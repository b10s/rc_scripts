" магия, чтобы был карсивый статус лайн
set laststatus=2
set statusline=%F[%{strlen(&fenc)?&fenc:'none'},%{&ff}]%h%m%r%y%=%c,%l/%L\ %P

" табы как 4 пробела
set ts=4

" нумерация строк
set number

" автоматический отступ на новой строке
set autoindent

" директория текущего файла по %% в командном режиме
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'

" регистронезависимый поиск
set ignorecase

" умный регистрозависимый поиск: если есть символы верхнего регистра, значит
" зависим, если нет, то независим; помни про \c и \C в любом месте шаблона;
set smartcase

" избавимся на время от стрелок
noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>

" Color column on 81 position
if version > 703
	set colorcolumn=81
	highlight ColorColumn ctermbg=4
endif

" отключить подсвеченные найденные куски
noremap <silent> <C-l> :<C-u>nohlsearch<CR><C-l>

" инкрементальный поиск - подсвечивает сразу при вводе шаблона
set incsearch

" подсчитать количество совпадений
map <C-n> :%s///gn<CR>

" On pressing tab, insert 4 spaces
" use pathogen
execute pathogen#infect()
syntax on
" filetype plugin indent on

set tabstop=2
set shiftwidth=2
set expandtab

" tab autocompletion improvement
set wildmode=longest,list,full
set wildmenu
