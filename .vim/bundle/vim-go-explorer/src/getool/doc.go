// Copyright 2015 Gary Burd. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package main

import (
	"bytes"
	"flag"
	"fmt"
	"go/ast"
	"go/build"
	"go/doc"
	"go/printer"
	"go/scanner"
	"go/token"
	"io"
	"io/ioutil"
	"path"
	"path/filepath"
	"regexp"
	"sort"
	"strconv"
	"strings"
	"unicode"
	"unicode/utf8"
)

const textIndent = "    "
const textWidth = 80 - len(textIndent)

func init() {
	var fs flag.FlagSet
	all := fs.Bool("all", false, "show unexported identifiers")
	commands["doc"] = &Command{
		fs: &fs,
		do: func(ctx *Context) int { return doDoc(ctx, *all) },
	}
}

func doDoc(ctx *Context, all bool) int {
	if len(ctx.args) != 1 {
		fmt.Fprint(ctx.out, "one command line argument expected")
		return 1
	}

	importPath := filepath.ToSlash(ctx.args[0])
	importPath = strings.TrimPrefix(importPath, "godoc://")

	p := docPrinter{
		importPath: importPath,
		lineNum:    1,
		lineOffset: -1,
		index:      make(map[string]int),
	}

	if importPath != "" {
		flags := loadDoc | loadExamples
		if all {
			flags |= loadUnexported
		}
		pkg, err := ctx.loadPackage(importPath, flags)
		if err != nil {
			fmt.Fprintf(ctx.out, "E\n%s", err)
			return 0
		}
		p.bpkg = pkg.bpkg
		p.dpkg = pkg.dpkg
		p.fset = pkg.fset
		p.examples = pkg.examples
	}

	p.execute(ctx.out, all)
	return 0
}

type docPrinter struct {
	importPath string
	fset       *token.FileSet
	bpkg       *build.Package
	dpkg       *doc.Package

	examples []*doc.Example

	// Output buffers
	buf     bytes.Buffer
	metaBuf bytes.Buffer

	index map[string]int

	// Fields used by outputPosition
	lineNum    int
	lineOffset int
	scanOffset int
}

func (p *docPrinter) execute(out io.Writer, all bool) {
	printDecls := false

	switch {
	case p.importPath == "":
		// root
	case p.dpkg == nil:
		p.buf.WriteString("Directory ")
		p.printLink(path.Base(p.importPath), p.bpkg.Dir, p.stringAddress(""))
		p.buf.WriteString("\n\n")
	case p.dpkg.Name == "main":
		p.buf.WriteString("Command ")
		p.printLink(path.Base(p.importPath), p.bpkg.Dir, p.stringAddress(""))
		p.buf.WriteString("\n\n")
		p.printText(p.dpkg.Doc)
		printDecls = all
	default:
		p.buf.WriteString("package ")
		p.printLink(p.dpkg.Name, p.bpkg.Dir, p.stringAddress(""))
		p.buf.WriteString("\n\n" + textIndent + "import \"")
		p.buf.WriteString(p.dpkg.ImportPath)
		p.buf.WriteString("\"\n\n")
		p.printText(p.dpkg.Doc)
		p.printExamples("")
		printDecls = true
	}

	if printDecls {
		p.buf.WriteString("FILES\n")
		p.printFiles(p.bpkg.GoFiles, p.bpkg.CgoFiles)
		p.printFiles(p.bpkg.TestGoFiles, p.bpkg.XTestGoFiles)
		p.buf.WriteString("\n")

		if len(p.dpkg.Consts) > 0 {
			p.buf.WriteString("CONSTANTS\n\n")
			p.printValues(p.dpkg.Consts)
		}

		if len(p.dpkg.Vars) > 0 {
			p.buf.WriteString("VARIABLES\n\n")
			p.printValues(p.dpkg.Vars)
		}

		if len(p.dpkg.Funcs) > 0 {
			p.buf.WriteString("FUNCTIONS\n\n")
			p.printFuncs(p.dpkg.Funcs, "")
		}

		if len(p.dpkg.Types) > 0 {
			p.buf.WriteString("TYPES\n\n")
			for _, d := range p.dpkg.Types {
				p.printDecl(d.Decl)
				p.printText(d.Doc)
				p.printExamples(d.Name)
				p.printValues(d.Consts)
				p.printValues(d.Vars)
				p.printFuncs(d.Funcs, "")
				p.printFuncs(d.Methods, d.Name+"_")
			}
		}

		p.printImports()
	}

	if p.importPath != "" {
		p.buf.WriteString("DIRECTORIES\n\n")
		p.buf.WriteString(textIndent)
		up := path.Dir(p.importPath)
		if up == "." {
			up = ""
		}
		p.printLink("..", "godoc://"+up, p.stringAddress(""))
		p.buf.WriteString(" (up a directory)\n")
		p.printDirs(append(filepath.SplitList(build.Default.GOPATH), build.Default.GOROOT))
	} else {
		p.buf.WriteString("\n\nStandard Packages\n\n")
		p.printDirs([]string{build.Default.GOROOT})
		p.buf.WriteString("\n\nThird Party Packages\n\n")
		p.printDirs(filepath.SplitList(build.Default.GOPATH))
	}

	p.metaBuf.WriteString("D\n")
	p.metaBuf.WriteTo(out)
	p.buf.WriteTo(out)
}

const (
	noAnnotation = iota
	anchorAnnotation
	packageLinkAnnoation
	linkAnnotation
	startLinkAnnotation
	endLinkAnnotation
)

type annotation struct {
	kind int
	data string
	pos  token.Pos
}

func (p *docPrinter) printDecl(decl ast.Decl) {
	v := &declVisitor{}
	ast.Walk(v, decl)
	var w bytes.Buffer
	err := (&printer.Config{Tabwidth: 4}).Fprint(
		&w,
		p.fset,
		&printer.CommentedNode{Node: decl, Comments: v.comments})
	if err != nil {
		p.buf.WriteString(err.Error())
		return
	}
	buf := bytes.TrimRight(w.Bytes(), " \t\n")

	var s scanner.Scanner
	fset := token.NewFileSet()
	file := fset.AddFile("", fset.Base(), len(buf))
	base := file.Base()
	s.Init(file, buf, nil, scanner.ScanComments)
	lastOffset := 0
	var startPos int64
loop:
	for {
		pos, tok, lit := s.Scan()
		switch tok {
		case token.EOF:
			break loop
		case token.IDENT:
			if len(v.annotations) == 0 {
				// Oops!
				break loop
			}
			offset := int(pos) - base
			p.buf.Write(buf[lastOffset:offset])
			lastOffset = offset + len(lit)
			a := v.annotations[0]
			v.annotations = v.annotations[1:]
			switch a.kind {
			case startLinkAnnotation:
				startPos = p.adjustedOutputPosition()
				p.buf.WriteString(lit)
			case linkAnnotation:
				startPos = p.adjustedOutputPosition()
				fallthrough
			case endLinkAnnotation:
				file := ""
				if a.data != "" {
					file = "godoc://" + a.data
				}
				p.buf.WriteString(lit)
				p.addLink(startPos, file, p.stringAddress(lit))
			case packageLinkAnnoation:
				p.printLink(lit, "godoc://"+a.data, p.stringAddress(""))
			case anchorAnnotation:
				p.addAnchor(lit, a.data)
				position := p.fset.Position(a.pos)
				p.printLink(lit,
					filepath.Join(p.bpkg.Dir, position.Filename),
					-p.lineColumnAddress(position.Line, position.Column))
			default:
				p.buf.WriteString(lit)
			}
		}
	}
	p.buf.Write(buf[lastOffset:])
	p.buf.WriteString("\n\n")
}

func (p *docPrinter) printText(s string) {
	s = strings.TrimRight(s, " \t\n")
	if s != "" {
		doc.ToText(&p.buf, s, textIndent, textIndent+"\t", textWidth)
		b := p.buf.Bytes()
		if b[len(b)-1] != '\n' {
			p.buf.WriteByte('\n')
		}
		p.buf.WriteByte('\n')
	}
}

var exampleOutputRx = regexp.MustCompile(`(?i)//[[:space:]]*output:`)

func (p *docPrinter) printExamples(name string) {
	for _, e := range p.examples {
		if !strings.HasPrefix(e.Name, name) {
			continue
		}
		name := e.Name[len(name):]
		if name != "" {
			if i := strings.LastIndex(name, "_"); i != 0 {
				continue
			}
			name = name[1:]
			if r, _ := utf8.DecodeRuneInString(name); unicode.IsUpper(r) {
				continue
			}
			name = strings.Title(name)
		}

		var node interface{}
		if _, ok := e.Code.(*ast.File); ok {
			node = e.Play
		} else {
			node = &printer.CommentedNode{Node: e.Code, Comments: e.Comments}
		}

		var buf bytes.Buffer
		err := (&printer.Config{Tabwidth: 4}).Fprint(&buf, p.fset, node)
		if err != nil {
			continue
		}

		// Additional formatting if this is a function body.
		b := buf.Bytes()
		if i := len(b); i >= 2 && b[0] == '{' && b[i-1] == '}' {
			// Remove surrounding braces.
			b = b[1 : i-1]
			// Unindent
			b = bytes.Replace(b, []byte("\n    "), []byte("\n"), -1)
			// Remove output comment
			if j := exampleOutputRx.FindIndex(b); j != nil {
				b = bytes.TrimSpace(b[:j[0]])
			}
		} else {
			// Drop output, as the output comment will appear in the code
			e.Output = ""
		}

		// Hide examples for now. I tried displaying comments inline and folded
		// and found them both distracting. Consider includling link from doc
		// to examples at the end of the page.
		/*
			p.buf.Write(b)
			p.buf.WriteByte('\n')
			if e.Output != "" {
				p.buf.WriteString(e.Output)
				buf.WriteByte('\n')
			}
			p.buf.WriteByte('\n')
		*/
	}
}

func (p *docPrinter) printFiles(sets ...[]string) {
	var fnames []string
	for _, set := range sets {
		fnames = append(fnames, set...)
	}
	if len(fnames) == 0 {
		return
	}

	sort.Strings(fnames)

	col := 0
	p.buf.WriteByte('\n')
	p.buf.WriteString(textIndent)
	for _, fname := range fnames {
		n := utf8.RuneCountInString(fname)
		if col != 0 {
			if col+n+3 > textWidth {
				col = 0
				p.buf.WriteByte('\n')
				p.buf.WriteString(textIndent)
			} else {
				col += 1
				p.buf.WriteByte(' ')
			}
		}
		p.printLink(fname, filepath.Join(p.bpkg.Dir, fname), p.stringAddress(""))
		col += n + 2
	}
	p.buf.WriteString("\n")
}

func (p *docPrinter) printValues(values []*doc.Value) {
	for _, d := range values {
		p.printDecl(d.Decl)
		p.printText(d.Doc)
	}
}

func (p *docPrinter) printFuncs(funcs []*doc.Func, examplePrefix string) {
	for _, d := range funcs {
		p.printDecl(d.Decl)
		p.printText(d.Doc)
		p.printExamples(examplePrefix + d.Name)
	}
}

func (p *docPrinter) printImports() {
	if len(p.bpkg.Imports) == 0 {
		return
	}
	p.buf.WriteString("IMPORTS\n\n")
	for _, imp := range p.bpkg.Imports {
		p.buf.WriteString(textIndent)
		startPos := p.outputPosition()
		p.buf.WriteString(imp)
		p.addLink(startPos, "godoc://"+imp, p.stringAddress(""))
		p.buf.WriteByte('\n')
	}
	p.buf.WriteString("\n")
}

func (p *docPrinter) printDirs(roots []string) {
	m := map[string]bool{}
	for _, root := range roots {
		dir := filepath.Join(root, "src", filepath.FromSlash(p.importPath))
		fis, err := ioutil.ReadDir(dir)
		if err != nil {
			continue
		}
		for _, fi := range fis {
			if !fi.IsDir() || strings.HasPrefix(fi.Name(), ".") {
				continue
			}
			m[fi.Name()] = true
		}
	}

	var names []string
	for name := range m {
		names = append(names, name)
	}
	sort.Strings(names)

	for _, name := range names {
		p.buf.WriteString(textIndent)
		startPos := p.outputPosition()
		p.buf.WriteString(name)
		p.addLink(startPos, "godoc://"+path.Join(p.importPath, name), p.stringAddress(""))
		p.buf.WriteByte('\n')
	}
}

func (p *docPrinter) printLink(s string, file string, address int64) {
	startPos := p.outputPosition()
	p.buf.WriteString(s)
	p.addLink(startPos, file, address)
}

func (p *docPrinter) addLink(startPos int64, file string, address int64) {
	fmt.Fprintf(&p.metaBuf, "L %d %d %d %d\n", startPos, p.outputPosition(), p.stringAddress(file), address)
}

func (p *docPrinter) addAnchor(name, typeName string) {
	if typeName != "" {
		name = typeName + "." + name
	}
	fmt.Fprintf(&p.metaBuf, "A %d %s\n", p.outputPosition(), name)
}

func (p *docPrinter) stringAddress(s string) int64 {
	if i, ok := p.index[s]; ok {
		return int64(i)
	}
	i := len(p.index)
	p.index[s] = i
	fmt.Fprintf(&p.metaBuf, "S %s\n", s)
	return int64(i)
}

func (p *docPrinter) lineColumnAddress(line, col int) int64 {
	return int64(line)*10000 + int64(col)
}

func (p *docPrinter) outputPosition() int64 {
	b := p.buf.Bytes()
	for i, c := range b[p.scanOffset:] {
		if c == '\n' {
			p.lineNum += 1
			p.lineOffset = p.scanOffset + i
		}
	}
	p.scanOffset = len(b)
	return p.lineColumnAddress(p.lineNum, len(b)-p.lineOffset)
}

func (p *docPrinter) adjustedOutputPosition() int64 {
	b := p.buf.Bytes()
	b = bytes.TrimSuffix(b, []byte{'*'})
	b = bytes.TrimSuffix(b, []byte{'[', ']'})
	b = bytes.TrimSuffix(b, []byte{'*'})
	b = bytes.TrimSuffix(b, []byte{'&'})
	return p.outputPosition() - int64(p.buf.Len()-len(b))
}

const (
	notPredeclared = iota
	predeclaredType
	predeclaredConstant
	predeclaredFunction
)

// predeclared represents the set of all predeclared identifiers.
var predeclared = map[string]int{
	"bool":       predeclaredType,
	"byte":       predeclaredType,
	"complex128": predeclaredType,
	"complex64":  predeclaredType,
	"error":      predeclaredType,
	"float32":    predeclaredType,
	"float64":    predeclaredType,
	"int16":      predeclaredType,
	"int32":      predeclaredType,
	"int64":      predeclaredType,
	"int8":       predeclaredType,
	"int":        predeclaredType,
	"rune":       predeclaredType,
	"string":     predeclaredType,
	"uint16":     predeclaredType,
	"uint32":     predeclaredType,
	"uint64":     predeclaredType,
	"uint8":      predeclaredType,
	"uint":       predeclaredType,
	"uintptr":    predeclaredType,

	"true":  predeclaredConstant,
	"false": predeclaredConstant,
	"iota":  predeclaredConstant,
	"nil":   predeclaredConstant,

	"append":  predeclaredFunction,
	"cap":     predeclaredFunction,
	"close":   predeclaredFunction,
	"complex": predeclaredFunction,
	"copy":    predeclaredFunction,
	"delete":  predeclaredFunction,
	"imag":    predeclaredFunction,
	"len":     predeclaredFunction,
	"make":    predeclaredFunction,
	"new":     predeclaredFunction,
	"panic":   predeclaredFunction,
	"print":   predeclaredFunction,
	"println": predeclaredFunction,
	"real":    predeclaredFunction,
	"recover": predeclaredFunction,
}

// declVisitor modifies a declaration AST for printing and collects annotations.
type declVisitor struct {
	annotations []*annotation
	comments    []*ast.CommentGroup
}

func (v *declVisitor) addAnnoation(kind int, data string, pos token.Pos) {
	v.annotations = append(v.annotations, &annotation{kind: kind, data: data, pos: pos})
}

func (v *declVisitor) ignoreName() {
	v.annotations = append(v.annotations, &annotation{kind: noAnnotation})
}

func (v *declVisitor) Visit(n ast.Node) ast.Visitor {
	switch n := n.(type) {
	case *ast.TypeSpec:
		v.addAnnoation(anchorAnnotation, "", n.Pos())
		name := n.Name.Name
		switch n := n.Type.(type) {
		case *ast.InterfaceType:
			for _, f := range n.Methods.List {
				for _, n := range f.Names {
					v.addAnnoation(anchorAnnotation, name, n.Pos())
				}
				ast.Walk(v, f.Type)
			}
		case *ast.StructType:
			for _, f := range n.Fields.List {
				for _, n := range f.Names {
					v.addAnnoation(anchorAnnotation, name, n.Pos())
				}
				ast.Walk(v, f.Type)
			}
		default:
			ast.Walk(v, n)
		}
	case *ast.FuncDecl:
		if n.Recv == nil {
			v.addAnnoation(anchorAnnotation, "", n.Name.NamePos)
		} else {
			ast.Walk(v, n.Recv)
			if len(n.Recv.List) > 0 {
				typ := n.Recv.List[0].Type
				if se, ok := typ.(*ast.StarExpr); ok {
					typ = se.X
				}
				if id, ok := typ.(*ast.Ident); ok {
					v.addAnnoation(anchorAnnotation, id.Name, n.Name.NamePos)
				}
			}
		}

		ast.Walk(v, n.Type)
	case *ast.Field:
		for _ = range n.Names {
			v.ignoreName()
		}
		ast.Walk(v, n.Type)
	case *ast.ValueSpec:
		for _, n := range n.Names {
			v.addAnnoation(anchorAnnotation, "", n.Pos())
		}
		if n.Type != nil {
			ast.Walk(v, n.Type)
		}
		for _, x := range n.Values {
			ast.Walk(v, x)
		}
	case *ast.Ident:
		switch {
		case n.Obj == nil && predeclared[n.Name] != notPredeclared:
			v.addAnnoation(linkAnnotation, "builtin", 0)
		case n.Obj != nil && ast.IsExported(n.Name):
			v.addAnnoation(linkAnnotation, "", 0)
		default:
			v.ignoreName()
		}
	case *ast.SelectorExpr:
		if x, _ := n.X.(*ast.Ident); x != nil {
			if obj := x.Obj; obj != nil && obj.Kind == ast.Pkg {
				if spec, _ := obj.Decl.(*ast.ImportSpec); spec != nil {
					if path, err := strconv.Unquote(spec.Path.Value); err == nil {
						if path == "C" {
							v.ignoreName()
							v.ignoreName()
						} else if n.Sel.Pos()-x.End() == 1 {
							v.addAnnoation(startLinkAnnotation, path, 0)
							v.addAnnoation(endLinkAnnotation, path, 0)
						} else {
							v.addAnnoation(packageLinkAnnoation, path, 0)
							v.addAnnoation(linkAnnotation, path, 0)
						}
						return nil
					}
				}
			}
		}
		ast.Walk(v, n.X)
		v.ignoreName()
	case *ast.BasicLit:
		if n.Kind == token.STRING && len(n.Value) > 128 {
			v.comments = append(v.comments,
				&ast.CommentGroup{List: []*ast.Comment{{
					Slash: n.Pos(),
					Text:  fmt.Sprintf("/* %d byte string literal not displayed */", len(n.Value)),
				}}})
			n.Value = `""`
		} else {
			return v
		}
	case *ast.CompositeLit:
		if len(n.Elts) > 100 {
			if n.Type != nil {
				ast.Walk(v, n.Type)
			}
			v.comments = append(v.comments,
				&ast.CommentGroup{List: []*ast.Comment{{
					Slash: n.Lbrace,
					Text:  fmt.Sprintf("/* %d elements not displayed */", len(n.Elts)),
				}}})
			n.Elts = n.Elts[:0]
		} else {
			return v
		}
	default:
		return v
	}
	return nil
}
