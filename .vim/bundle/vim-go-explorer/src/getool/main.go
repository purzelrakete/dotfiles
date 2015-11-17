// Copyright 2015 Gary Burd. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"sort"
	"strings"
)

type Command struct {
	fs *flag.FlagSet
	do func(*Context) int
}

var commands = map[string]*Command{}

func main() {
	log.SetFlags(0)

	cwd := flag.String("cwd", ".", "use `dir` to resolve relative paths")

	flag.Usage = printUsage
	flag.Parse()

	if d, err := filepath.Abs(*cwd); err == nil {
		*cwd = d
	}

	args := flag.Args()
	if len(args) >= 1 {
		if c, ok := commands[args[0]]; ok {
			c.fs.Usage = func() {
				c.fs.PrintDefaults()
				os.Exit(1)
			}
			c.fs.Parse(args[1:])
			os.Exit(c.do(&Context{
				cwd:  *cwd,
				in:   os.Stdin,
				out:  os.Stdout,
				args: c.fs.Args(),
			}))
		}
	}
	log.Fatalf("getool: unknown command")
}

func printUsage() {
	var names []string
	for name, _ := range commands {
		names = append(names, name)
	}
	sort.Strings(names)
	fmt.Fprintf(os.Stderr, "%s %s\n", os.Args[0], strings.Join(names, "|"))
	flag.PrintDefaults()
}
