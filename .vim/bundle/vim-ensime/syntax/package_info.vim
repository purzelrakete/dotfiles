"" Syntax highlighting for ensime's package inspector

if exists("b:current_syntax")
    finish
endif

let b:current_syntax = "package_info"

syn keyword class Class
syn keyword obj Object
syn keyword trait Trait

hi def link class Type
hi def link obj Keyword
hi def link trait Comment
