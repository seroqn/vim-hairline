if exists('s:save_cpo')| finish| endif
let s:save_cpo = &cpo| set cpo&vim
scriptencoding utf-8
"=============================================================================
function! hairline#misc#_reload_stl() abort "{{{
  if !has_key(g:hairline, 'statusline') || get(g:hairline.statusline, 'disable', 0)
    set stl=
    return
  end
  let g:hairline.statusline.left = has_key(g:hairline.statusline, 'left') ? g:hairline.statusline.left : g:hairline#statusline.left
  let g:hairline.statusline.right = has_key(g:hairline.statusline, 'right') ? g:hairline.statusline.right : g:hairline#statusline.right
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
  end
endfunc
"}}}

"=============================================================================
"END "{{{1
let &cpo = s:save_cpo| unlet s:save_cpo
