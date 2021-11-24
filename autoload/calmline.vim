if exists('s:save_cpo')| finish| endif
let s:save_cpo = &cpo| set cpo&vim
scriptencoding utf-8
"=============================================================================
let g:calmline#statusline = {}
let g:calmline#statusline.left = []
let g:calmline#statusline.right = []


let g:calmline#tabline = {}
let g:calmline#tabline.left = ['T:2']
let g:calmline#tabline.right = []
function! g:calmline#tabline.get_label(is_current, tn) abort "{{{
  let currbuf = bufname(tabpagebuflist(a:tn)[tabpagewinnr(a:tn)-1])
  return a:tn. ' '. (currbuf=='' ? '[No Name]' : fnamemodify(currbuf, ':t'))
endfunc
"}}}

"=============================================================================
"END "{{{1
let &cpo = s:save_cpo| unlet s:save_cpo
