" File: eslint.vim
" Author: Shinya Ohyanagi <sohyanagi@gmail.com>
" Version: 0.1.1
" WebPage: http://github.com/heavenshell/vim-eslint-config
" Description: Vim plugin for ESLint
" License: BSD, see LICENSE for more details.
let s:save_cpo = &cpo
set cpo&vim
if exists('g:eslint_loaded')
  finish
endif
let g:eslint_loaded = 1

if !exists('g:eslint_configs')
  let g:eslint_configs = []
endif

let s:eslint_config = ''

let s:eslint_complete = ['c']

let s:eslint = {}

function! s:detect_eslint_bin(srcpath) abort
  if executable('eslint') == 0
    let root_path = finddir('node_modules', a:srcpath . ';')
    let eslint = root_path . '/.bin/eslint'
  endif

  return eslint
endfunction

function! s:build_config(srcpath) abort
  let root_path = finddir('node_modules', a:srcpath . ';')
  if s:eslint_config == '' && len(g:eslint_configs) > 0
    for c in g:eslint_configs
      let path = printf('%s/%s', root_path, c)
      if isdirectory(path)
        let s:eslint_config = path
      else
        let s:eslint_config = findfile(c, a:srcpath . ';')
      endif
    endfor
  endif
  if s:eslint_config == ''
    let config_path = printf(' -f compact ')
  else
    let config_path = printf(' --config=%s -f compact ', s:eslint_config)
  endif
  return config_path
endfunction

" Build eslint bin path.
function! s:build_eslint(binpath, configpath, target) abort
  let cmd = a:binpath . a:configpath . '%'
  return cmd
endfunction

function! s:parse_options(args) abort
  if a:args =~ '-c\s'
    let args = split(a:args, '-c\s')
    if len(args) > 0
      let s:eslint_config = matchstr(args[0],'^\s*\zs.\{-}\ze\s*$')
    endif
  endif
endfunction

" Build eslint cmmand {name,value} complete.
function! eslint#complete(lead, cmd, pos) abort
  let cmd = split(a:cmd)
  let size = len(cmd)
  if size <= 1
    " Command line name completion.
    let args = map(copy(s:eslint_complete), '"-" . v:val . " "')
    return filter(args, 'v:val =~# "^".a:lead')
  endif
  " Command line value completion.
  let name = cmd[1]
  let filter_cmd = printf('v:val =~ "^%s"', a:lead)

  return filter(g:eslint_configs, filter_cmd)
endfunction

" Detect eslint bin and config file.
function! eslint#init() abort
  let eslint = s:detect_eslint_bin(expand('%:p'))
  let config = s:build_config(expand('%:p'))

  let s:eslint['bin'] = eslint
  let s:eslint['config'] = config

  return s:eslint
endfunction

" Setup eslint settings.
function! eslint#setup(...)
  call s:parse_options(a:000[0])
  let ret = eslint#init()
  let eslint = ret['bin']
  let config = ret['config']

  let eslint_path = s:build_eslint(eslint, config, expand('%:p'))
  let cmd = substitute(eslint_path, '\s', '\\ ', 'g')
  "let &makeprg did not work properly.
  execute 'set makeprg=' . cmd

  " Errorformat for `eslint -f compact`.
  let fmt =
    \ '%E%f: line %l\, col %c\, Error - %m,' .
    \ '%W%f: line %l\, col %c\, Warning - %m,' .
    \ '%-G%.%#'

  let &errorformat = fmt
endfunction

function! eslint#run(...) abort
  call eslint#setup(a:000[0])
  execute 'WatchdogsRun'
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
