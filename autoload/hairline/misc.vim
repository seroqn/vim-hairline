if exists('s:save_cpo')| finish| endif
let s:save_cpo = &cpo| set cpo&vim
scriptencoding utf-8
"=============================================================================
function! hairline#misc#_reload_stl() abort "{{{
  if !has_key(g:hairline, 'statusline') || get(g:hairline.statusline, 'disable', 0)
    set stl=
    return
  endif
  if !(has_key(g:hairline.statusline, 'left') && has_key(g:hairline.statusline, 'right'))
    let g:hairline.statusline.left = g:hairline#default.statusline.left
    let g:hairline.statusline.right = g:hairline#default.statusline.right
    let g:hairline.statusline.left_NC = g:hairline#default.statusline.left_NC
    let g:hairline.statusline.right_NC = g:hairline#default.statusline.right_NC
    let g:hairline.part = has_key(g:hairline, 'part') ? g:hairline.part : g:hairline#default.part
    let g:hairline.part_func = has_key(g:hairline, 'part_func') ? g:hairline.part_func : g:hairline#default.part_func
    let g:hairline.highlight = has_key(g:hairline, 'highlight') ? g:hairline.highlight : g:hairline#default.highlight
  endif
  aug HairLine
    au WinEnter,BufEnter * setl stl=%!HairLine_stl()
    au WinLeave,BufLeave * if &l:stl == '%!HairLine_stl()' | setl stl=%!HairLine_stl_NC() | endif
  aug END
  let [i, last] = [1, winnr('$')]
  while i <= last
    call setwinvar(i, '&stl', '%!HairLine_stl_NC()')
    let i += 1
  endwhile
  setl stl=%!HairLine_stl()
endfunc
"}}}
function! hairline#misc#_reload_tal() abort "{{{
  if has_key(g:hairline, 'tabline') && !get(g:hairline.tabline, 'disable', 0)
    let g:hairline.tabline.left = has_key(g:hairline.tabline, 'left') ? g:hairline.tabline.left : g:hairline#tabline.left
    let g:hairline.tabline.right = has_key(g:hairline.tabline, 'right') ? g:hairline.tabline.right : g:hairline#tabline.right
    let g:hairline.tabline.get_label = has_key(g:hairline.tabline, 'get_label') ? g:hairline.tabline.get_label : g:hairline#tabline.get_label
    set tabline=%!HairLine_tal()
  else
    set tabline=
  endif
endfunc
"}}}

"=============================================================================
"END "{{{1
let &cpo = s:save_cpo| unlet s:save_cpo
