" ~/.config/nvim/init.vim - Neovim configuration

" Load standard vim configuration
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath

" Include vimrc settings
source ~/.vimrc

" ============================================
" Neovim Specific Settings
" ============================================
set mouse=a                   " Enable mouse in all modes

" ============================================
" Plugin Management (using vim-plug as example)
" ============================================
" Uncomment and configure if using vim-plug
" call plug#begin('~/.config/nvim/plugged')
" 
" " Your plugins here
" " Plug 'tpope/vim-sensible'
" " Plug 'preservim/nerdtree'
" 
" call plug#end()

" ============================================
" Neovim Terminal Settings
" ============================================
" Exit terminal mode with Escape
tnoremap <Esc> <C-\><C-n>
