let s:last_req_id = 0

function! s:handle_symbols(req_id, error, response) abort
  if a:req_id != s:last_req_id
    return
  endif

  if a:error != v:null
    let l:results = []
  else
    let l:results = a:response
  endif

  let s:results = l:results
  let s:request_completed = v:true
endfunction

function! denite_coc_workspace_symbols#set_current_server() abort
  let s:servers = CocAction('services')
  let s:servers = filter(s:servers, 'v:val.state ==# "running"')
  let s:servers = filter(s:servers, 'index(v:val.languageIds, &filetype) >= 0')
endfunction

function! denite_coc_workspace_symbols#prepare_for_next_query() abort
  let s:request_completed = v:false
  let s:results = []
  let s:last_req_id = (s:last_req_id + 1) % 100000
endfunction

function! denite_coc_workspace_symbols#request_completed() abort
  return s:request_completed
endfunction

function! denite_coc_workspace_symbols#try_get_results() abort
  if s:request_completed
    return s:results
  else
    return v:null
  endif
endfunction

function! denite_coc_workspace_symbols#workspace_symbols(query) abort
  for l:server in s:servers
    call CocRequestAsync(
          \   l:server.id,
          \   'workspace/symbol',
          \   { 'query': a:query },
          \   funcref('s:handle_symbols', [s:last_req_id]),
          \ )
  endfor
endfunction
