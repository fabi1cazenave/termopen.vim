TermOpen.vim
================================================================================

Easy integration of TUI apps in Neovim: [Ranger][1], [LF][2], [Tig][3]…

  [1]: https://ranger.github.io/
  [2]: https://github.com/gokcehan/lf
  [3]: https://github.com/jonas/tig

Basic Usage
--------------------------------------------------------------------------------

Neovim natively comes with a neat `:term` command to open a terminal.
*termopen.vim* enhances such terminal windows with a few details:

* by default, opens a terminal window in a split rather than overriding the current window
* closes the terminal window if it exits without any error (i.e. no more `[Process exited 0]` message)
* hides unnecessary UI elements in terminal windows: line numbers, gutter, etc.

The `TermOpen` function makes it easy to run a TUI application in such a terminal:

```vim
" TermOpen([command], [window], [callback])
"   command  : command to execute (default = &shell)
"   window   : [s]plit (default)
"              [m]aximized split
"              [v]ertical split
"              [t]ab
"   callback : function to call when done (default = close window)

" open a shell in a new split (= default behavior)
nmap <C-Return> :call TermOpen()<CR>

" open a python shell in a new split
nmap <Leader>p :call TermOpen('python')<CR>

" open Tig in a new tab
nmap <Leader>g :call TermOpen('tig', 't')<CR>

" my favorite: https://github.com/samtay/tetris
nmap <Leader>T :call TermOpen('tetris', 'm')<CR>
```

File Managers
--------------------------------------------------------------------------------

`TermOpen`’s optional `callback` argument makes it easy to use a terminal file manager such as [Ranger][1] or [LF][2] as a file selector. That’s what the `TermOpenRanger` function does (26 SLOC only).

```vim
" TermOpenRanger([command], [window])
"   command  : command to execute (default = 'ranger')
"   window   : [s]plit
"              [m]aximized split (default)
"              [v]ertical split
"              [t]ab

" open Ranger a maximized split and edit the selected file(s)
nmap <Leader>r :call TermOpenRanger()<CR>

" alternative: use LF instead (much shorter startup time)
nmap <Leader>f :call TermOpenRanger('lf')<CR>
```

Settings
--------------------------------------------------------------------------------

### Auto-Insert

By default, this plugin switches to insert / terminal mode when a terminal window is focused. This can be disabled with the following:

```vim
let g:termopen_autoinsert = 0
```

### Keyboard Mappings

By default, <kbd>Ctrl</kbd>-<kbd>Return</kbd> opens a new terminal window and all <kbd>Ctrl</kbd>-<kbd>w</kbd> shortcuts work in terminal mode.

If [suckless.vim][4] is installed and `g:suckless_tmap` is set to 1, all *suckless.vim* <kbd>Alt</kbd>-* shortcuts are used in terminal mode instead of the default <kbd>Ctrl</kbd>-<kbd>w</kbd> shortcuts.

  [4]: https://github.com/fabi1cazenave/suckless.vim

All shortcuts can be disabled with the following:

```vim
let g:termopen_mappings = 0
```

Nothing else is pre-defined: if you want to use [Ranger][1], [LF][2], [Tig][3] or any other app, you’ll have to define your own mappings in your `~/.vimrc` or `~/.config/nvim/init.vim` file.

Partial Vim Support
--------------------------------------------------------------------------------

Vim 8 comes with a limited `:terminal` support:

* there’s no way to automatically close a terminal when it’s done: you’ll have to close the window manually;
* it does not support callbacks yet: if you pass a callback to `TermOpen`, it will run the command synchronously in fullscreen before starting the callback. This requires Vim to run in a terminal emulator: gVim is not supported.

Vim 7 has no `:terminal` support at all. All commands passed to `TermOpen` will run synchronously in fullscreen mode — again, this requires a terminal emulator.
