" Copyright 2015 Gary Burd. All rights reserved.
" Use of this source code is governed by a BSD-style
" license that can be found in the LICENSE file.

function! s:throw(string) abort
  let v:errmsg = 'go-explorer: ' . a:string
  throw v:errmsg
endfunction

function! s:tool_binary() abort
    if executable('getool')
        return 'getool'
    endif

    let sep = '/'
    let list_sep = ':'
    for feature in ['win16', 'win32', 'win32unix', 'win64', 'win95']
        if (has(feature))
            let sep = '/'
            let list_sep = ';'
            break
        endif
    endfor

    let bin = $GOBIN . sep . 'getool'
    if executable(bin)
        return bin
    endif

    for path in split($GOPATH, list_sep)
        let bin = path . sep . 'bin' . sep . 'getool'
        if executable(bin)
            return bin
        endif
    endfor

    call s:throw('getool not found, run "go get -u github.com/garyburd/go-explorer/src/getool" to install')
endfunction

function! s:run(input, args) abort
    let cmd = s:tool_binary()
    for arg in a:args
        let cmd = cmd . ' ' . shellescape(arg)
    endfor
    if a:input ==# ''
        let result = system(cmd)
    else
        let result = system(cmd, a:input)
    endif
    if v:shell_error
        call s:throw(result)
    endif
    return result
endfunction

" run returns output of running tool_binary with arguments ... and stdin set to
" input.
function ge#tool#run(input, ...) abort
    return s:run(a:input, a:000)
endfunction

" runl is like run, but returns output as a list.
function ge#tool#runl(input, ...) abort
    return split(s:run(a:input, a:000), "\n", 1)
endfunction

" vim:ts=4:sw=4:et
