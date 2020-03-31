" Defaults for new vim users.
source $VIMRUNTIME/defaults.vim
" Ignore this filetypes in the wildmenu
set wildignore=*.o,*~,*.pyc,*.mod
" Make search case insensitive, but only as long as it contains only lowercase
set ignorecase
set smartcase
" Automatic indentation
set autoindent
set smartindent
set tabstop=4
set shiftwidth=4
set smarttab
set expandtab
" Fortran specific options
let fortran_do_enddo=1
let fortran_free_source=1
