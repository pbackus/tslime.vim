" Tslime.vim. Send portion of buffer to tmux instance
" Maintainer: C.Coutinho <kikijump [at] gmail [dot] com>
" Licence:    DWTFYWTPL

if exists("g:loaded_tslime") && g:loaded_tslime
  finish
endif

let g:loaded_tslime = 1

" Main function.
" Use it in your script if you want to send text to a tmux session.
function! Send_to_Tmux(text)
  if !exists("g:tslime")
    call <SID>Tmux_Vars()
  endif

  call system("tmux load-buffer -b tslime -", a:text)
  call system("tmux paste-buffer -d -b tslime -t " . s:tmux_target())
endfunction

function! s:tmux_target()
  return '"' . g:tslime['session'] . '":' . g:tslime['window'] . "." . g:tslime['pane']
endfunction

" Session completion
function! Tmux_Session_Names(A,L,P)
  return <SID>TmuxSessions()
endfunction

" Window completion
function! Tmux_Window_Names(A,L,P)
  return <SID>TmuxWindows()
endfunction

" Pane completion
function! Tmux_Pane_Numbers(A,L,P)
  return <SID>TmuxPanes()
endfunction

function! s:ActiveTarget()
  return split(system('tmux list-panes -F "active=#{pane_active} #{session_name},#{window_index},#{pane_index}" | grep "active=1" | cut -d " " -f 2 | tr , "\n"'), '\n')
endfunction

function! s:TmuxSessions()
  if exists("g:tslime_always_current_session") && g:tslime_always_current_session
    let sessions = <SID>ActiveTarget()[0:0]
  else
    let sessions = split(system("tmux list-sessions -F '#{session_name}'"), '\n')
  endif
  return sessions
endfunction

function! s:TmuxWindows()
  if exists("g:tslime_always_current_window") && g:tslime_always_current_window
    let windows = <SID>ActiveTarget()[1:1]
  else
    let windows = split(system('tmux list-windows -F "#{window_index}" -t ' . g:tslime['session']), '\n')
  endif
  return windows
endfunction

function! s:TmuxPanes()
  let all_panes = split(system('tmux list-panes -t "' . g:tslime['session'] . '":' . g:tslime['window'] . " -F '#{pane_index}'"), '\n')

  " If we're in the active session & window, filter away current pane from
  " possibilities
  let active = <SID>ActiveTarget()
  let current = [g:tslime['session'], g:tslime['window']]
  if active[0:1] == current
    call filter(all_panes, 'v:val != ' . active[2])
  endif
  return all_panes
endfunction

" set tslime.vim variables
function! s:Tmux_Vars()
  let names = s:TmuxSessions()
  let g:tslime = {}
  if len(names) == 1
    let g:tslime['session'] = names[0]
  else
    let g:tslime['session'] = ''
  endif
  while g:tslime['session'] == ''
    let g:tslime['session'] = input("session name: ", "", "customlist,Tmux_Session_Names")
  endwhile

  let windows = s:TmuxWindows()
  if len(windows) == 1
    let window = windows[0]
  else
    let window = input("window name: ", "", "customlist,Tmux_Window_Names")
    if window == ''
      let window = windows[0]
    endif
  endif

  let g:tslime['window'] =  substitute(window, ":.*$" , '', 'g')

  let panes = s:TmuxPanes()
  if len(panes) == 1
    let g:tslime['pane'] = panes[0]
  else
    let g:tslime['pane'] = input("pane number: ", "", "customlist,Tmux_Pane_Numbers")
    if g:tslime['pane'] == ''
      let g:tslime['pane'] = panes[0]
    endif
  endif
endfunction

" Send text from a motion or text object
function! s:TslimeOperator(motion_type)
  let sel_save = &selection
  let &selection = "inclusive"
  let reg_save = @@

  if a:motion_type == 'line'
    silent execute "normal! '[V']y"
  elseif a:motion_type == 'char'
    silent execute "normal! `[v`]y"
  elseif a:motion_type == 'block'
    silent execute "normal! `[\<C-V>`]y"
  endif

  call Send_to_Tmux(@@)

  let &selection = sel_save
  let @@ = reg_save
endfunction

function! s:SendRange() range
  let lines = join(getline(a:firstline, a:lastline), "\n") . "\n"
  call Send_to_Tmux(lines)
endfunction

xnoremap <silent> <Plug>(TslimeSendSelection) "ry :call Send_to_Tmux(@r)<CR>
nnoremap <silent> <Plug>(TslimeOperator) :set operatorfunc=<SID>TslimeOperator<CR>g@
command! -range=% TslimeSend <line1>,<line2>call <SID>SendRange()
command! TslimeSetTarget call <SID>Tmux_Vars()
