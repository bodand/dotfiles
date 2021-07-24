set nocompatible
set belloff=all
set encoding=utf-8

if (empty(glob('~/.vim/autoload/plug.vim')))
    silent execute '!curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
    execute '!~/.vim/plugged/YouCompleteMe/install.py --clangd-completer'
endif

call plug#begin('~/.vim/plugged')
" Coloring "
Plug 'sheerun/vim-polyglot'
Plug 'ghifarit53/tokyonight-vim'
" CMake tooling "
Plug 'cdelledonne/vim-cmake'
" CSV "
Plug 'chrisbra/csv.vim'
" SWIG
Plug 'vim-scripts/SWIG-syntax'
" Gutter "
Plug 'airblade/vim-gitgutter'
" Airline "
Plug 'vim-airline/vim-airline'
" Auto Completion "
Plug 'ycm-core/YouCompleteMe'
" NERD Commenting "
Plug 'scrooloose/nerdcommenter'
" NERD Project Tree "
Plug 'scrooloose/nerdtree'
Plug 'jistr/vim-nerdtree-tabs'
" File icons "
Plug 'ryanoasis/vim-devicons'
" Manual rendering "
Plug 'now/vim-man'
call plug#end()

"" Indentation settings ""
set tabstop=4
set softtabstop=0
set expandtab 
set shiftwidth=4 
set smarttab
set number
autocmd FileType make set noexpandtab tabstop=2 shiftwidth=2

"" Theme settings ""
set termguicolors
" Windows Terminal is fucking retarded, because MS literally has to put at
" least one fuckup in everything
if has("gui_running")
    set guifont=BlexMono\ NF:h10
else
    set t_ut= | set ttyscroll=1
endif

colorscheme tokyonight

"" Keybindings ""
" Ctrl-S - Save
imap <C-s> <esc>:w<cr>a
nmap <C-s> :w<cr>

" Ctrl-D - Duplicate Line
imap <C-d> <esc>Vypa
nmap <C-d> Vyp

" Alt-C - Center File
imap <silent> <M-c> <esc>zza
nmap <silent> <M-c> zz

" Ctrl-Alt-L - Reformat File
imap <C-M-l> <esc>:norm gg=G<cr>a
nmap <C-M-l> :norm gg=G

" Ctrl-C / Ctrl-V - Copy paste in insert mode
imap <C-v> <esc>"+gPa
imap <C-c> <esc>"+y<cr>a
vmap <C-c> "+y

" Alt-<Arrows> tab switching
imap <silent> <M-Right> <esc>:tabnext<cr>a
nmap <silent> <M-Right> :tabnext<cr>
imap <silent> <M-Left> <esc>:tabprev<cr>a
nmap <silent> <M-Left> :tabprev<cr>

" Ctrl-Alt-<Arrows> buffer swap
imap <silent> <C-M-Up>    <esc>:wincmd k<cr>
imap <silent> <C-M-Down>  <esc>:wincmd j<cr>
imap <silent> <C-M-Left>  <esc>:wincmd h<cr>
imap <silent> <C-M-Right> <esc>:wincmd l<cr>

nmap <silent> <C-M-Up>    :wincmd k<cr>
nmap <silent> <C-M-Down>  :wincmd j<cr>
nmap <silent> <C-M-Left>  :wincmd h<cr>
nmap <silent> <C-M-Right> :wincmd l<cr>

" Ctrl-T open NERDTree in normal mode
nmap <silent> <C-t> :NERDTreeFocus<cr>

