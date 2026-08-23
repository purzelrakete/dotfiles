" plugins
"
" bundles live in ~/.vim/bundle and are loaded by pathogen. without this nvim
" starts bare: no airline, fugitive, solarized, copilot.

set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath=&runtimepath
call pathogen#infect()

" basics

let mapleader = " "

set encoding=utf-8
set history=1000
set nocompatible            " don't need vi compatibility
set backspace=indent,eol,start

" search and navigation

set ignorecase              " makes / searches case insensitive
set wildmenu                " bash-like cycling
set wildmode=list:longest
set wildignore=*.o,*.obj,.git,tags,*.class,*.gem,*.xsd,*.dtd,*.jarName,**/target/**,node_modules
set incsearch

" safety

set undofile
set noswapfile
set nobackup                " no backup after closing
set nowritebackup           " no backup while working
set undodir=/tmp/.vim_undo

" ui

set title                   " show title of file in menu bar
set ruler
set number                  " numbers on the left
set relativenumber
set scrolloff=1             " breathing room for zt
set laststatus=2

" folds

set foldmethod=indent
set foldlevel=1
set foldnestmax=10
set nofoldenable

highlight Folded ctermfg=grey
highlight Folded ctermbg=NONE

" sign column to the left
set signcolumn=number

" column width

set textwidth=78
set colorcolumn=+1

" stripping

map <Leader>w :%s/\v\s+$//g<CR>
set list listchars=tab:..,trail:.

" indentation

set wrap
set formatoptions=qrn1
set autoindent              " always set autoindenting on
set shiftwidth=2            " number of spaces to use for autoindenting
set softtabstop=2
set tabstop=2
set expandtab

" global remappings

map <leader>d :bd<CR>
map <leader>q :q<CR>
map <leader>s :w<CR>

" search replace
highlight IncSearch ctermfg=White ctermbg=Black

" interactive mode

imap <c-k> <esc>

" visual mode

vmap > >gv
vmap < <gv

" cycle through buffers

map <c-n> :tabnext<cr>
map <c-p> :tabprevious<cr>

" fix regular expressions

nmap / /\v
vmap / /\v

" copy current filename to clipboard

nmap <C-o> :!echo % \| pbcopy<cr><cr>

" reload testing screen

map <leader>u :!tmux send-keys -t 2 y Enter<CR><CR>

" persist marks, registers history and buffer list across restarts

set viminfo='10,\"100,:20,%,n~/.viminfo

" tags

set tags=.tags,tags

" spelling

autocmd BufRead,BufNewFile *.md setlocal spell
highlight SpellBad ctermfg=Red ctermbg=120 cterm=bold cterm=underline
