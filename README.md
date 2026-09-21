# dotfiles

Bash、tmux、Vim、Neovim の個人設定を管理するリポジトリです。

## 対応環境

主に Linux / WSL2 を想定しています。tmux のクリップボード連携は、利用可能なコマンドに応じて WSL2 (`clip.exe`)、macOS (`pbcopy`)、Linux/X11 (`xclip`) を自動判定します。

## ファイル構成

| リポジトリ内 | 配置先 | 用途 |
| --- | --- | --- |
| `_bashrc` | `~/.bashrc` | Bash |
| `_bash_env` | `~/.bash_env` | 対話シェル用の追加設定・tmux自動起動 |
| `_tmux.conf` | `~/.tmux.conf` | tmux |
| `_vimrc` | `~/.vimrc` | Vim |
| `_vimrc_min` | `~/.vimrc` | 最小構成のVim設定（任意） |
| `nvim/` | `~/.config/nvim/` | Neovim |

## インストール

通常構成:

```bash
git clone https://github.com/ai-daizu39/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash install.sh
```

Vim を最小構成にする場合:

```bash
bash install.sh --minimal-vim
```

既存の設定ファイルがある場合は、`~/.dotfiles-backup/<timestamp>.<random>/` 以下へ退避してからシンボリックリンクを作成します。バックアップ先は実行ごとに一意になるため、連続実行でも既存バックアップを上書きしません。

`install.sh` は Git が利用できる場合、minpac も未導入時のみ `v3.0.0` に固定して以下へインストールします。

- Vim: `~/.vim/pack/minpac/opt/minpac`
- Neovim: `${XDG_DATA_HOME:-~/.local/share}/nvim/site/pack/minpac/opt/minpac`

minpac の導入を行わない場合:

```bash
bash install.sh --skip-minpac
```

## Vim / Neovim プラグイン

Vim / Neovim を起動後、以下でプラグインを取得・更新できます。

```vim
:PackUpdate
```

不要になったプラグインは以下で整理できます。

```vim
:PackClean
```

Vim の既存プラグインは、従来指定していたバージョンタグを minpac の `rev` オプションで固定しています。`branch` は実在するブランチを追従する場合にのみ使用し、Neovim の `coc.nvim` は `release` ブランチを利用します。

## Neovim の Markdown preview

`bufpreview.vim` で利用するブラウザは、環境変数 `BUF_PREVIEW_BROWSER` で指定できます。

例:

```bash
export BUF_PREVIEW_BROWSER="/usr/bin/google-chrome"
```

WSL2 では Windows 版 Chrome の標準的なパスが存在する場合、自動的に利用します。

## tmux 自動起動

`_bash_env` は以下を満たす場合のみ tmux を自動起動します。

- tmux がインストール済み
- tmux の外側
- stdin / stdout が端末
- Bash が対話シェル

これにより、SSH の非対話コマンド、scp、rsync、自動処理などを tmux が横取りしないようにしています。

## 検証

GitHub Actions で以下を確認します。

- Bash の構文
- ShellCheck
- tmux 設定の読み込み
- Vim 設定の起動
- Neovim 設定の起動
- minpac の `PackInit()` によるプラグイン定義の読み込み
- 設定ファイルから抽出した固定 tag / branch がリモートに存在すること
- minpac 本体が `v3.0.0` で導入されること

ローカルでも最低限の構文確認ができます。

```bash
bash -n _bashrc _bash_env install.sh
tmux -L dotfiles-test -f "$PWD/_tmux.conf" new-session -d -s dotfiles-test
tmux -L dotfiles-test kill-server
vim -Nu "$PWD/_vimrc" -n -es +'qa!'
nvim --headless -u "$PWD/nvim/init.vim" +qa
```
