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
" set noexpandtab
set expandtab
" tmuxによるvimの色の変化を防ぐ
" set termguicolors
" let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
" let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
" end

" EXモードで補完リストの表示
set wildmenu

" 行番号の追加
set number 
" 現在のディレクトリ下全てをfind出来るようにする
set path+=**
" vimでmouse操作の追加(https://yskwkzhr.blogspot.jp/2013/02/use-mouse-on-terminal-vim.html)
set mouse=a
" for vim not nvim
" set ttymouse=xterm2

" Escape changes for normal mode in terminal mode
"tnoremap <Esc> <C-W>N
"au BufWinEnter * if &buftype == 'terminal' | setlocal bufhidden=hide | endif

" introduction in https://itchyny.hatenablog.com/entry/2014/12/25/090000
" change a key mapping in normal mode
" nnoremap Y y$

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
" neovimでは、デフォルトが`~/.local/share/nvim/undo`
" set undodir=~/.envim/undo,.

set swapfile
" neovimでは、デフォルトが`~/.local/share/nvim/swap`
" set directory=~/.envim/swapfiles

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

  " neovim用
	" call minpac#add('neovim/nvim-lspconfig')
	" call minpac#add('williamboman/nvim-lsp-installer')

	" markdown用
	call minpac#add('vim-denops/denops.vim')
	" call minpac#add('Shougo/ddu.vim')
	" call minpac#add('Shougo/ddu-ui-filer')
  " call minpac#add('Shougo/ddu-ui-ff')
  " call minpac#add('Shougo/ddu-kind-file')
  " call minpac#add('Shougo/ddu-filter-matcher_substring')
  " markdown preview
	call minpac#add('kat0h/bufpreview.vim')

  " vim用
	" 非同期補完プラグイン
	" call minpac#add('prabirshrestha/asyncomplete.vim')
	" 非同期補完プラグインのLSP連携
	" call minpac#add('prabirshrestha/asyncomplete-lsp.vim')
	" LSPクライアント
	" call minpac#add('prabirshrestha/vim-lsp')
	" Language Serverのインストール
	" call minpac#add('mattn/vim-lsp-settings')
	" Use release branch (recommend)

	call minpac#add('neoclide/coc.nvim', {'branch': 'release'})
	" Or build from source code by using yarn: https://yarnpkg.com
	" call minpac#add('neoclide/coc.nvim', {'branch': 'master', 'do': '!yarn install --frozen-lockfile'})
endfunction

" Define user commands for updating/cleaning the plugins.
" " Each of them loads minpac, reloads .vimrc to register the
" " information of plugins, then performs the task.
command! PackUpdate call PackInit() | source $MYVIMRC | call minpac#update()
command! PackClean call PackInit() | source $MYVIMRC | call minpac#clean()
command! PackStatus packadd minpac | call minpac#status()

" TODO: PackUpdateCloseにlsp server名の引数を与えることでインストールできるようにする
command! PackUpdateClose call PackInit() | source $MYVIMRC | call minpac#update('', {'do': 'quitall'})

" setlocal omnifunc=lsp#complete
" setlocal signcolumn=yes

" vim-lspの設定
" let g:lsp_diagnostics_echo_cursor = 0
" let g:lsp_diagnostics_float_cursor = 1

" Required:
filetype plugin indent on
syntax enable

" vividchalkのcolorschemeが存在しない場合はスキップ
try
	colorscheme vividchalk
catch /^Vim\%((\a\+)\)\=:E185/
	colorscheme ron
endtry

" if system('uname -a | grep microsoft') != ''
"   augroup myYank
"     autocmd!
"     autocmd TextYankPost * :call system('clip.exe', @")
"   augroup END
" endif"

if exists('$BUF_PREVIEW_BROWSER') && !empty($BUF_PREVIEW_BROWSER)
  let g:bufpreview_browser = $BUF_PREVIEW_BROWSER
elseif executable('/mnt/c/Program Files/Google/Chrome/Application/chrome.exe')
  let g:bufpreview_browser = '/mnt/c/Program Files/Google/Chrome/Application/chrome.exe'
endif

" lua require('lsp-settings')

" for neovim terminal
autocmd TermOpen * setlocal nonumber norelativenumber
autocmd TermOpen * startinsert

" coc setting

" Set internal encoding of vim, not needed on neovim, since coc.nvim using some
" unicode characters in the file autoload/float.vim
set encoding=utf-8

" TextEdit might fail if hidden is not set.
set hidden

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Give more space for displaying messages.
set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("nvim-0.5.0") || has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ CheckBackspace() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Run the Code Lens action on the current line.
nmap <leader>cl  <Plug>(coc-codelens-action)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocActionAsync('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>
