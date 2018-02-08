execute pathogen#infect()
Helptags

" An example for a vimrc file.
"
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last change:	2008 Mar 19
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"	      for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"	    for OpenVMS:  sys$login:.vimrc

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" If for nothing more than keeping the undo history
set hidden

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set nobackup		" do not keep a backup file
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
set mouse=a

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  "Add detection of Pro*C which is very similar to ESQL-C
  autocmd BufNewFile,BufRead *.pc set filetype=esqlc

  " I'll do my own perl file headers, thanks
  let g:Perl_InsertFileHeader='no'

  " LaTeX-suite stuff
  " REQUIRED. This makes vim invoke Latex-Suite when you open a tex file.
  filetype plugin on

  " IMPORTANT: win32 users will need to have 'shellslash' set so that latex
  " can be called correctly.
  set shellslash

  " IMPORTANT: grep will sometimes skip displaying the file name if you
  " search in a singe file. This will confuse Latex-Suite. Set your grep
  " program to always generate a file-name.
  set grepprg=grep\ -nH\ $*

  " OPTIONAL: This enables automatic indentation as you type.
  filetype indent on

  " OPTIONAL: Starting with Vim 7, the filetype of empty .tex files defaults to
  " 'plaintex' instead of 'tex', which results in vim-latex not being loaded.
  " The following changes the default filetype back to 'tex':
  let g:tex_flavor='latex'
  " End LaTeX-suite stuff

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  " This is how I like my indenting done
  autocmd FileType perl setlocal tabstop=3 shiftwidth=3 expandtab
  autocmd FileType python setlocal tabstop=3 shiftwidth=3 expandtab
  autocmd FileType c setlocal tabstop=3 shiftwidth=3 expandtab
  autocmd FileType cpp setlocal tabstop=3 shiftwidth=3 expandtab autoindent
  autocmd FileType esqlc setlocal tabstop=3 shiftwidth=3 expandtab

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
                  \ | wincmd p | diffthis
endif

" Strip any trailing whitespace from all lines
" Mapped to F5
function! <SID>StripTrailingWhitespaces()
   " Preparation: save last search, and cursor position.
   let _s=@/
   let l = line(".")
   let c = col(".")
   " Do the business:
   %s/\s\+$//e
   " Clean up: restore previous search history, and cursor position
   let @/=_s
   call cursor(l, c)
endfunction
nnoremap <silent> <F5> :call <SID>StripTrailingWhitespaces()<CR>

" Search using * and # on a visual selection
function! s:VSetSearch(cmdtype)
  let temp = @s
  norm! gv"sy
  let @/ = '\V' . substitute(escape(@s, a:cmdtype.'\'), '\n', '\\n', 'g')
  let @s = temp
endfunction

xnoremap <kMultiply> :<C-u>call <SID>VSetSearch('/')<CR>/<C-R>=@/<CR><CR>
xnoremap * :<C-u>call <SID>VSetSearch('/')<CR>/<C-R>=@/<CR><CR>
xnoremap # :<C-u>call <SID>VSetSearch('?')<CR>?<C-R>=@/<CR><CR>

" recursively vimgrep for word under cursor or selection if you hit leader-star
nmap <leader>* :execute 'noautocmd vimgrep /\V' . substitute(escape(expand("<cword>"), '\'), '\n', '\\n', 'g') . '/ **'<CR>
vmap <leader>* :<C-u>call <SID>VSetSearch('/')<CR>:execute 'noautocmd vimgrep /' . @/ . '/ **'<CR>
nmap <leader><kMultiply> :execute 'noautocmd vimgrep /\V' . substitute(escape(expand("<cword>"), '\'), '\n', '\\n', 'g') . '/ **'<CR>
vmap <leader><kMultiply> :<C-u>call <SID>VSetSearch('/')<CR>:execute 'noautocmd vimgrep /' . @/ . '/ **'<CR>

"Mute highlight search on Ctrl-l and then do the usual Ctrl-l redraw
nnoremap <silent> <C-l> :<C-u>nohlsearch<CR><C-l>

set listchars=tab:▸\ ,eol:¬

