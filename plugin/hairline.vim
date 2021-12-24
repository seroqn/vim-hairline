if expand('<sfile>:p')!=#expand('%:p') && exists('g:loaded_hairline')| finish| endif| let g:loaded_hairline = 1
let s:save_cpo = &cpo| set cpo&vim
scriptencoding utf-8
"=============================================================================
command! -nargs=0   HairlineReload    call <SID>Reload()
let g:hairline = exists('g:hairline') ? g:hairline : {}

let s:enable_stl = has_key(g:hairline, 'statusline') && !get(g:hairline.statusline, 'disable', 0)
let s:enable_tal = has_key(g:hairline, 'tabline') && !get(g:hairline.tabline, 'disable', 0)

if s:enable_stl && !(has_key(g:hairline.statusline, 'left') && has_key(g:hairline.statusline, 'right'))
  let g:hairline.statusline.left = g:hairline#default.statusline.left
  let g:hairline.statusline.right = g:hairline#default.statusline.right
  let g:hairline.statusline.left_NC = g:hairline#default.statusline.left_NC
  let g:hairline.statusline.right_NC = g:hairline#default.statusline.right_NC
  let g:hairline.part = has_key(g:hairline, 'part') ? g:hairline.part : g:hairline#default.part
  let g:hairline.part_func = has_key(g:hairline, 'part_func') ? g:hairline.part_func : g:hairline#default.part_func
  let g:hairline.highlight = has_key(g:hairline, 'highlight') ? g:hairline.highlight : g:hairline#default.highlight
endif

aug Hairline
  au!
  au ColorScheme *  call s:init_hl()
  if s:enable_stl
    au WinEnter,BufEnter * setl stl=%!Hairline_stl()
    au WinLeave,BufLeave * if &l:stl == '%!Hairline_stl()' | setl stl=%!Hairline_stl_NC() | endif
  endif
aug END

if s:enable_tal
  let g:hairline.tabline.left = has_key(g:hairline.tabline, 'left') ? g:hairline.tabline.left : g:hairline#default.tabline.left
  let g:hairline.tabline.right = has_key(g:hairline.tabline, 'right') ? g:hairline.tabline.right : g:hairline#default.tabline.right
  let g:hairline.tabline.get_label = has_key(g:hairline.tabline, 'get_label') ? g:hairline.tabline.get_label : g:hairline#default.tabline.get_label
  set tabline=%!Hairline_tal()
endif

function! Hairline_stl() abort "{{{
  let CONF = g:hairline.statusline
  let qm = get({'n': 'n', 'v': 'v', 'V': 'v', "\<C-v>": 'v', 's': 'v', 'S': 'v', "\<C-s>": 'v', 'i': 'i', 't': 't'}, mode(), 'n')
  let hlhead = '%#Hairline_'. qm. '_'
  let part = get(g:hairline, 'part', {})
  let part_func = get(g:hairline, 'part_func', {})
  let lexprs = s:layout_into_exprs(get(CONF, 'left_'. qm, CONF.left), part, part_func, hlhead)
  let rexprs = s:layout_into_exprs(get(CONF, 'right_'. qm, CONF.right), part, part_func, hlhead)
  let hlplain = hlhead. 'plain#'
  return join([hlplain] + lexprs + [hlplain, '%='] + rexprs, '')
endfunc
"}}}
function! Hairline_stl_NC() abort "{{{
  let CONF = get(g:hairline, 'statusline', {})
  if CONF=={}
    setl stl=
    return ''
  endif
  let hlhead = '%#Hairline_NC_'
  let part = get(g:hairline, 'part', {})
  let part_func = get(g:hairline, 'part_func', {})
  let lexprs = s:layout_into_exprs(get(CONF, 'left_NC', CONF.left), part, part_func, hlhead)
  let rexprs = s:layout_into_exprs(get(CONF, 'right_NC', CONF.right), part, part_func, hlhead)
  let hlplain = hlhead. 'plain#'
  return join([hlplain] + lexprs + [hlplain, '%='] + rexprs, '')
endfunc
"}}}
function! Hairline_tal() abort "{{{
  let CONF = g:hairline.tabline
  let [crrtn, lasttn] = [tabpagenr(), tabpagenr('$')]
  let showall = lasttn <= 3
  let [i, last] = showall ? [1, lasttn] : crrtn==1 ? [1, 3] : crrtn==lasttn ? [crrtn-2, lasttn] : [crrtn-1, crrtn+1]
  let acc = showall || crrtn < 3 ? ['%', i, 'T%#Hairline_TAB_plain#'] : ['%', i, 'T%#Hairline_TAB_plain#..']
  while i <= last
    let is_current = i == crrtn
    let acc += [(is_current ? '%#Hairline_TAB_labelSel#' : '%#Hairline_TAB_label#'), '%', i, 'T %{g:hairline.tabline.get_label(', is_current, ',', i. ')} ', (is_current || i==last || i+1==crrtn ? '' : '|')]
    let i += 1
  endwhile
  let acc += showall || crrtn > lasttn-2 ? ['%T%#Hairline_TAB_plain#'] : ['%T%#Hairline_TAB_plain#..']
  let hlhead = '%#Hairline_TAB_'
  let part = get(g:hairline, 'part', {})
  let part_func = get(g:hairline, 'part_func', {})
  let lexprs = s:layout_into_exprs(CONF.left, part, part_func, hlhead, [crrtn, lasttn])
  let rexprs = s:layout_into_exprs(CONF.right, part, part_func, hlhead, [crrtn, lasttn])
  return join(acc + lexprs + ['%#Hairline_TAB_plain#%='] + rexprs, '')
endfunc
"}}}

function! s:Reload() abort "{{{
  call s:init_hl()
  aug Hairline
    au!
    au ColorScheme *  call s:init_hl()
  aug END
  call hairline#misc#_reload_stl()
  call hairline#misc#_reload_tal()
endfunc
"}}}
function! s:layout_into_exprs(layout, part, part_func, hlhead, ...) abort "{{{ a:1=[crrtn, lasttn]
  let acc = []
  for p in a:layout
    let strip_lv = p =~# '^X\%(\|[frT]\):' ? 3 : p =~# '^L\%(\|[frT]\):' ? 2 : p =~# '^R\%(\|[frT]\):'
    let [L, R] = strip_lv==3 ? [[''], ['']] : strip_lv==2 ? [['%('], [' %)']] : strip_lv ? [['%( '], ['%)']] : [['%( '], [' %)']]
    if strip_lv
      let p = p =~# '^\a\a:' ? p[1:] : p[2:]
    endif
    if p==''
      let acc += [' !EMPTY! '] | continue
    elseif p !~ '^\a:'
      let acc += L + [get(a:part, p, '??PART??')] + R | continue
    endif
    let [c, body] = [p[0], p[2:]]
    if c==#'I'
      continue
    elseif c==#'f'
      let result = !has_key(a:part_func, body) ? '??FUNC??' : call(a:part_func[body], [], a:part_func)
      if !empty(result)
        let acc += L + [result] + R
      endif
    elseif a:0 && c==#'T'
      let acc += L + (body=='1' ? ['(', a:1[1], ')'] : body=='2' ? ['(', a:1[0], '/', a:1[1], ')'] : ['???']) + R
    else
      let acc += c==#'r' ? L + [body] + R : c==#'H' ? [a:hlhead, body, '#'] : [' ??? ']
    endif
  endfor
  return acc
endfunc
"}}}
function! s:init_hl() abort "{{{
  if has_key(g:hairline, 'highlight')
    call g:hairline.highlight()
  endif
  hi default link Hairline_TAB_label    TabLine
  hi default link Hairline_TAB_labelSel TabLineSel
  hi default link Hairline_TAB_plain    TabLineFill
  hi default link Hairline_NC_plain     StatusLineNC
  hi default link Hairline_t_plain      StatusLineTerm
  hi default link Hairline_COMMON_plain StatusLine
  for hl in get(g:hairline, 'common_hl_basenames', ['plain'])
    for m in ['NC', 'n', 'v', 'i', 't', 'TAB']
      exe 'hi default link Hairline_'. m. '_'. hl 'Hairline_COMMON_'. hl
    endfor
  endfor
endfunc
"}}}
if s:enable_stl || s:enable_tal
  call s:init_hl()
endif

"=============================================================================
"END "{{{1
let &cpo = s:save_cpo| unlet s:save_cpo
