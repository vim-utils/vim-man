" run the test with this command from project root dir:
" $ vim "+so test/manpage_extension_stripping_test.vim"
"
" Output is 'OK' if tests pass, otherwise failing test cases are displayed.
" Shell exit code is set to 0 if tests pass, 1 otherwise.

source autoload/man/helpers.vim

" test cases are split into sections:
"  1. simplest cases
"  2. various extensions (3pm, 1ssl, 3tcl etc)
"  3. harder cases (with numbers)
"  4. extensions without numbers
"  5. various zip extensions (xz, bz2, lzma)
let s:test_cases = [
      \ { 'in': 'bison.1',                           'out': 'bison' },
      \ { 'in': 'bison.1.gz',                        'out': 'bison' },
      \ { 'in': '[.1',                               'out': '[' },
      \ { 'in': '[.1.gz',                            'out': '[' },
      \ { 'in': 'c++.1',                             'out': 'c++' },
      \ { 'in': 'c++.1.gz',                          'out': 'c++' },
      \ { 'in': 'c99.1',                             'out': 'c99' },
      \ { 'in': 'c99.1.gz',                          'out': 'c99' },
      \ { 'in': 'X.7',                               'out': 'X' },
      \ { 'in': 'X.7.gz',                            'out': 'X' },
      \ { 'in': 'codesign_allocate.1',               'out': 'codesign_allocate' },
      \ { 'in': 'codesign_allocate.1.gz',            'out': 'codesign_allocate' },
      \ { 'in': 'llvm-cov.1',                        'out': 'llvm-cov' },
      \ { 'in': 'llvm-cov.1.gz',                     'out': 'llvm-cov' },
      \ { 'in': 'm4.1',                              'out': 'm4' },
      \ { 'in': 'm4.1.gz',                           'out': 'm4' },
      \ { 'in': 'arch.3',                            'out': 'arch' },
      \ { 'in': 'arch.3.gz',                         'out': 'arch' },
      \ { 'in': 'a.out.5',                           'out': 'a.out' },
      \ { 'in': 'a.out.5.gz',                        'out': 'a.out' },
      \ { 'in': 'RunTargetUnitTests.1',              'out': 'RunTargetUnitTests' },
      \ { 'in': 'RunTargetUnitTests.1.gz',           'out': 'RunTargetUnitTests' },
      \ { 'in': 'git-credential-cache--daemon.1',    'out': 'git-credential-cache--daemon' },
      \ { 'in': 'git-credential-cache--daemon.1.gz', 'out': 'git-credential-cache--daemon' },
      \ { 'in': 'xcb_dri2_connect.3',                'out': 'xcb_dri2_connect' },
      \ { 'in': 'xcb_dri2_connect.3.gz',             'out': 'xcb_dri2_connect' },
      \ { 'in': 'Magick++-config.1',                 'out': 'Magick++-config' },
      \ { 'in': 'Magick++-config.1.gz',              'out': 'Magick++-config' },
      \
      \ { 'in': 'Date::Format.3pm',        'out': 'Date::Format' },
      \ { 'in': 'Date::Format.3pm.gz',     'out': 'Date::Format' },
      \ { 'in': 'Date::Format5.16.3pm',    'out': 'Date::Format5.16' },
      \ { 'in': 'Date::Format5.16.3pm.gz', 'out': 'Date::Format5.16' },
      \ { 'in': 'ca.1ssl',                 'out': 'ca' },
      \ { 'in': 'ca.1ssl.gz',              'out': 'ca' },
      \ { 'in': 'CA.pl.1ssl',              'out': 'CA.pl' },
      \ { 'in': 'CA.pl.1ssl.gz',           'out': 'CA.pl' },
      \ { 'in': 'crl2pkcs7.1ssl',          'out': 'crl2pkcs7' },
      \ { 'in': 'crl2pkcs7.1ssl.gz',       'out': 'crl2pkcs7' },
      \ { 'in': 'TIFFClose.3tiff',         'out': 'TIFFClose' },
      \ { 'in': 'TIFFClose.3tiff.gz',      'out': 'TIFFClose' },
      \ { 'in': 'Tcl_Access.3tcl',         'out': 'Tcl_Access' },
      \ { 'in': 'Tcl_Access.3tcl.gz',      'out': 'Tcl_Access' },
      \ { 'in': 'errinfo.1m',              'out': 'errinfo' },
      \ { 'in': 'errinfo.1m.gz',           'out': 'errinfo' },
      \ { 'in': 'filebyproc.d.1m',         'out': 'filebyproc.d' },
      \ { 'in': 'filebyproc.d.1m.gz',      'out': 'filebyproc.d' },
      \ { 'in': 'CCCrypt.3cc',             'out': 'CCCrypt' },
      \ { 'in': 'CCCrypt.3cc.gz',          'out': 'CCCrypt' },
      \ { 'in': 'CC_SHA256_Final.3cc',     'out': 'CC_SHA256_Final' },
      \ { 'in': 'CC_SHA256_Final.3cc.gz',  'out': 'CC_SHA256_Final' },
      \ { 'in': 'PAIR_NUMBER.3x',          'out': 'PAIR_NUMBER' },
      \ { 'in': 'PAIR_NUMBER.3x.gz',       'out': 'PAIR_NUMBER' },
      \ { 'in': '_nc_freeall.3x',          'out': '_nc_freeall' },
      \ { 'in': '_nc_freeall.3x.gz',       'out': '_nc_freeall' },
      \ { 'in': 'pcap.3pcap',              'out': 'pcap' },
      \ { 'in': 'pcap.3pcap.gz',           'out': 'pcap' },
      \ { 'in': 'glColorMask.3G',          'out': 'glColorMask' },
      \ { 'in': 'glColorMask.3G.gz',       'out': 'glColorMask' },
      \ { 'in': 'glUniform1f.3G',          'out': 'glUniform1f' },
      \ { 'in': 'glUniform1f.3G.gz',       'out': 'glUniform1f' },
      \ { 'in': 'readline.3readline.gz',   'out': 'readline' },
      \ { 'in': 'alias.1p',                'out': 'alias' },
      \ { 'in': 'alias.1p.gz',             'out': 'alias' },
      \
      \ { 'in': 'aclocal-1.15.1',    'out': 'aclocal-1.15' },
      \ { 'in': 'aclocal-1.15.1.gz', 'out': 'aclocal-1.15' },
      \ { 'in': '2to3-2.7.1.gz',     'out': '2to3-2.7' },
      \ { 'in': 'c++-4.2.1',         'out': 'c++-4.2' },
      \ { 'in': 'g++.1.gz',          'out': 'g++' },
      \ { 'in': 'g++-4.6.1.gz',      'out': 'g++-4.6' },
      \
      \ { 'in': 'S3.n',                'out': 'S3' },
      \ { 'in': 'S3.n.gz',             'out': 'S3' },
      \ { 'in': 'TclX.n',              'out': 'TclX' },
      \ { 'in': 'TclX.n.gz',           'out': 'TclX' },
      \ { 'in': 'apply.ntcl',          'out': 'apply' },
      \ { 'in': 'apply.ntcl.gz',       'out': 'apply' },
      \ { 'in': 'base32.n',            'out': 'base32' },
      \ { 'in': 'base32.n.gz',         'out': 'base32' },
      \ { 'in': 'ttk::button.ntcl',    'out': 'ttk::button' },
      \ { 'in': 'ttk::button.ntcl.gz', 'out': 'ttk::button' },
      \
      \ { 'in': 'bison.1.z',       'out': 'bison' },
      \ { 'in': 'bison.1.Z',       'out': 'bison' },
      \ { 'in': 'bison.1.lz',      'out': 'bison' },
      \ { 'in': 'bison.1.xz',      'out': 'bison' },
      \ { 'in': 'bison.1.bz2',     'out': 'bison' },
      \ { 'in': 'bison.1.lzma',    'out': 'bison' },
      \ { 'in': '2to3-2.7.1.z',    'out': '2to3-2.7' },
      \ { 'in': '2to3-2.7.1.Z',    'out': '2to3-2.7' },
      \ { 'in': '2to3-2.7.1.lz',   'out': '2to3-2.7' },
      \ { 'in': '2to3-2.7.1.xz',   'out': '2to3-2.7' },
      \ { 'in': '2to3-2.7.1.bz2',  'out': '2to3-2.7' },
      \ { 'in': '2to3-2.7.1.lzma', 'out': '2to3-2.7' }
      \ ]

function! s:display_test_output(failing_cases)
  let output_string = ''
  for case in a:failing_cases
    let output_string .= 'In: '.case['in'].', out: '.case['out'].', result: '.case['got']."\n"
  endfor
  exec '!echo '.shellescape(output_string)
endfunction

function! s:exit(failing_cases)
  if empty(a:failing_cases)
    exec '!echo "OK"'
    qa!
  else
    call s:display_test_output(a:failing_cases)
    cq!
  endif
endfunction

function! s:run_test_cases()
  let failing_cases = []
  for case in s:test_cases
    let output = man#helpers#strip_extension(case.in)
    if output !=# case.out
      call add(failing_cases, {'in': case.in, 'out': case.out, 'got': output})
    endif
  endfor
  call s:exit(failing_cases)
endfunction

call s:run_test_cases()
