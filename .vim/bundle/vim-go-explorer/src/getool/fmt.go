// Copyright 2015 Gary Burd. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package main

import (
	"bufio"
	"bytes"
	"flag"
	"fmt"
	"go/format"
	"go/parser"
	"go/token"
	"io/ioutil"

	"golang.org/x/tools/imports"
)

func init() {
	var fs flag.FlagSet
	goimport := fs.Bool("goimport", false, "use goimport instead of gofmt")
	commands["fmt"] = &Command{
		fs: &fs,
		do: func(ctx *Context) int { return doFormat(ctx, *goimport) },
	}
}

func doFormat(ctx *Context, goimport bool) int {
	w := bufio.NewWriter(ctx.out)
	defer w.Flush()

	fname := ""
	if len(ctx.args) == 1 {
		fname = ctx.args[0]
	}

	in, err := ioutil.ReadAll(ctx.in)
	if err != nil {
		fmt.Fprintf(w, "ERR\n%s", err)
		return 0
	}

	var out []byte

	if goimport {
		var err error
		out, err = imports.Process(fname, in, nil)
		if err != nil {
			fmt.Fprintf(w, "ERR\n%s", err)
			return 0
		}
	} else {
		fset := token.NewFileSet()
		file, err := parser.ParseFile(fset, fname, in, parser.ParseComments)
		if err != nil {
			fmt.Fprintf(w, "ERR\n%s", err)
			return 0
		}
		var buf bytes.Buffer
		if err := format.Node(&buf, fset, file); err != nil {
			fmt.Fprintf(w, "ERR\n%s", err)
			return 0
		}
		out = buf.Bytes()
	}

	// Input does not contain trailing newline, trim trailing newline from
	// output to match.
	if len(out) > 0 && out[len(out)-1] == '\n' {
		out = out[:len(out)-1]
	}

	if bytes.Equal(in, out) {
		fmt.Fprintf(w, "OK")
		return 0
	}

	linesIn := bytes.Split(in, []byte{'\n'})
	linesOut := bytes.Split(out, []byte{'\n'})

	n := len(linesOut)
	if len(linesIn) < len(linesOut) {
		n = len(linesIn)
	}

	head := 0
	for ; head < n; head++ {
		if !bytes.Equal(linesIn[head], linesOut[head]) {
			break
		}
	}

	n -= head

	tail := 0
	for ; tail < n; tail++ {
		if !bytes.Equal(linesIn[len(linesIn)-1-tail], linesOut[len(linesOut)-1-tail]) {
			break
		}
	}

	fmt.Fprintf(w, "REPL %d %d", head+1, len(linesIn)-tail)
	for _, l := range linesOut[head : len(linesOut)-tail] {
		fmt.Fprintf(w, "\n%s", l)
	}
	return 0
}
