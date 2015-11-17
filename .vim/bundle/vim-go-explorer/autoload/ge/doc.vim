" Copyright 2015 Gary Burd. All rights reserved.
" Use of this source code is governed by a BSD-style
" license that can be found in the LICENSE file.

" read loads a buffer with documentation, link and anchor data. This function
" is intended to be called from a BufReadCmd event.
"
" The caller must execute the return value to report errors.
function! ge#doc#read() abort
    try
        setlocal noreadonly modifiable
        let b:strings = []
        let b:links = []
        let b:anchors = {}
        if !exists("b:gedoc_showall")
            let b:gedoc_showall = 0
        endif
        if b:gedoc_showall
            let out = ge#tool#runl('', 'doc', '--all', expand('%'))
        else
            let out = ge#tool#runl('', 'doc', expand('%'))
        endif
        let index = 0
        while index < len(out)
            let line = out[index]
            let index = index + 1
            let m = matchlist(line, '\C\v^S (.*)')
            if len(m)
                " String
                let b:strings = add(b:strings, m[1])
                continue
            endif
            let m = matchlist(line, '\C\v^L ([0-9]+) ([0-9]+) ([0-9]+) ([-0-9]+)$')
            if len(m)
                " Link: start, end, file, position
                call add(b:links, [str2nr(m[1]), str2nr(m[2]), str2nr(m[3]), str2nr(m[4])])
                continue
            endif
            let m = matchlist(line, '\C\v^A ([0-9]+) (\S+)$')
            if len(m)
                " Anchor: position, name
                let b:anchors[m[2]] = str2nr(m[1])
                continue
            endif
             if line ==# 'D'
                " Document
                call append(0, out[index : -1])
                break
            endif
            if line ==# 'E'
                " Error
                call append(0, out[index : -1])
                setlocal buftype=nofile bufhidden=delete nobuflisted noswapfile nomodifiable
                break
            end
        endwhile
        setlocal foldlevel=1 foldtext=ge#doc#foldtext() foldcolumn=0 foldmethod=syntax
        setlocal buftype=nofile bufhidden=hide noswapfile nomodifiable readonly
        setlocal nonumber tabstop=4
        setfiletype gedoc
        silent 0
        nnoremap <buffer> <silent> <c-]> :execute <SID>jump()<CR>
        nnoremap <buffer> <silent> <c-t> :execute <SID>pop()<CR>
        nnoremap <buffer> <silent> <c-a> :execute <SID>toggle_all()<CR>
        nnoremap <buffer> <silent> ]] :execute <SID>next_section('')<CR>
        nnoremap <buffer> <silent> [[ :execute <SID>next_section('b')<CR>
        noremap <buffer> <silent> <2-LeftMouse> :execute <SID>jump()<CR>
        autocmd! * <buffer>
        autocmd BufWinLeave <buffer> execute s:clear_highlight()
        autocmd CursorMoved <buffer> execute s:update_highlight()
    catch /^go-explorer:/
        return 'echoerr v:errmsg'
    endtry
    return ''
endfunction

" open implements the GeDoc command.
function! ge#doc#open(...) abort
    if a:0 < 1 || a:0 > 2
       return 'echoerr "one or two arguments required"'
    endif
    let pos = 0
    if a:0 >= 2
        let pos = a:2
        if len(pos) > 0 && pos[-1:] ==# '.'
            let pos = pos[:-2]
        endif
        let pos = "'" . escape(pos, '\') . "'"
    endif
    try
        let p = ge#complete#resolve_package(a:1)
        if &filetype !=# 'gedoc'
            let thiswin = winnr()
            exe "norm! \<C-W>b"
            if winnr() > 1
                exe 'norm! ' . thiswin . '\<C-W>w'
                while 1
                    if &filetype ==# 'gedoc'
                        break
                    endif
                    exe "norm! \<C-W>w"
                    if thiswin == winnr()
                        break
                    endif
                endwhile
            endif
            if &filetype !=# 'gedoc'
                new
            endif
        endif
        return 'edit godoc://' . p  .  ' | call ge#doc#go_to_pos(' . pos . ')'
    catch /^go-explorer:/
        return 'echoerr v:errmsg'
    endtry
    return ''
endfunction

" update_highlight updates highlighted link.
function! s:update_highlight() abort
    " With :syntax sync fromstart and :setlocal foldmethod=syntax, the last
    " command in the following sequence is very slow:
    "    :edit godoc://net/http
    "    :edit junk
    "    :edit #
    " Switching to manual folding here fixes the problem.
    setlocal foldmethod=manual

    let link = s:link()
    if exists('w:highlight_link') && w:highlight_link == link
        return ''
    endif
    let w:highlight_link = link
    if exists('w:highlight_match') && w:highlight_match
        call matchdelete(w:highlight_match)
        let w:highlight_match = 0
    endif
    if len(link) == 0
        return ''
    endif
    let w:highlight_match = matchadd('Underlined', '\%' . link[0] / 10000 . 'l\%' . link[0] % 10000 . 'c.\{' . (link[1] - link[0]) . '\}')
    return ''
endfunction

" clear_highlight clears link highlighting.
function! s:clear_highlight() abort
    if exists('w:highlight_match') && w:highlight_match
        call matchdelete(w:highlight_match)
    endif
    let w:highlight_match = 0
    let w:highlight_link = []
    return ''
endfunction

" link returns the link under the cursor or []
function! s:link() abort
    let p = line('.') * 10000 + col('.')
    for t in b:links
        if p >= t[0]
            if p < t[1]
                return t
            endif
        else
            break
        endif
    endfor
    return []
endfunction

" go_to_pos moves cursor to location specified by pos. The pos argument is
" either a string specfiying an anchor or line * 10000 + column.
function ge#doc#go_to_pos(pos) abort
    let pos = a:pos
    if exists('b:anchors') && type(pos) == type('') 
        let pos = get(b:anchors, pos, 0)
    endif
    if pos == 0
        return
    endif
    exec pos / 10000
    exec 'normal! 0' . (pos % 10000 - 1) . 'l'
endfunction

let s:stack = []

function <SID>jump() abort
    let link = s:link()
    if len(link) == 0
        return ''
    endif

    if link[3] >= 0
        let pos = "'" . b:strings[link[3]] . "'"
    else
        let pos = -link[3]
    endif

    let file = b:strings[link[2]]

    if file ==# '' || match(file, '^godoc://') == 0
        call add(s:stack, [bufnr('%'), line('.'), col('.')])
    endif

    let cmd = 'call ge#doc#go_to_pos(' . pos . ')'
    if file !=# ''
        let cmd = 'edit ' . file . ' | ' . cmd
    endif
    return cmd
endfunction

function <SID>pop() abort
    if len(s:stack) == 0
        return ''
    endif
    let p = s:stack[-1]
    let s:stack = s:stack[:-2]
    exec p[0] . 'b'
    exec p[1]
    exec 'normal! 0' . (p[2] - 1) . 'l'
    return ''
endfunction

function! <SID>toggle_all() abort
    let b:gedoc_showall = !b:gedoc_showall
    edit
endfunction

function <SID>next_section(dir) abort
    call search('\C\v^[^ \t)}]', 'W' . a:dir)
    return ''
endfunction

function ge#doc#foldtext() abort
    let line = getline(v:foldstart)
    let m = matchlist(line, '\C\v^(var|const) ')
    if len(m)
        " show sorted list of constants and variables
        let start=10000 * v:foldstart
        let end = 10000 * v:foldend+1
        let ids = []
        for [id, pos] in items(b:anchors)
            if pos >= start && pos < end
                call add(ids, id)
            endif
        endfor
        sort(ids)
        return m[1] . ' ' . join(ids) . ' '
    endif
    if line[-2:] ==# ' {'
        " chop { following a struct or interface
        let line = line[:-3]
    endif
    return line . ' '
endfunction

" vim:ts=4:sw=4:et
