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
;    var : 
;   
;   
;   
;    dx : 
;   
;   
;   
;    dy : 
;   
;   
;   
; 
; :Keywords:
; 
;    cubic  : 
;   
;   
;   
; 
; 
; :history:
; 
;   2013-06-04 : Split from monolithic version of crispred.pro.
; 
;   2014-01-13 : PS  Use (faster) Poly_2D
;-
function red_shift_im, var, dx, dy, cubic = cubic 
  if(n_elements(cubic) eq 0) then cubic = -0.5 
  
  p = [-dx, 0., 1., 0.] & q = [-dy, 1., 0., 0.]
  
  return, poly_2d(var, p, q, 2, cubic = cubic, missing = median(var))

end
