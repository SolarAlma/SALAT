; docformat = 'rst'

;+
; Calculates the shifts relative to the new reference
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
;    var : 
;   
;   
;   
;    pos : 
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
;   2013-07-24 : MGL. Use red_show rather than show. Changed dimension
;                check from dim1[0] to dim1[2] when deciding whether
;                to call align.
;
;   2014-01-14 : PS Code cleanup, move image display to calling routine
;-
function red_getcoords, var, pos
                                
  dim1 = size(var, /dimension)
  ref = reform(var[*, *, pos])

  IF n_elements(dim1) EQ 2 THEN $
    offs = dblarr(2) $
  ELSE $
    offs = dblarr(2, dim1[2])
  
  FOR l = 0, n_elements(offs)/2-1 DO BEGIN  
      IF l EQ pos THEN CONTINUE
      offs[*, l] = red_shc(ref, var[*, *, l], /filt, /int)
  ENDFOR
  
  return, offs
  
END
