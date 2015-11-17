if exists('g:loaded_ge')
  finish
endif
let g:loaded_ge = 1

augroup ge_doc
    autocmd!
    autocmd BufReadCmd  godoc://** execute ge#doc#read()
augroup END

command! -nargs=* -complete=customlist,ge#complete#complete_package_id GeDoc :execute ge#doc#open(<f-args>)

" vim:ts=4:sw=4:et
