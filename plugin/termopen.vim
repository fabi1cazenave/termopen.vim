"|
"| File    : ~/.vim/plugin/termopen.vim
"| File    : ~/.config/nvim/plugin/termopen.vim
"| Author  : Fabien Cazenave
"| Source  : https://github.com/fabi1cazenave/termopen.vim
"| Licence : MIT
"|

" autocmd! bufwritepost termopen.vim source %

"==============================================================================
" Exported Functions
"==============================================================================

" TermOpen: open a :term in a new window
" {{{ 3 optional arguments:
"   cmd   : command to execute (default = &shell)
"   type  : window type
"             [s]plit (default)
"             [m]aximized split
"             [v]ertical split
"             [t]ab
"   callback (default = close window)
function! TermOpen(...)
  function! NoOp()
  endfunction

  let cmd  = a:0 >= 1 ? a:1 : ''
  let type = a:0 >= 2 ? a:2 : 's'
  let Func = a:0 >= 3 ? a:3 : function('NoOp')

  if has('nvim') "{{{
    if type == 's'      " open term in a new [s]plit (default)
      wincmd n
    elseif type == 'm'  " open term in a new [m]aximized split
      wincmd n
      wincmd _
    elseif type == 'v'  " open term in a new [v]ertical split
      wincmd n
      wincmd L
    elseif type == 't'  " open term in a new [t]ab
      tabnew
    endif               " otherwise, open term in the current window

    " default callback = close the terminal window when done
    let callback = { 'type': type, 'ext_cb': Func }
    function callback.on_exit(job_id, code, event)
      if a:code == 0  " close the terminal window when done if no error
        silent! bd!
        call self.ext_cb()
      endif
    endfunction

    " hide unnecessary UI info and open a :term in insert mode
    setlocal nonumber norelativenumber signcolumn=no listchars=
    setlocal nocursorcolumn nocursorline
    call termopen(len(cmd) ? cmd : &shell, callback)
    startinsert
    "}}}

  else " partial Vim support {{{
    " Vim 7 has no 'terminal' at all: use a synchronous shell instead.
    " Vim 8 has a 'terminal' but: <https://github.com/vim/vim/issues/1870>
    "  - no callbacks: a synchronous shell command must be run instead;
    "  - Vim has no way to close the terminal buffer on its own.
    if a:0 >= 3 || !has('terminal') " synchronous shell command
      if !has('gui_running') " this hack requires a real term
        silent exec '!' . cmd
        call Func()
        redraw!
      endif
    else
      if type == 's'      " open term in a new [s]plit (default)
        terminal
      elseif type == 'm'  " open term in a new [m]aximized split
        terminal
        wincmd _
      elseif type == 'v'  " open term in a new [v]ertical split
        vert terminal
      elseif type == 't'  " open term in a new [t]ab
        tabnew            " (+ dirty hack to avoid a split...)
        terminal
        wincmd w
        bd
      endif
      setlocal nonumber norelativenumber signcolumn=no listchars=
      if len(cmd)
        call term_sendkeys(bufnr("%"), cmd . "&& exit\<CR>\<C-l>")
      endif
    endif
  endif "}}}

endfunction "}}}

" TermOpenRanger: browse files with Ranger or LF
" {{{ supported file managers:
"   https://github.com/ranger/ranger  -- Vim-inspired file manager (Python)
"   https://github.com/gokcehan/lf    -- super-fast Ranger alternative (Go)
let s:ranger_tmp = '/tmp/selectedfiles'

function! s:ranger_edit()
  if filereadable(s:ranger_tmp)
    let cwd = getcwd()
    for f in readfile(s:ranger_tmp)
      exec 'split ' . (f[0:len(cwd)-1] ==# cwd ? f[len(cwd)+1:-1] : f)
    endfor
    call delete(s:ranger_tmp)
  endif
endfunction

function! TermOpenRanger(...)
  let cmd  = a:0 >= 1 ? a:1 : 'ranger'    " default file browser
  let type = a:0 >= 2 ? a:2 : 'm'         " default mode: [m]aximized
  let path = a:0 >= 3 ? a:3 : expand("%") " default file path

  if path =~ "^term://" " in case TermOpenRanger is called from a term...
    let path = getcwd()
  endif
  if cmd == 'lf'
    let browse_cmd = 'lf -selection-path ' . s:ranger_tmp .
        \ ' "' . fnamemodify(path, ':h') . '"'
  else
    let browse_cmd = cmd . ' --choosefiles=' . s:ranger_tmp .
        \ (isdirectory(path) ? ' "' : ' --selectfile="') . path . '"'
  endif

  call TermOpen(browse_cmd, type, function('s:ranger_edit')) 
endfunction
" }}}

"==============================================================================
" Keyboard Mappings
"==============================================================================

if !exists('g:termopen_autoinsert') || g:termopen_autoinsert
  if has('nvim')
    autocmd BufEnter term://* startinsert
  elseif has('terminal') " startinsert doesn't work on Vim8 terminal windows
    autocmd BufWinEnter,WinEnter *
          \ if &buftype == 'terminal' | silent! normal i | endif
  endif
endif

if !exists('g:termopen_mappings') || g:termopen_mappings

  " Ctrl-Return to open a new term and to switch to normal mode
  nmap <silent> <C-Return> :call TermOpen()<CR>
  if has('nvim') || has('terminal')
    tnoremap <C-Return> <C-\><C-n>

    " Ctrl-W mappings in terminal / insert mode
    " (unless suckless.vim handles terminal windows) {{{
    if !exists('g:suckless_tmap') || !g:suckless_tmap

      " Ctrl+w [hjkl]: select window
      tnoremap <C-w>h <C-\><C-n><C-w>h
      tnoremap <C-w>j <C-\><C-n><C-w>j
      tnoremap <C-w>k <C-\><C-n><C-w>k
      tnoremap <C-w>l <C-\><C-n><C-w>l

      " Ctrl+w Ctrl+w: select previous window
      tnoremap <C-w>w <C-\><C-n><C-w>w
      tnoremap <C-w><C-w> <C-\><C-n><C-w>w

      " Ctrl+w [HJKL]: move current window
      tnoremap <C-w>H <C-\><C-n><C-w>H
      tnoremap <C-w>J <C-\><C-n><C-w>J
      tnoremap <C-w>K <C-\><C-n><C-w>K
      tnoremap <C-w>L <C-\><C-n><C-w>L

      " Ctrl+w c: close window
      tnoremap <C-w>c <C-\><C-n><C-w>c

    endif "}}}
  endif

endif

" vim: set ft=vim fdm=marker fmr={{{,}}} fdl=0:
