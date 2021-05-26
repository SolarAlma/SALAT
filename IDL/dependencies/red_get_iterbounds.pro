; docformat = 'rst'

;+
; 
; 
; :Categories:
;
;    CRISP pipeline
; 
; 
; :author:
; 
; 
; 
; 
; :returns:
; 
; 
; :Params:
; 
;   tot : 
;   
;   
;   
;   np : 
;   
;   
;   
; 
; :Keywords:
; 
; 
; 
; :history:
; 
;   2013-06-04 : Split from monolithic version of crispred.pro.
; 
; 
;-
function red_get_iterbounds,tot,np
  maxi=double(tot) / double(np)
  maxit=fix(maxi)
  jot=fltarr(maxit+1)+np
  jot[maxit]=(maxi-maxit)*np
  if jot[maxit] eq 0 then jot=jot[0:maxit-1]
  return,jot
end
