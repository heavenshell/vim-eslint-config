" File: eslint.vim
" Author: Shinya Ohyanagi <sohyanagi@gmail.com>
" Version: 0.1.0
" WebPage: http://github.com/heavenshell/vim-eslint-config
" Description: Vim plugin for ESLint
" License: BSD, see LICENSE for more details.
let s:save_cpo = &cpo
set cpo&vim

command! -nargs=* -buffer -complete=customlist,eslint#complete Eslint call eslint#setup(<q-args>, <count>, <line1>, <line2>)

command! -nargs=* -buffer -complete=customlist,eslint#complete EslintRun call eslint#run(<q-args>, <count>, <line1>, <line2>)

let &cpo = s:save_cpo
unlet s:save_cpo
