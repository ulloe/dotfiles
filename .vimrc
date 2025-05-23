" Disable compatibility with vi which can cause unexpected issues.
set nocompatible

" Enable type file detection. Vim will be able to try to detect the type of file in use.
filetype on

" Enable plugins and load plugin for the detected file type.
filetype plugin on

" Load an indent file for the detected file type.
filetype indent on

" Set shift width to 4 spaces.
set shiftwidth=4

" Set tab width to 4 columns.
set tabstop=4

" Use space characters instead of tabs.
set expandtab

" Do not save backup files.
" set nobackup

" Turn syntax highlighting on.
syntax on

" Add numbers to each line on the left-hand side.
set number relativenumber
highlight LineNr ctermfg=grey

" Highlight cursor line underneath the cursor horizontally.
 set cursorline
 highlight CursorLine cterm=NONE
 highlight CursorLineNr ctermfg=yellow cterm=NONE

" Highlight cursor line underneath the cursor vertically.
" set cursorcolumn

" Do not let cursor scroll below or above N number of lines when scrolling.
set scrolloff=10

" Do not wrap lines. Allow long lines to extend as far as the line goes.
set nowrap

" While searching though a file incrementally highlight matching characters as you type.
set incsearch

" Ignore capital letters during search.
set ignorecase

" Override the ignorecase option if searching for capital letters.
" This will allow you to search specifically for capital letters.
set smartcase

" Show partial command you type in the last line of the screen.
set showcmd

" Show the mode you are on the last line.
set showmode

" Show matching words during a search.
set showmatch

" Use highlighting when doing a search.
set hlsearch

" Set the commands to save in history default number is 20.
set history=1000

" Mark tabs.
set lcs=tab:>-
set list!

" Tabs Key Bindings
:map <silent> <F7> :tabp<CR>
:map <silent> <F8> :tabn<CR>
:map <silent> <c-t> :tabnew<CR>
:map <silent> <c-w> :hide<CR>

" Window/Split Key Bindings
" " Use ctrl-[hjkl] to select the active split!
nmap <silent> <c-k> :wincmd k<CR>
nmap <silent> <c-j> :wincmd j<CR>
nmap <silent> <c-h> :wincmd h<CR>
nmap <silent> <c-l> :wincmd l<CR>
