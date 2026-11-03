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

map <Leader>f za<CR>

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

map <leader>b :b
map <leader>d :bd<CR>
map <leader>p :Files<CR>
map <leader>f :Rg<CR>
map <leader>q :q<CR>
map <leader>s :w<CR>
map <leader>vv :source ~/.vimrc<CR>
map <leader>e  :Sex<CR>
map <leader>m  :!mou %<CR>

" search replace
highlight IncSearch ctermfg=White ctermbg=Black

" interactive mode

imap <c-k> <esc>

" visual mode

vmap > >gv
vmap < <gv

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

map <leader>u :!tmux send-keys -t 1 y Enter<CR><CR>

" persist marks, registers history and buffer list across restarts

if !has('nvim') | set viminfo='10,\"100,:20,%,n~/.viminfo | endif

" restore cursor to saved position

au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

" tags

set tags=tags,.tags

" lsp
nnoremap <silent> gd <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> gD <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> gr <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> gi <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> K <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> <C-k> <cmd>lua vim.lsp.buf.signature_help()<CR>

" julia

au FileType julia setlocal shiftwidth=2
au FileType julia filetype plugin off

" go

" vim-go's gd and <C-]> need guru, which no longer exists; gopls does it
let g:go_def_mapping_enabled = 0
au FileType go nnoremap <buffer> <C-]> <cmd>split \| lua vim.lsp.buf.definition()<CR>
au FileType go setlocal shiftwidth=2 tabstop=2 nolist noexpandtab

let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_fmt_command = "goimports"

" netrw

let g:netrw_quiet = 1

" all languages

filetype plugin indent on
au BufWritePre *.go GoFmt
au FileType go setlocal shiftwidth=2 tabstop=2 nolist noexpandtab
au FileType julia filetype plugin off
au FileType julia setlocal shiftwidth=2
nnoremap <leader>t :EnTypeCheck<CR>

" python

autocmd FileType python setlocal completeopt-=preview

" tags

set tags=.tags,tags

" solarized

syntax enable

" powerline arrows (U+E0B0-E0B3); iTerm draws them without a patched font
" when Profiles > Text > "Use built-in Powerline glyphs" is on
let g:airline_theme = 'solarized'
let g:airline_left_sep = "\ue0b0"
let g:airline_left_alt_sep = "\ue0b1"
let g:airline_right_sep = "\ue0b2"
let g:airline_right_alt_sep = "\ue0b3"

if $VIM_THEME == "light"
  set background=light
else
  set background=dark
endif

" vim-colors-solarized only sets cterm colors outside the GUI; nvim 0.10+
" turns on termguicolors in truecolor terminals, which would ignore them
if has('nvim') | set notermguicolors | endif

" nvim combines airline's highlights with StatusLine, inheriting solarized's
" reverse and swapping every section's fg/bg; re-applied on each reload
augroup solarized_statusline
  autocmd!
  autocmd ColorScheme solarized hi StatusLine cterm=NONE gui=NONE | hi StatusLineNC cterm=NONE gui=NONE
augroup END

colorscheme solarized

" spelling

autocmd BufRead,BufNewFile *.md setlocal spell
highlight SpellBad ctermfg=Red ctermbg=120 cterm=bold cterm=underline

" completion

set completeopt-=preview

" search

let g:ag_working_path_mode="r"

" remove annoying bottom bar in fzf
"
autocmd! FileType fzf
autocmd  FileType fzf set laststatus=0 | autocmd WinLeave <buffer> set laststatus=2

" soywiki

let g:soywiki_mapping_next_link = ''
let g:soywiki_mapping_previous_link = ''
let g:soywiki_mapping_follow_link_under_cursor_vertical = ''
