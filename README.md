TermOpen.vim
============

Easy integration of TUI apps in Neovim: [Ranger][1], [LF][2], [Tig][3]…

  [1]: https://ranger.github.io/
  [2]: https://github.com/gokcehan/lf
  [3]: https://github.com/jonas/tig

Basic Usage
-----------

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
nmap <Leader>t :call TermOpen()<CR>

" open a python shell in a new split
nmap <Leader>p :call TermOpen('python')<CR>

" open Tig in a new tab
nmap <Leader>g :call TermOpen('tig', 't')<CR>

" my favorite: https://github.com/samtay/tetris
nmap <Leader>T :call TermOpen('tetris', 'm')<CR>
```

File Managers
-------------

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

Keyboard Mappings
-----------------

By default, `<Leader>t` opens a new terminal window (unless `g:termopen_mappings` is set to 0).

If [suckless.vim][4] is installed with its <kbd>Alt</kbd> shortcuts enabled:

* <kbd>Alt</kbd>+<kbd>Return</kbd> is used instead;
* all terminals are open in insert mode, and <kbd>Alt</kbd>+<kbd>Return</kbd> exits the terminal mode;
* all other window management shortcuts (<kbd>Alt</kbd>+<kbd>h</kbd><kbd>j</kbd><kbd>k</kbd><kbd>l</kbd>, etc.) shortcuts work in terminal windows.

  [4]: https://github.com/fabi1cazenave/suckless.vim

Nothing else is pre-defined: if you want to use [Ranger][1], [LF][2], [Tig][3] or any other app, you’ll have to define your own mappings in your `~/.config/nvim/init.vim` file.

Experimental Vim 8 support
--------------------------

Vim 8 comes with a quite limited `:terminal` command. However it has a few caveats:

* there’s no way to automatically close a terminal when it’s done: you’ll have to close the window manually;
* it does not support [suckless.vim][4] window management shortcuts;
* it does not support callbacks yet: if you pass a callback to `TermOpen`, it will run the command synchronously in fullscreen before starting the callback.

A partial and hacky support has been implemented for Vim 8. Expect a few rough edges, but it should be usable for most cases.
