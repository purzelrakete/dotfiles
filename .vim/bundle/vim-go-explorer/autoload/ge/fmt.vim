" Copyright 2015 Gary Burd. All rights reserved.
" Use of this source code is governed by a BSD-style
" license that can be found in the LICENSE file.

" format formats the current buffer. If with_goimports is true then goimports
" is used to format the code. Otherwise, gofmt is used to format the code.
" Errors are written to the quickfix window if error_list is equal to 'c' or
" the location list of error_list is equal to 'l'.
"
" The caller must execute the return value to report errors.
function! ge#fmt#format(error_list, with_goimports) abort
    try
        let buf = join(getline(1, '$'), "\n")
        let out = ge#tool#runl(buf, 'fmt', '-goimport=' . a:with_goimports, expand('%:p'))
        if out[0] ==# 'ERR'
            if a:error_list ==# 'c'
                cexpr out[1:]
            elseif a:error_list ==# 'l'
                lexpr out[1:]
            endif
            return ''
        endif

        if out[0] ==# 'OK'
            return ''
        endif

        let m = matchlist(out[0], '\C\v^REPL ([0-9]+) ([0-9]+)$')
        if len(m)
            let v = winsaveview()
            let start = m[1] + 0
            let end = m[2] + 0
            if start <= end
                silent execute start . ',' . end . 'd'
            endif
            call append(start-1, out[1:])
            call winrestview(v)
            return ''
        endif

        echo out[0]
    catch /^go-explorer:/
        return 'echoerr v:errmsg'
    endtry
    return ''
endfunction

" vim:ts=4:sw=4:et
