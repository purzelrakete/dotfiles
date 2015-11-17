" Copyright 2015 Gary Burd. All rights reserved.
" Use of this source code is governed by a BSD-style
" license that can be found in the LICENSE file.

if exists('b:current_syntax')
  finish
endif

syntax case match
syntax region godocSection start='^[^ \t)}]' end='^[^ \t)}]'me=e-1 fold contains=godocDecl,godocHead

syntax region godocDecl start='^\(package\|const\|var\|func\|type\) ' end='^$' contained contains=godocComment,godocParen,godocBrace
syntax region godocParen start='(' end=')' contained contains=godocComment,godocParen,godocBrace
syntax region godocBrace start='{' end='}' contained contains=godocComment,godocParen,godocBrace
syntax region godocComment start='/\*' end='\*/'  contained
syntax region godocComment start='//' end='$' contained

syntax match godocHead '\n\n\n    [^\t ].*$' contained
syntax match godocHead '^[A-Z].*$' contained

syntax sync fromstart

highlight link godocComment Comment
highlight link godocHead Constant
highlight link godocDecl Type
highlight link godocParen Type
highlight link godocBrace Type

let b:current_syntax = 'gedoc'

" vim:ts=4 sts=2 sw=2:
