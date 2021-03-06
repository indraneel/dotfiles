" death to the swapfile
set noswapfile

" i want to use my mouse
set mouse=a

set t_Co=256		" 256 color terminal
set number		" line numbers
set softtabstop=4	" number of columns tabs count for 
set shiftwidth=4	" number of columns indented with << and >>
set backspace=2		" make backspce work like most other apps
set pastetoggle=<F2>	" allows text to be pasted with original alignment
set autoindent		" indents each line the same as the previous one
" set cindent		indents according to C indentation standard, should not be used with smartindent
set smartindent		" automatically inserts one extra level of indentation
set incsearch		" search as string is typed
set ignorecase		" ignore case on search
set shortmess=atI	" short messages and don't show intro
set showcmd		" shows normal mode key presses at bottom
set confirm		" dialog asking to confirm things instead of error
set wildmenu		" menu pops up for tab completion on commands 
set ruler		" show current position at bottm
set tabpagemax=20	" sets max # of tabs possible
filetype plugin indent on   " so I can use pathogen.vim
syntax on		" turn on syntax highlighting


"use ack instead of grep
set grepprg=ack

" Colors - {{
" Explanation of 256 colors and vim: http://www.frexx.de/xterm-256-notes/
" vim color names: http://vim.wikia.com/wiki/Xterm256_color_names_for_console_Vim
" thread that helped me choose the color for hi CursorLine: http://tech.groups.yahoo.com/group/vim/message/105727
" choosing colors: http://colorschemedesigner.com/
colo molokai 
" colo github 

" line highlighting
hi CursorLine cterm=None ctermbg=235 
set cursorline!
hi CursorColumn cterm=None ctermbg=235
set cursorcolumn!


" wildmenu colors
hi WildMenu cterm=None ctermbg=black ctermfg=2
hi StatusLine term=reverse ctermfg=0 ctermbg=white gui=bold,reverse 
" }}

" Key adjusts - {{
imap jj <Esc>	" detect down movement in insert mode
imap kk <Esc>	" detect up movement in insert mode

" make cursor move as expected with wrapped lines
inoremap <Down> <C-o>gj
inoremap <Up> <C-o>gk

"use Enter to insert new lines
map <CR> o<Esc>k

" use Space to add spaces in cmd mode
" map <Space> i<Space><Esc>
map <Space> :noh<CR>


nmap J }
nmap K {

nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k

" makes tab movement easier
nmap <C-n> :tabn<cr>
nmap <C-p> :tabp<cr>

" makes buffer movement easier
" nmap <C-S-h> :bp<cr>
" nmap <C-S-l> :bn<cr>


" }}

" Backups - {{
" must create these directories first!
set backup
set backupdir=~/.vim/backup
set directory=~/.vim/tmp
" }}

cmap w!! w !sudo tee >/dev/null %

" Tips - {{
" H M L - high middle low of current screen
" ^ - first non-blank character
" n% - go to n percent of file
" E, B, W - strict word definitions
" ctrl n - word completion
" >i{ indent block in 
" <i{ decrease indent
" :S
" f F - find occurrence
" t T - like f, except till one char before occurrence
" , - next occurrence of f, t
" ; - previous occurrence of f, t
" ctrl L - redraw screen
" }}

" ./vim/autoload/pathogen.vim
execute pathogen#infect()

" ALIASES
cnoreabbrev <expr> W ((getcmdtype() is# ':' && getcmdline() is# 'W')?('w'):('W'))


" FUNCTIONS
" show us when lines go over 80 characters in length.
function! ShowLongLines()
    try
        /\%>80v.\+
        match ErrorMsg '\%>80v.\+'
    catch E486
        call echo('All lines are within 80 characters.')
    endtry
endfunction

function MoveToPrevTab()
  "there is only one window
  if tabpagenr('$') == 1 && winnr('$') == 1
    return
  endif
  "preparing new window
  let l:tab_nr = tabpagenr('$')
  let l:cur_buf = bufnr('%')
  if tabpagenr() != 1
    close!
    if l:tab_nr == tabpagenr('$')
      tabprev
    endif
    sp
  else
    close!
    exe "0tabnew"
  endif
  "opening current buffer in new window
  exe "b".l:cur_buf
endfunc

function MoveToNextTab()
  "there is only one window
  if tabpagenr('$') == 1 && winnr('$') == 1
    return
  endif
  "preparing new window
  let l:tab_nr = tabpagenr('$')
  let l:cur_buf = bufnr('%')
  if tabpagenr() < tab_nr
    close!
    if l:tab_nr == tabpagenr('$')
      tabnext
    endif
    sp
  else
    close!
    tabnew
  endif
  "opening current buffer in new window
  exe "b".l:cur_buf
endfunc

