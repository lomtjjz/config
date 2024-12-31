" Works best with Chalk terminal theme
" File layout adopted from: https://github.com/a-kr/myvim/blob/master/vim/colors/autumn.vim
" ---
" PLSPUTMEAT: $HOME/.vim/colors/chalk.vim
" PLSOWNME: chad
" PLSGRPME: chad
" PLSMODME: 444
" ---


set background=dark

hi clear
if exists("syntax_on")
	syntax reset
endif

hi Normal	ctermfg=NONE		ctermbg=NONE

hi IncSearch	ctermfg=NONE		ctermbg=YELLOW
hi Search	ctermfg=NONE		ctermbg=YELLOW

hi ErrorMsg	ctermfg=DARKRED		ctermbg=NONE
hi WarningMsg	ctermfg=YELLOW		ctermbg=NONE
hi ModeMsg	ctermfg=NONE		ctermbg=NONE
hi Question	ctermfg=NONE		ctermbg=NONE

hi StatusLine	ctermfg=NONE		ctermbg=NONE	cterm=bold
hi StatusLineNC	ctermfg=NONE		ctermbg=NONE	cterm=bold
hi VertSplit	ctermfg=DARKGREEN	ctermbg=NONE	cterm=bold
hi WildMenu	ctermfg=NONE		ctermbg=NONE


hi DiffText	ctermfg=NONE		ctermbg=NONE
hi DiffChange	ctermfg=YELLOW		ctermbg=NONE
hi DiffDelete	ctermfg=RED		ctermbg=NONE
hi DiffAdd	ctermfg=GREEN		ctermbg=NONE


hi Folded	ctermfg=DARKGREY	ctermbg=NONE	cterm=bold
hi FoldColumn	ctermfg=DARKGREY	ctermbg=NONE	cterm=bold

hi Directory	ctermfg=LIGHTBLUE	ctermbg=NONE
hi LineNr	ctermfg=DARKMAGENTA	ctermbg=NONE
hi NonText	ctermbg=NONE		ctermfg=BLUE	cterm=bold
hi SpecialKey	ctermfg=BLUE		ctermbg=NONE
hi Title	ctermfg=NONE		ctermbg=NONE
hi Visual	ctermfg=NONE		ctermbg=DARKGREY

hi Comment	ctermfg=DARKGREY	ctermbg=NONE
hi Constant	ctermfg=DARKGREEN	ctermbg=NONE
hi Error	ctermfg=NONE		ctermbg=MAGENTA
hi Identifier	ctermfg=NONE		ctermbg=NONE	cterm=none
hi PreProc	ctermfg=DARKMAGENTA	ctermbg=NONE
hi Special	ctermfg=CYAN		ctermbg=NONE
hi Statement	ctermfg=NONE		ctermbg=NONE
hi Todo		ctermfg=DARKYELLOW	ctermbg=NONE
hi Type		ctermfg=DARKBLUE	ctermbg=NONE
hi Underlined	ctermfg=NONE		ctermbg=NONE	cterm=underline

