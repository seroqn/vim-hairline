if exists('s:save_cpo')| finish| endif
let s:save_cpo = &cpo| set cpo&vim
scriptencoding utf-8
"=============================================================================
let g:hairline#default#part_func = {}
function! g:hairline#default#part_func.mode() abort "{{{
  return get({'n': 'NORMAL', 'i': 'INSERT', 'v': 'VISUAL', 'V': 'V-LINE', "\<C-v>": 'V-BLOCK', 't': 'TERMINAL'}, mode(), 'NORMAL')
endfunc
"}}}

let g:hairline#default#statusline = {}
let g:hairline#default#statusline.left = []
let g:hairline#default#statusline.right = []


let g:hairline#default#tabline = {}
let g:hairline#default#tabline.left = ['T:2']
let g:hairline#default#tabline.right = []
function! g:hairline#default#tabline.get_label(is_current, tn) abort "{{{
  let currbuf = bufname(tabpagebuflist(a:tn)[tabpagewinnr(a:tn)-1])
  return a:tn. ' '. (currbuf=='' ? '[No Name]' : fnamemodify(currbuf, ':t'))
endfunc
"}}}

"=============================================================================
"END "{{{1
let &cpo = s:save_cpo| unlet s:save_cpo
