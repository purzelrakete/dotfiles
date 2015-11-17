// Copyright 2015 Gary Burd. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package main

import (
	"go/doc"
	"regexp"
)

func untangleDoc(dpkg *doc.Package) {
	for _, t := range dpkg.Types {
		dpkg.Consts = append(dpkg.Consts, t.Consts...)
		t.Consts = nil
		dpkg.Vars = append(dpkg.Vars, t.Vars...)
		t.Vars = nil
		dpkg.Funcs = append(dpkg.Funcs, t.Funcs...)
		t.Funcs = nil
	}
}

var packageNamePats = []*regexp.Regexp{
	// Last element with .suffix removed.
	regexp.MustCompile(`/([^-./]+)[-.](?:git|svn|hg|bzr|v\d+)$`),

	// Last element with "go" prefix or suffix removed.
	regexp.MustCompile(`/([^-./]+)[-.]go$`),
	regexp.MustCompile(`/go[-.]([^-./]+)$`),

	// Special cases for popular repos.
	regexp.MustCompile(`^code\.google\.com/p/google-api-go-client/([^/]+)/v[^/]+$`),
	regexp.MustCompile(`^code\.google\.com/p/biogo\.([^/]+)$`),

	// It's also common for the last element of the path to contain an
	// extra "go" prefix, but not always. TODO: examine unresolved ids to
	// detect when trimming the "go" prefix is appropriate.

	// Last component of path.
	regexp.MustCompile(`([^/]+)$`),
}

// guessNameFromPath guesses the package name from the package path.
func guessNameFromPath(path string) string {
	// Guess the package name without importing it.
	for _, pat := range packageNamePats {
		m := pat.FindStringSubmatch(path)
		if m != nil {
			return m[1]
		}
	}
	return ""
}

type byFuncName []*doc.Func

func (s byFuncName) Len() int           { return len(s) }
func (s byFuncName) Swap(i, j int)      { s[i], s[j] = s[j], s[i] }
func (s byFuncName) Less(i, j int) bool { return s[i].Name < s[j].Name }
