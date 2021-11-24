if expand('<sfile>:p')!=#expand('%:p') && exists('g:loaded_calmline')| finish| endif| let g:loaded_calmline = 1
let s:save_cpo = &cpo| set cpo&vim
scriptencoding utf-8
"=============================================================================
command! -nargs=0   CalmLineReload    call <SID>Reload()
let g:calmline = exists('g:calmline') ? g:calmline : {}

let s:enable_stl = has_key(g:calmline, 'statusline')
let s:enable_tal = has_key(g:calmline, 'tabline')

aug CalmLine
  au!
  au ColorScheme *  call s:init_hl()
  if s:enable_stl
    let g:calmline.statusline.left = has_key(g:calmline.statusline, 'left') ? g:calmline.statusline.left : g:calmline#statusline.left
    let g:calmline.statusline.right = has_key(g:calmline.statusline, 'right') ? g:calmline.statusline.right : g:calmline#statusline.right
    au WinEnter,BufEnter * setl stl=%!CalmLine_stl()
    au WinLeave,BufLeave * if &l:stl == '%!CalmLine_stl()' | setl stl=%!CalmLine_stl_NC() | endif
  end
aug END

if s:enable_tal
  let g:calmline.tabline.left = has_key(g:calmline.tabline, 'left') ? g:calmline.tabline.left : g:calmline#tabline.left
  let g:calmline.tabline.right = has_key(g:calmline.tabline, 'right') ? g:calmline.tabline.right : g:calmline#tabline.right
  let g:calmline.tabline.get_label = has_key(g:calmline.tabline, 'get_label') ? g:calmline.tabline.get_label : g:calmline#tabline.get_label
  set tabline=%!CalmLine_tal()
end

function! CalmLine_stl() abort "{{{
  let CONF = g:calmline.statusline
  let qm = get({'n': 'n', 'v': 'v', 'V': 'v', "\<C-v>": 'v', 's': 'v', 'S': 'v', "\<C-s>": 'v', 'i': 'i', 'c': 'c', 't': 't'}, mode(), 'n')
  let hlhead = '%#CalmLine_'. qm. '_'
  let part = get(g:calmline, 'part', {})
  let part_func = get(g:calmline, 'part_func', {})
  let lexprs = s:layout_into_exprs(CONF.left, part, part_func, hlhead)
  let rexprs = s:layout_into_exprs(CONF.right, part, part_func, hlhead)
  let hlplain = hlhead. 'plain#'
  return join([hlplain] + lexprs + [hlplain, '%='] + rexprs, '')
endfunc
"}}}
function! CalmLine_stl_NC() abort "{{{
  let CONF = g:calmline.statusline
  let hlhead = '%#CalmLine_NC_'
  let part = get(g:calmline, 'part', {})
  let part_func = get(g:calmline, 'part_func', {})
  let lexprs = s:layout_into_exprs(CONF.left, part, part_func, hlhead)
  let rexprs = s:layout_into_exprs(CONF.right, part, part_func, hlhead)
  let hlplain = hlhead. 'plain#'
  return join([hlplain] + lexprs + [hlplain, '%='] + rexprs, '')
endfunc
"}}}

function! CalmLine_tal() abort "{{{
  let CONF = g:calmline.tabline
  let [crrtn, lasttn] = [tabpagenr(), tabpagenr('$')]
  let showall = lasttn <= 3
  let [i, last] = showall ? [1, lasttn] : crrtn==1 ? [1, 3] : crrtn==lasttn ? [crrtn-2, lasttn] : [crrtn-1, crrtn+1]
  let acc = showall || crrtn < 3 ? ['%', i, 'T%#CalmLine_TAB_plain#'] : ['%', i, 'T%#CalmLine_TAB_plain#..']
  while i <= last
    let is_current = i == crrtn
    let acc += [(is_current ? '%#CalmLine_TAB_labelSel#' : '%#CalmLine_TAB_label#'), '%', i, 'T %{g:calmline.tabline.get_label(', is_current, ',', i. ')} ', (is_current || i==last || i+1==crrtn ? '' : '|')]
    let i += 1
  endwhile
  let acc += showall || crrtn > lasttn-2 ? ['%T%#CalmLine_TAB_plain#'] : ['%T%#CalmLine_TAB_plain#..']
  let hlhead = '%#CalmLine_TAB_'
  let part = get(g:calmline, 'part', {})
  let part_func = get(g:calmline, 'part_func', {})
  let lexprs = s:layout_into_exprs(CONF.left, part, part_func, hlhead, [crrtn, lasttn])
  let rexprs = s:layout_into_exprs(CONF.right, part, part_func, hlhead, [crrtn, lasttn])
  return join(acc + lexprs + ['%#CalmLine_TAB_plain#%='] + rexprs, '')
endfunc
"}}}

function! s:Reload() abort "{{{
  call s:init_hl()
  if has_key(g:calmline, 'statusline')
    let g:calmline.statusline.left = has_key(g:calmline.statusline, 'left') ? g:calmline.statusline.left : g:calmline#statusline.left
    let g:calmline.statusline.right = has_key(g:calmline.statusline, 'right') ? g:calmline.statusline.right : g:calmline#statusline.right
    au CalmLine WinEnter,BufEnter * setl stl=%!CalmLine_stl()
    au CalmLine WinLeave,BufLeave * if &l:stl == '%!CalmLine_stl()' | setl stl=%!CalmLine_stl_NC() | endif
  end
  if has_key(g:calmline, 'tabline')
    let g:calmline.tabline.left = has_key(g:calmline.tabline, 'left') ? g:calmline.tabline.left : g:calmline#tabline.left
    let g:calmline.tabline.right = has_key(g:calmline.tabline, 'right') ? g:calmline.tabline.right : g:calmline#tabline.right
    let g:calmline.tabline.get_label = has_key(g:calmline.tabline, 'get_label') ? g:calmline.tabline.get_label : g:calmline#tabline.get_label
    set tabline=%!CalmLine_tal()
  end
endfunc
"}}}
function! s:layout_into_exprs(layout, part, part_func, hlhead, ...) abort "{{{ a:1=[crrtn, lasttn]
  let acc = []
  for p in a:layout
    let lstrip = p =~# '^[LS]\%(\|[frT]\):'
    let rstrip = p =~# '^[RS]\%(\|[frT]\):'
    let L = lstrip ? ['%('] : ['%( ']
    let R = rstrip ? ['%)'] : [' %)']
    if lstrip || rstrip
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
  if has_key(g:calmline, 'highlight')
    call g:calmline.highlight()
  end
  hi default link CalmLine_TAB_label    TabLine
  hi default link CalmLine_TAB_labelSel TabLineSel
  hi default link CalmLine_TAB_plain    TabLineFill
  hi default link CalmLine_NC_plain StatusLineNC
  hi default link CalmLine_COMMON_plain StatusLine
  for bhl in get(g:calmline, 'common_hlnames', ['plain'])
    for m in ['NC', 'n', 'c', 'v', 'i', 't', 'TAB']
      exe 'hi default link CalmLine_'. m. '_'. bhl 'CalmLine_COMMON_'. bhl
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
