// Copyright 2015 Gary Burd. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

// The complete and resolve commands support three forms of package
// specifications:
//
//  importpath - Import path
//  ./relpath   - Relative path
//  \name       - Name of imported package
//
// The complete and resolve commands silently ignore errors. It is assumed that
// downstream uses of the command results will detect and handle errors in some
// way.

package main

import (
	"flag"
	"fmt"
	"go/ast"
	"go/build"
	"go/parser"
	"go/token"
	"io"
	"io/ioutil"
	"path"
	"path/filepath"
	"sort"
	"strconv"
	"strings"
)

func init() {
	var cfs flag.FlagSet
	commands["complete-package-id"] = &Command{
		fs: &cfs,
		do: func(ctx *Context) int { return doCompletePackageID(ctx) },
	}
	var rfs flag.FlagSet
	commands["resolve-package"] = &Command{
		fs: &rfs,
		do: func(ctx *Context) int { return doResolvePackage(ctx) },
	}
}

func doCompletePackageID(ctx *Context) int {
	if len(ctx.args) != 3 {
		fmt.Fprint(ctx.out, "complete: three arguments required\n")
		return 1
	}
	argLead := ctx.args[0]
	cmdLine := ctx.args[1]
	f := strings.Fields(cmdLine)
	var completions []string
	if len(f) >= 3 || (len(f) == 2 && argLead == "") {
		completions = completeID(ctx, resolvePackageSpec(ctx, f[1]), argLead)
	} else {
		completions = completePackage(ctx, argLead)
	}
	io.Copy(ioutil.Discard, ctx.in)
	ctx.out.Write([]byte(strings.Join(completions, "\n")))
	return 0
}

func completePackage(ctx *Context, arg string) (completions []string) {
	switch {
	case arg == ".":
		completions = []string{"./", "../"}

	case arg == "..":
		completions = []string{"../"}

	case strings.HasPrefix(arg, "."):
		// Complete using relative directory.
		bpkg, err := build.Import(".", ctx.cwd, build.FindOnly)
		if err != nil {
			return nil
		}
		dir, name := path.Split(arg)
		fis, err := ioutil.ReadDir(filepath.Join(bpkg.Dir, filepath.FromSlash(dir)))
		if err != nil {
			return nil
		}
		for _, fi := range fis {
			if !fi.IsDir() || strings.HasPrefix(fi.Name(), ".") {
				continue
			}
			if strings.HasPrefix(fi.Name(), name) {
				completions = append(completions, path.Join(dir, fi.Name())+"/")
			}
		}
		sort.Strings(completions)

	case strings.HasPrefix(arg, "\\"):
		// Complete with package names imported in current file.
		for n := range readImports(ctx.in) {
			if strings.HasPrefix(n, arg[1:]) {
				completions = append(completions, "\\"+n)
			}
		}
		if len(completions) == 0 && len(completePackageByPath(arg)) > 0 {
			// Fallback to arg if arg will complete on import path.
			completions = []string{arg}
		}
		sort.Strings(completions)

	default:
		// Complete using import path.
		completions = completePackageByPath(arg)
		sort.Strings(completions)
	}
	return completions
}

func completePackageByPath(arg string) []string {
	var completions []string
	dir, name := path.Split(arg)
	for _, srcDir := range build.Default.SrcDirs() {
		fis, err := ioutil.ReadDir(filepath.Join(srcDir, filepath.FromSlash(dir)))
		if err != nil {
			continue
		}
		for _, fi := range fis {
			if !fi.IsDir() || strings.HasPrefix(fi.Name(), ".") {
				continue
			}
			if strings.HasPrefix(fi.Name(), name) {
				completions = append(completions, path.Join(dir, fi.Name())+"/")
			}
		}
	}
	return completions
}

func completeID(ctx *Context, importPath string, arg string) (completions []string) {
	pkg, err := ctx.loadPackage(importPath, loadDoc)
	if err != nil {
		return []string{arg}
	}

	typeName := ""
	name := strings.ToLower(arg)
	if i := strings.Index(name, "."); i >= 0 {
		typeName = name[:i]
		name = name[i+1:]
	}

	dpkg := pkg.dpkg

	if typeName == "" {
		untangleDoc(dpkg)
		add := func(n string) {
			if strings.HasPrefix(strings.ToLower(n), name) {
				completions = append(completions, n)
			}
		}
		for _, d := range append(pkg.dpkg.Consts, pkg.dpkg.Vars...) {
			for _, n := range d.Names {
				add(n)
			}
		}
		for _, d := range pkg.dpkg.Funcs {
			add(d.Name)
		}
		for _, d := range pkg.dpkg.Types {
			add(d.Name + ".")
		}
	} else {
		for _, d := range pkg.dpkg.Types {
			if strings.ToLower(d.Name) == typeName {
				add := func(n string) {
					if strings.HasPrefix(strings.ToLower(n), name) {
						completions = append(completions, d.Name+"."+n)
					}
				}
				for _, d := range d.Methods {
					add(d.Name)
				}
			}
		}
	}

	sort.Strings(completions)
	return completions
}

func resolvePackageSpec(ctx *Context, spec string) string {
	path := strings.TrimRight(spec, "/")
	switch {
	case strings.HasPrefix(spec, "."):
		if bpkg, err := build.Import(spec, ctx.cwd, build.FindOnly); err == nil {
			path = bpkg.ImportPath
		}
	case strings.HasPrefix(spec, "\\"):
		if p, ok := readImports(ctx.in)[spec[1:]]; ok {
			path = p
		}
	}
	return path
}

func doResolvePackage(ctx *Context) int {
	if len(ctx.args) != 1 {
		fmt.Fprint(ctx.out, "resolve: one argument required\n")
		return 1
	}
	path := resolvePackageSpec(ctx, ctx.args[0])
	io.Copy(ioutil.Discard, ctx.in)
	io.WriteString(ctx.out, path)
	return 0
}

// readImports returns the imports in the Go source file read from r. Errors
// are silently ignored.
func readImports(r io.Reader) map[string]string {
	fset := token.NewFileSet()
	file, err := parser.ParseFile(fset, "", r, parser.ImportsOnly)
	if err != nil {
		return nil
	}
	paths := map[string]string{}
	set := map[string]bool{}
	for _, decl := range file.Decls {
		d, ok := decl.(*ast.GenDecl)
		if !ok {
			continue
		}
		for _, dspec := range d.Specs {
			spec, ok := dspec.(*ast.ImportSpec)
			if !ok || spec.Path == nil {
				continue
			}
			quoted := spec.Path.Value
			path, err := strconv.Unquote(quoted)
			if err != nil || path == "C" {
				continue
			}
			if spec.Name != nil {
				paths[spec.Name.Name] = path
				set[spec.Name.Name] = true
			} else {
				name := guessNameFromPath(path)
				if !set[path] {
					paths[name] = path
				}
			}
		}
	}
	return paths
}
