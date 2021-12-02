if expand('<sfile>:p')!=#expand('%:p') && exists('g:loaded_hairline')| finish| endif| let g:loaded_hairline = 1
let s:save_cpo = &cpo| set cpo&vim
scriptencoding utf-8
"=============================================================================
command! -nargs=0   HairLineReload    call <SID>Reload()
let g:hairline = exists('g:hairline') ? g:hairline : {}

let s:enable_stl = has_key(g:hairline, 'statusline') && !get(g:hairline.statusline, 'disable', 0)
let s:enable_tal = has_key(g:hairline, 'tabline') && !get(g:hairline.tabline, 'disable', 0)

aug HairLine
  au!
  au ColorScheme *  call s:init_hl()
  if s:enable_stl
    let g:hairline.statusline.left = has_key(g:hairline.statusline, 'left') ? g:hairline.statusline.left : g:hairline#statusline.left
    let g:hairline.statusline.right = has_key(g:hairline.statusline, 'right') ? g:hairline.statusline.right : g:hairline#statusline.right
    au WinEnter,BufEnter * setl stl=%!HairLine_stl()
    au WinLeave,BufLeave * if &l:stl == '%!HairLine_stl()' | setl stl=%!HairLine_stl_NC() | endif
  end
aug END

if s:enable_tal
  let g:hairline.tabline.left = has_key(g:hairline.tabline, 'left') ? g:hairline.tabline.left : g:hairline#tabline.left
  let g:hairline.tabline.right = has_key(g:hairline.tabline, 'right') ? g:hairline.tabline.right : g:hairline#tabline.right
  let g:hairline.tabline.get_label = has_key(g:hairline.tabline, 'get_label') ? g:hairline.tabline.get_label : g:hairline#tabline.get_label
  set tabline=%!HairLine_tal()
end

function! HairLine_stl() abort "{{{
  let CONF = g:hairline.statusline
  let qm = get({'n': 'n', 'v': 'v', 'V': 'v', "\<C-v>": 'v', 's': 'v', 'S': 'v', "\<C-s>": 'v', 'i': 'i', 't': 't'}, mode(), 'n')
  let hlhead = '%#HairLine_'. qm. '_'
  let part = get(g:hairline, 'part', {})
  let part_func = get(g:hairline, 'part_func', {})
  let lexprs = s:layout_into_exprs(get(CONF, 'left_'. qm, CONF.left), part, part_func, hlhead)
  let rexprs = s:layout_into_exprs(get(CONF, 'right_'. qm, CONF.right), part, part_func, hlhead)
  let hlplain = hlhead. 'plain#'
  return join([hlplain] + lexprs + [hlplain, '%='] + rexprs, '')
endfunc
"}}}
function! HairLine_stl_NC() abort "{{{
  let CONF = get(g:hairline, 'statusline', {})
  if CONF=={}
    setl stl=
    return ''
  end
  let hlhead = '%#HairLine_NC_'
  let part = get(g:hairline, 'part', {})
  let part_func = get(g:hairline, 'part_func', {})
  let lexprs = s:layout_into_exprs(get(CONF, 'left_NC', CONF.left), part, part_func, hlhead)
  let rexprs = s:layout_into_exprs(get(CONF, 'right_NC', CONF.right), part, part_func, hlhead)
  let hlplain = hlhead. 'plain#'
  return join([hlplain] + lexprs + [hlplain, '%='] + rexprs, '')
endfunc
"}}}
function! HairLine_tal() abort "{{{
  let CONF = g:hairline.tabline
  let [crrtn, lasttn] = [tabpagenr(), tabpagenr('$')]
  let showall = lasttn <= 3
  let [i, last] = showall ? [1, lasttn] : crrtn==1 ? [1, 3] : crrtn==lasttn ? [crrtn-2, lasttn] : [crrtn-1, crrtn+1]
  let acc = showall || crrtn < 3 ? ['%', i, 'T%#HairLine_TAB_plain#'] : ['%', i, 'T%#HairLine_TAB_plain#..']
  while i <= last
    let is_current = i == crrtn
    let acc += [(is_current ? '%#HairLine_TAB_labelSel#' : '%#HairLine_TAB_label#'), '%', i, 'T %{g:hairline.tabline.get_label(', is_current, ',', i. ')} ', (is_current || i==last || i+1==crrtn ? '' : '|')]
    let i += 1
  endwhile
  let acc += showall || crrtn > lasttn-2 ? ['%T%#HairLine_TAB_plain#'] : ['%T%#HairLine_TAB_plain#..']
  let hlhead = '%#HairLine_TAB_'
  let part = get(g:hairline, 'part', {})
  let part_func = get(g:hairline, 'part_func', {})
  let lexprs = s:layout_into_exprs(CONF.left, part, part_func, hlhead, [crrtn, lasttn])
  let rexprs = s:layout_into_exprs(CONF.right, part, part_func, hlhead, [crrtn, lasttn])
  return join(acc + lexprs + ['%#HairLine_TAB_plain#%='] + rexprs, '')
endfunc
"}}}

function! s:Reload() abort "{{{
  call s:init_hl()
  aug HairLine
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
    let strip_lv = p =~# '^S\%(\|[frT]\):' ? 3 : p =~# '^L\%(\|[frT]\):' ? 2 : p =~# '^R\%(\|[frT]\):'
    let [L, R] = strip_lv==3 ? [[''], ['']] : strip_lv==2 ? [['%('], [' %)']] : strip_lv ? [['%( '], ['%)']] : [['%( '], [' %)']]
    if strip_lv
      let p = p =~# '^\a\a:' ? p[1:] : p[2:]
    end
    if p==''
      let acc += [' !EMPTY! '] | continue
    elseif p !~ '^\a:'
      let acc += L + [get(a:part, p, '??PART??')] + R | continue
    end
    let [c, body] = [p[0], p[2:]]
    if c==#'I'
      continue
    elseif c==#'f'
      let result = !has_key(a:part_func, body) ? '??FUNC??' : call(a:part_func[body], [], a:part_func)
      if !empty(result)
        let acc += L + [result] + R
      end
    elseif a:0 && c==#'T'
      let acc += L + (body=='1' ? ['(', a:1[1], ')'] : body=='2' ? ['(', a:1[0], '/', a:1[1], ')'] : ['???']) + R
    else
      let acc += c==#'r' ? L + [body] + R : c==#'H' ? [a:hlhead, body, '#'] : [' ??? ']
    end
  endfor
  return acc
endfunc
"}}}
function! s:init_hl() abort "{{{
  if has_key(g:hairline, 'highlight')
    call g:hairline.highlight()
  end
  hi default link HairLine_TAB_label    TabLine
  hi default link HairLine_TAB_labelSel TabLineSel
  hi default link HairLine_TAB_plain    TabLineFill
  hi default link HairLine_NC_plain     StatusLineNC
  hi default link HairLine_t_plain      StatusLineTerm
  hi default link HairLine_COMMON_plain StatusLine
  for bhl in get(g:hairline, 'common_hlnames', ['plain'])
    for m in ['NC', 'n', 'v', 'i', 't', 'TAB']
      exe 'hi default link HairLine_'. m. '_'. bhl 'HairLine_COMMON_'. bhl
    endfor
  endfor
endfunc
"}}}
if s:enable_stl || s:enable_tal
  call s:init_hl()
end

"=============================================================================
"END "{{{1
let &cpo = s:save_cpo| unlet s:save_cpo
