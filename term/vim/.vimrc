" ---
" PLSPUTMEAT: $HOME/.vimrc
" PLSOWNME: chad
" PLSGRPME: chad
" PLSMODME: 444
" ---
call plug#begin()

Plug 'vimwiki/vimwiki'
Plug 'bfrg/vim-c-cpp-modern'

call plug#end()

let g:vimwiki_global_ext = 1

inoremap <kPagedown> ~
set ttimeoutlen=100
set nocompatible
filetype plugin on

set relativenumber
set autoindent
set number

syntax on
colorscheme chalk


nmap <Up>	<Nop>
nmap <Down>	<Nop>
nmap <Left>	<Nop>
nmap <Right>	<Nop>


function Execute()
	let l:CFLAGS=" -O3 -Wall -Wextra -Werror "
	let l:CCFLAGS=l:CFLAGS . "-std=c++20 "
	let l:TARGET=" " . shellescape(expand("%")) . " "

	:w
	if expand('%:e') ==? 'c'
		:exe "!gcc -o .tmp" l:CFLAGS  l:TARGET "&& echo" l:TARGET "&& ./.tmp"
	elseif expand('%:e') ==? 'cpp'
		:exe "!g++ -o .tmp" l:CCFLAGS l:TARGET "&& echo" l:TARGET "&& ./.tmp"
	elseif expand('%:e') ==? 'py'
		:exe "!echo " l:TARGET " && python " l:TARGET
	else
		:echomsg "Unknown file type '" expand("%") "'!"
	endif
endfunction

function Debug()
	let l:CCFLAGS=" -g -O3 -Wall -Wextra -Werror -std=c++20 "
	let l:TARGET=" " . shellescape(expand("%")) . " "

	:w
	if expand('%:e') ==? 'cpp'
		:exe "!g++ -o .tmp" l:CCFLAGS l:TARGET "&& gdb ./.tmp"
	else
		:echoerr "Unknown file type '" expand(%) "'!"
	endif
endfunction

nmap <c-k> :call Execute()<Return>
nmap <c-j> :call Debug()<Return>
