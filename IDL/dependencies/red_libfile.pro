; docformat = 'rst'

;+
; 
; 
; :Categories:
;
;    CRISP pipeline
; 
; 
; :Author:
; 
; 
; 
; 
; :Returns:
;    path to an .so library
; 
; :Params:
; 
;   
; 
; :Keywords:
; 
; 
; :History:
;
;   2013-12-09 : initial version
;
;   2017-05-04 : MGL. Look only in !path, not in !dlm_path.
;
;   2017-09-16 : THI. Use rdx_cache to avoid multiple searches in the same session.
;
;-
function red_libfile, libname

  libfile = rdx_cacheget( 'libfile:'+libname, count=cnt )
  if cnt gt 0 && file_test(libfile) then return, libfile

  libfile = file_search(strsplit(!PATH, ':', /extr), libname, count = count)
  if(count gt 1) then begin
    print, 'red_libfile : WARNING, you have multiple '+libname+' files in your path!'
    for ii=0, count-1 do print, '  -> '+libfile[ii]
    print,'red_libfile : using the first one!'
  endif
  
  if count eq 0 then begin
    message, 'Could not locate library file '+libname+'; Exiting'
    return,''
  endif
  
  rdx_cache, 'libfile:'+libname, libfile[0]
  
  return, libfile[0]

END
