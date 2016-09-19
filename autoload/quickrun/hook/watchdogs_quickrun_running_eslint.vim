let s:save_cpo = &cpo
set cpo&vim

let s:hook = {
\ "config" : {
\   "enable" : 0
\ },
\}

let s:eslint = {}

function! s:hook.init(...)
  if self.config.enable
    let s:eslint = eslint#init()
    let g:watchdogs_quickrun_running_check = 1
  endif
endfunction

function! s:hook.on_exit(...)
  let g:watchdogs_quickrun_running_check = 0
endfunction

function! quickrun#hook#watchdogs_quickrun_running_eslint#new()
  return deepcopy(s:hook)
endfunction

function! s:hook.on_module_loaded(session, context)
  let a:session['config']['command'] = s:eslint['bin']
  let a:session['config']['cmdopt'] = s:eslint['config']
  let a:session['config']['exec'] = ['%c %o %s']
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
