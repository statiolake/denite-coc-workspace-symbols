let s:results = []

function! s:handle_symbols(error, response) abort
  if a:error != v:null
    let l:results = []
  else
    let l:results = a:response
  endif

  " add received results to the global results
  call extend(s:results, l:results)
endfunction

function! denite_coc_workspace_symbols#set_current_server() abort
  let s:servers = CocAction('services')
  let s:servers = filter(s:servers, 'v:val.state ==# "running"')
  let s:servers = filter(s:servers, 'index(v:val.languageIds, &filetype) >= 0')
endfunction

function! denite_coc_workspace_symbols#try_get_results() abort
  if !empty(s:results)
    let l:results = s:results
    " clear the results
    let s:results = []
    return l:results
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
          \   funcref('s:handle_symbols'),
          \ )

    " It seems that some language servers (e.g. rust-analyzer) need a query to
    " be starting with '#', so populate results with that query.
    call CocRequestAsync(
          \   l:server.id,
          \   'workspace/symbol',
          \   { 'query': '#' . a:query },
          \   funcref('s:handle_symbols'),
          \ )
  endfor
endfunction
