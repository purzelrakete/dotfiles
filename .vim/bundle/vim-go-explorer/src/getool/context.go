// Copyright 2015 Gary Burd. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package main

import (
	"errors"
	"go/ast"
	"go/build"
	"go/doc"
	"go/parser"
	"go/token"
	"io"
	"io/ioutil"
	"path/filepath"
	"regexp"
	"sort"
)

type Context struct {
	cwd  string
	args []string
	in   io.Reader
	out  io.Writer
}

var linePat = regexp.MustCompile(`(?m)^//line .*$`)

func simpleImporter(imports map[string]*ast.Object, path string) (*ast.Object, error) {
	pkg := imports[path]
	if pkg != nil {
		return pkg, nil
	}

	n := guessNameFromPath(path)
	if n == "" {
		return nil, errors.New("package not found")
	}

	pkg = ast.NewObj(ast.Pkg, n)
	pkg.Data = ast.NewScope(nil)
	imports[path] = pkg
	return pkg, nil
}

type Package struct {
	fset     *token.FileSet
	bpkg     *build.Package
	apkg     *ast.Package
	dpkg     *doc.Package
	examples []*doc.Example
	errors   []error
}

func (pkg *Package) parseFile(name string) (*ast.File, error) {
	p, err := ioutil.ReadFile(filepath.Join(pkg.bpkg.Dir, name))
	if err != nil {
		return nil, err
	}
	// overwrite //line comments
	for _, m := range linePat.FindAllIndex(p, -1) {
		for i := m[0] + 2; i < m[1]; i++ {
			p[i] = ' '
		}
	}
	return parser.ParseFile(pkg.fset, name, p, parser.ParseComments)
}

const (
	loadDoc = 1 << iota
	loadExamples
	loadUnexported
)

func (ctx *Context) loadPackage(importPath string, flags int) (*Package, error) {
	bpkg, err := build.Import(importPath, ctx.cwd, 0)
	if _, ok := err.(*build.NoGoError); ok {
		return &Package{bpkg: bpkg}, nil
	}
	if err != nil {
		return nil, err
	}

	pkg := &Package{
		fset: token.NewFileSet(),
		bpkg: bpkg,
	}

	files := make(map[string]*ast.File)
	for _, name := range append(pkg.bpkg.GoFiles, pkg.bpkg.CgoFiles...) {
		file, err := pkg.parseFile(name)
		if err != nil {
			pkg.errors = append(pkg.errors, err)
			continue
		}
		files[name] = file
	}

	pkg.apkg, _ = ast.NewPackage(pkg.fset, files, simpleImporter, nil)

	if flags&loadDoc != 0 {
		mode := doc.Mode(0)
		if pkg.bpkg.ImportPath == "builtin" || flags&loadUnexported != 0 {
			mode |= doc.AllDecls
		}
		pkg.dpkg = doc.New(pkg.apkg, pkg.bpkg.ImportPath, mode)
		if pkg.bpkg.ImportPath == "builtin" {
			for _, t := range pkg.dpkg.Types {
				pkg.dpkg.Funcs = append(pkg.dpkg.Funcs, t.Funcs...)
				t.Funcs = nil
			}
			sort.Sort(byFuncName(pkg.dpkg.Funcs))
		}
	}

	if flags&loadExamples != 0 {
		for _, name := range append(pkg.bpkg.TestGoFiles, pkg.bpkg.XTestGoFiles...) {
			file, err := pkg.parseFile(name)
			if err != nil {
				pkg.errors = append(pkg.errors, err)
				continue
			}
			pkg.examples = append(pkg.examples, doc.Examples(file)...)
		}
	}

	return pkg, nil
}
