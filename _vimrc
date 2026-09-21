if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

" netrwのデフォルト表示形式の変更
" let g:netrw_liststyle=0　（thin形式の場合）
" let g:netrw_liststyle=1　（long形式の場合）
" let g:netrw_liststyle=2　（wide形式の場合）
" let g:netrw_liststyle=3　（tree形式の場合）
let g:netrw_liststyle=3

" 不可視文字の表示
set list

" :TOhtmlコマンドでxhtmlを吐く
let use_xhtml=1

" カーソルが何行目の何列目に置かれているかを表示
set ruler
" タブの空白幅を半角2個分にする
set tabstop=2
" >>によるインデントのタブ幅を2にする
set shiftwidth=2
" タブをスペースに展開しない
set noexpandtab
" tmuxによるvimの色の変化を防ぐ
set termguicolors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
" end

" EXモードで補完リストの表示
set wildmenu

" 行番号の追加
set number 
" 現在のディレクトリ下全てをfind出来るようにする
set path+=**
" vimでmouse操作の追加(https://yskwkzhr.blogspot.jp/2013/02/use-mouse-on-terminal-vim.html)
set mouse=a
set ttymouse=xterm2
" Escape changes for normal mode in terminal mode
"tnoremap <Esc> <C-W>N
"au BufWinEnter * if &buftype == 'terminal' | setlocal bufhidden=hide | endif

" introduction in https://itchyny.hatenablog.com/entry/2014/12/25/090000
" change a key mapping in normal mode
nnoremap Y y$
vnoremap y "*y

" matchした括弧のhilight表示の時間を変更をする
" begin
set showmatch
" set matchtime=1
" end

" https://www.tweeeety.blog/entry/2014/12/17/222935
set encoding=utf-8
set fileencodings=utf-8,sjis,iso-2022-jp,euc-jp
set fileformats=unix,dos,mac

" vimのステータスラインを設定
" %F: ファイル名
" %r: ReadOnlyの場合には表示
" %h: helpページの場合には表示
" %w: Preview windowsの場合に表示
" %=: ここより右側は右揃え
" %{(&fenc!=''?&fenc:&enc)}: fileencodingが設定されている場合には、fileencodingを表示、そうでない場合にはvimのデフォルトであるencodingを表示
" &ff: 改行コードが、unix(LF), dos(CRLF), mac(CR)かを表示。
" %04B: 文字コードを4桁で16進数により表示
" %02v: カーソルが何列目にあるか表示
" %L: ファイルの全行を表示
set statusline=%F%r%h%w%=[ENC=%{(&fenc!=''?&fenc:&enc)}][FMT=%{&ff}][CODE=%04B][COL=%02v][TOTALLINE=%L]
set laststatus=2

" start tab settings(https://qiita.com/wadako111/items/755e753677dd72d8036d)
" Anywhere SID.
function! s:SID_PREFIX()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_\zeSID_PREFIX$')
endfunction

" Set tabline.
function! s:my_tabline()  "{{{
	let s = ''
	for i in range(1, tabpagenr('$'))
		let bufnrs = tabpagebuflist(i)
		let bufnr = bufnrs[tabpagewinnr(i) - 1]  " first window, first appears
		let no = i  " display 0-origin tabpagenr.
		let mod = getbufvar(bufnr, '&modified') ? '!' : ' '
		let title = fnamemodify(bufname(bufnr), ':t')
		let title = '[' . title . ']'
		let s .= '%'.i.'T'
		let s .= '%#' . (i == tabpagenr() ? 'TabLineSel' : 'TabLine') . '#'
		let s .= no . ':' . title
		let s .= mod
		let s .= '%#TabLineFill# '
	endfor
	let s .= '%#TabLineFill#%T%=%#TabLine#'
	return s
endfunction "}}}
let &tabline = '%!'. s:SID_PREFIX() . 'my_tabline()'
set showtabline=2 " 常にタブラインを表示
"end tab setting

" vimを閉じても、uで履歴を戻せる
set undofile
" undofileを置く場所をカレントディレクトリから変更する
set undodir=~/.vim/undo,.

if &compatible
	"vi互換の動作をやめる
	set nocompatible               " Be iMproved
endif

function! PackInit() abort
	packadd minpac

	call minpac#init()
	" call minpac#add('k-takata/minpac', {'type': 'opt', 'branch': 'v3.0.0'})

	" Add other plugins here
	call minpac#add('vim-scripts/DrawIt')
	call minpac#add('junegunn/vim-easy-align')
	call minpac#add('tpope/vim-commentary')
	call minpac#add('tpope/vim-surround')
	call minpac#add('tpope/vim-repeat')
	call minpac#add('kana/vim-textobj-user')
	call minpac#add('kana/vim-textobj-entire')

	" colorscheme
	call minpac#add('tpope/vim-vividchalk')

	" 非同期補完プラグイン
	" call minpac#add('prabirshrestha/asyncomplete.vim')
	" 非同期補完プラグインのLSP連携
	" call minpac#add('prabirshrestha/asyncomplete-lsp.vim')
	" LSPクライアント
	call minpac#add('prabirshrestha/vim-lsp')
	" Language Serverのインストール
	call minpac#add('mattn/vim-lsp-settings')
endfunction

" Define user commands for updating/cleaning the plugins.
" " Each of them loads minpac, reloads .vimrc to register the
" " information of plugins, then performs the task.
command! PackUpdate call PackInit() | source $MYVIMRC | call minpac#update()
command! PackClean  call PackInit() | source $MYVIMRC | call minpac#clean()
command! PackStatus packadd minpac | call minpac#status()

" TODO: PackUpdateCloseにlsp server名の引数を与えることでインストールできるようにする
command! PackUpdateClose call PackInit() | source $MYVIMRC | call minpac#update('', {'do': 'quitall'})

setlocal omnifunc=lsp#complete
setlocal signcolumn=yes

" vim-lspの設定
let g:lsp_diagnostics_echo_cursor = 0
let g:lsp_diagnostics_float_cursor = 1

" Required:
filetype plugin indent on
syntax enable

" vividchalkのcolorschemeが存在しない場合はスキップ
try
  colorscheme vividchalk
catch /^Vim\%((\a\+)\)\=:E185/
  colorscheme ron
endtry

