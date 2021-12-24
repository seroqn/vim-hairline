if exists('s:save_cpo')| finish| endif
let s:save_cpo = &cpo| set cpo&vim
scriptencoding utf-8
"=============================================================================
let g:hairline#default = {}
function! g:hairline#default.highlight() abort "{{{
  hi HairLine_COMMON_plain  guifg=gray54 guibg=gray19 ctermfg=245 ctermbg=236

  hi link HairLine_NC_plain HairLine_COMMON_plain
  hi HairLine_NC_bufname    guifg=gray34 guibg=gray15 ctermfg=240 ctermbg=235
  hi HairLine_NC_percent    guifg=gray34 guibg=gray15 ctermfg=240 ctermbg=235
  hi HairLine_NC_lineinfo   guifg=gray15 guibg=gray38 ctermfg=235 ctermbg=241
  hi HairLine_n_mode        guifg=DarkGreen guibg=GreenYellow ctermfg=22 ctermbg=148 gui=bold term=bold cterm=bold
  hi HairLine_n_bufname     guifg=white guibg=gray35 ctermfg=231 ctermbg=240
  hi HairLine_n_percent     guifg=gray74 guibg=gray34 ctermfg=250 ctermbg=240
  hi HairLine_n_lineinfo    guifg=gray38 guibg=gray82 ctermfg=241 ctermbg=252
  hi HairLine_i_mode        guifg=SteelBlue4 guibg=white ctermfg=23 ctermbg=231 gui=bold term=bold cterm=bold
  hi HairLine_i_bufname     guifg=white guibg=DeepSkyBlue3 ctermfg=231 ctermbg=31
  hi HairLine_i_plain       guifg=SkyBlue guibg=DeepSkyBlue4 ctermfg=117 ctermbg=24
  hi HairLine_i_percent     guifg=SkyBlue guibg=SteelBlue ctermfg=117 ctermbg=31
  hi HairLine_i_percent     guifg=SkyBlue guibg=DeepSkyBlue3 ctermfg=117 ctermbg=31
  hi HairLine_i_lineinfo    guifg=SteelBlue guibg=SkyBlue ctermfg=23 ctermbg=117
  hi HairLine_v_mode        guifg=red4 guibg=DarkOrange ctermfg=88 ctermbg=208 gui=bold term=bold cterm=bold
  hi HairLine_v_bufname     guifg=white guibg=gray35 ctermfg=231 ctermbg=240
  hi HairLine_v_percent     guifg=gray74 guibg=gray34 ctermfg=250 ctermbg=240
  hi HairLine_v_lineinfo    guifg=gray38 guibg=gray82 ctermfg=241 ctermbg=252
endfunc
"}}}

let g:hairline#default.part = {'bufname': '%t', 'readonly': '%R', 'modified': '%M',
  \ 'filetype': '%{&ft !=# "" ? &ft : "no ft"}', 'fileformat': '%{&ff}',
  \ 'fileencordng': '%{&fenc!=#""?&fenc:&enc}', 'percent': '%3p%%', 'lineinfo': '%3l:%-2c'}

let g:hairline#default.part_func = {}
function! g:hairline#default.part_func.mode() abort "{{{
  return get({'n': 'NORMAL', 'i': 'INSERT', 'v': 'VISUAL', 'V': 'V-LINE', "\<C-v>": 'V-BLOCK', 't': 'TERMINAL'}, mode(), 'NORMAL')
endfunc
"}}}

let g:hairline#default.statusline = {}
let g:hairline#default.statusline.left = ['H:mode', 'f:mode', 'r:%R', 'H:bufname', 'bufname', 'modified']
let g:hairline#default.statusline.right = ['fileencordng', 'fileformat', 'filetype', 'H:percent', 'percent', 'H:lineinfo', 'lineinfo']
let g:hairline#default.statusline.left_NC = ['H:bufname', 'bufname', 'modified']
let g:hairline#default.statusline.right_NC = ['H:percent', 'percent', 'H:lineinfo', 'lineinfo']


let g:hairline#default.tabline = {}
let g:hairline#default.tabline.left = ['T:2']
let g:hairline#default.tabline.right = []
function! g:hairline#default.tabline.get_label(is_current, tn) abort "{{{
  let currbuf = bufname(tabpagebuflist(a:tn)[tabpagewinnr(a:tn)-1])
  return a:tn. ' '. (currbuf=='' ? '[No Name]' : fnamemodify(currbuf, ':t'))
endfunc
"}}}

"=============================================================================
"END "{{{1
let &cpo = s:save_cpo| unlet s:save_cpo
