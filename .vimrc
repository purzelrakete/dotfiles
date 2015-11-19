" pathogen

call pathogen#infect()

" basics

let mapleader = " "

set encoding=utf-8
set history=1000
set nocompatible            " don't need vi compatibility
set backspace=indent,eol,start

" work with system clipboard

if has('mac')
  set clipboard=unnamed
elseif has('unix')
  set clipboard=unnamedplus
endif

" search and navigation

set ignorecase              " makes / searches case insensitive
set wildmenu                " bash-like cycling
set wildmode=list:longest
set wildignore=*.o,*.obj,.git,tags,*.class,*.gem,*.xsd,*.dtd,*.jarName,**/target/**
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
set term=screen-256color

" folds

set foldmethod=indent
set foldlevel=1
set foldnestmax=10
set nofoldenable

highlight Folded ctermfg=grey
highlight Folded ctermbg=NONE

map <Leader>f za<CR>

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

map <leader>a :Ag 
map <leader>b :b
map <leader>d :bd<CR>
map <leader>p :CtrlPCurWD<CR>
map <leader>j :CtrlPBuffer<CR>
map <leader>q :q<CR>
map <leader>s :w<CR>
map <leader>vv :source ~/.vimrc<CR>
map <leader>e  :Sex<CR>
map <leader>m  :!mou %<CR>

" interactive mode

imap <c-k> <esc>

" visual mode

vmap > >gv
vmap < <gv

" remove ctrlp binding. use leader instead

let g:ctrlp_map = '<c-&>'

" cycle through buffers

map <c-n> :bnext<cr>
map <c-p> :bprevious<cr>

" fix regular expressions

nmap / /\v
vmap / /\v

" copy current filename to clipboard

nmap <C-o> :!echo % \| pbcopy<cr><cr>

" stop that.

noremap  <Up> ""
noremap  <Down> ""
noremap  <Left> ""
noremap  <Right> ""

" reload testing screen

map <leader>u :!tmux send-keys -t 2 y<CR><CR>

" persist marks, registers history and buffer list across restarts

set viminfo='10,\"100,:20,%,n~/.viminfo

" restore cursor to saved position
"
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

" languages

filetype plugin indent on

" julia

au FileType julia setlocal shiftwidth=2
au FileType julia filetype plugin off

" go

au FileType go nmap <C-]> <Plug>(go-def-split)
au FileType go setlocal shiftwidth=2 tabstop=2 nolist noexpandtab

let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_fmt_command = "goimports"

" netrw. TODO can netrw be removed?

let g:netrw_quiet = 1

" solarized

syntax enable

let g:airline_left_sep = '⮀'
let g:airline_left_alt_sep = '⮁'
let g:airline_right_sep = '⮂'
let g:airline_right_alt_sep = '⮃'
let g:airline_right_alt_sep = '⮃'

if $VIM_THEME == "light"
  set background=light
else
  set background=dark
endif

colorscheme solarized

" completion

set completeopt-=preview

let g:neocomplete#enable_at_startup = 1
let g:neocomplete#enable_smart_case = 1
let g:neocomplete#sources#syntax#min_keyword_length = 3

" search

let g:ag_working_path_mode="r"

" highlight   Pmenu         ctermfg=0 ctermbg=2
" highlight   PmenuSel      ctermfg=0 ctermbg=7
" highlight   PmenuSbar     ctermfg=7 ctermbg=0
" highlight   PmenuThumb    ctermfg=1 ctermbg=7
