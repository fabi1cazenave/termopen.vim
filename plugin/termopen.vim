"|
"| File    : ~/.vim/plugin/termopen.vim
"| File    : ~/.config/nvim/plugin/termopen.vim
"| Author  : Fabien Cazenave
"| Source  : https://github.com/fabi1cazenave/termopen.vim
"| Licence : MIT
"|

autocmd! bufwritepost terminal.vim source %

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
function! s:noop()
endfunction

function! TermOpen(...)
  let cmd  = a:0 >= 1 ? a:1 : ''
  let type = a:0 >= 2 ? a:2 : 's'
  let Func = a:0 >= 3 ? a:3 : function('s:noop')

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

  elseif has('terminal')  " Vim 8.0 or greater {{{
    " Vim has no 'termopen' equivalent, sadly. No callbacks.
    " And Vim cannot close the terminal buffer on its own.
    " https://github.com/vim/vim/issues/1870
    if a:0 >= 3
      " callbacks are not supported: run a synchronous shell command instead
      silent exec '!' . cmd
      call Func()
      redraw!
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
        call term_sendkeys(bufnr("%"), cmd . "\<CR>")
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

let s:termopen_mappings = exists('g:termopen_mappings') && g:termopen_mappings

" true if suckless.vim Alt+* shortcuts are in use
let s:suckless_mappings = exists('g:suckless_mappings')
      \ && has_key(g:suckless_mappings, 'windows')
      \ && get(g:suckless_mappings.windows, 'meta', 0)

" window management
if has('nvim') && s:suckless_mappings " {{{

  " enter the terminal in insert mode
  autocmd BufEnter term://* startinsert

  " Alt+[sdf]: select tiling mode
  tmap <M-s> <C-\><C-n><M-s>
  tmap <M-d> <C-\><C-n><M-d>
  tmap <M-f> <C-\><C-n><M-f>

  " Alt+[hjkl]: select window
  tmap <M-h> <C-\><C-n><M-h>
  tmap <M-j> <C-\><C-n><M-j>
  tmap <M-k> <C-\><C-n><M-k>
  tmap <M-l> <C-\><C-n><M-l>

  " Shift+Alt+[hjkl]: move current window
  tmap <M-H> <C-\><C-n><M-H>
  tmap <M-J> <C-\><C-n><M-J>
  tmap <M-K> <C-\><C-n><M-K>
  tmap <M-L> <C-\><C-n><M-L>

  " Ctrl+Alt+[hjkl]: resize current window
  tmap <C-M-h> <C-\><C-n><C-M-h>i
  tmap <C-M-j> <C-\><C-n><C-M-j>i
  tmap <C-M-k> <C-\><C-n><C-M-k>i
  tmap <C-M-l> <C-\><C-n><C-M-l>i

  " Alt+[wc]: close/collapse current window
  tmap <M-w> <C-\><C-n><M-w>
  tmap <M-c> <C-\><C-n><M-c>

  " }}}
elseif !s:termopen_mappings " make <C-w> shortcuts work in terminal mode {{{

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
endif " }}}

" open a new terminal
if s:suckless_mappings
  " Alt+Return to start a new term (and to exit the term mode in neovim) {{{
  if g:MetaSendsEscape
    nnoremap <silent> <Esc><Return> :call TermOpen()<CR>
  else
    nnoremap <silent> <M-Return> :call TermOpen()<CR>
  endif
  if has('nvim') " exit terminal mode
    tnoremap <M-Return> <C-\><C-n>
  endif
  " }}}
elseif !s:termopen_mappings
  nnoremap <silent> <Leader>t :call TermOpen()<CR>
endif

" vim: set ft=vim fdm=marker fmr={{{,}}} fdl=0:
