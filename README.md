# neovim_config

## クリップボード (OSC 52)

WSL 以外の環境では、ヤンクした内容を OSC 52 で端末に送り、手元の端末 (Windows Terminal 等) のクリップボードへコピーします。ssh 先や docker の中でも動きます (`lua/options.lua`)。

### tmux 内で使う場合

tmux のデフォルト (`set-clipboard external`) では、nvim などペイン内のアプリが送った OSC 52 は無視されます。そのため、nvim でヤンクしても手元のクリップボードに届きません。tmux 自身のコピーモードでのコピーは届くので気付きにくいです。

nvim を起動するホストの `~/.tmux.conf` に次の設定を追加してください。

```tmux
set -g set-clipboard on
```

追加したら tmux に読み込ませ、nvim を起動し直します。

```sh
tmux source-file ~/.tmux.conf
```

それでも届かない場合は、外側の端末の `TERM` が `xterm*` 以外になっていないか確認してください。その場合は次の設定も必要です。

```tmux
set -as terminal-features ',*:clipboard'
```

### 貼り付けについて

Windows Terminal は OSC 52 の読み取りに対応していません。そのため `p` で貼り付けられるのは nvim 内で最後にヤンクした内容です。Windows 側でコピーした内容は、端末の Ctrl+V で貼り付けてください。
