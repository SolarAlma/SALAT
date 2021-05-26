; docformat = 'rst'

;+
; Rotate and shift an image using linear or cubic interpolation.
; 
; :Categories:
;
;    SST pipeline
; 
; 
; :Author:
; 
;    J. de la Cruz Rodriguez, Institute for Solar Physics
; 
; 
; :Returns:
;
;    Interpolated version of the input array
; 
; :Params:
; 
;    x : in, type=array
;
;       x-coordinates of the input 2D array.
;
;    y : in, type=array
;
;       y-coordinates of the input 2D array.
;
;    im : in, type=array
;
;      image/2D array to be interpolated.
; 
;    xx : in, type=array
;
;       x-coordinates of the output 2D array. It is a 2D array.
;
;    yy : in, type=array
;
;       y-coordinates of the output 2D array. It is a 2D array.
;
; 
; :Keywords:
;
;    nearest : in, optional, type=boolean
;   
;       Use nearest neighbor interpolation, takes precedence over using the
;       cubic keyword.
;   
;    nthreads: in, optional, type=int
;
;       Number of threads to use
;
;     missing: in, optional, type=scalar
;
;       Fill missing data values with this value (default = NaN)
;
; :History:
; 
;    2020-10-10 : JdlCR. First version.
; 
;-

function red_interpolate2D, x, y, im, xx, yy, nthreads = nthreads, nearest = nearest, missing = missing

  ;; Get dimensions of input and output arrays
  
  dim = size(im, /dim)
  nx  = long(dim[0])
  ny  = long(dim[1])
  
  dim = size(yy, /dim)
  nx1 = long(dim[0])
  ny1 = long(dim[1])


  ;; Allocate output array
  
  res = dblarr([nx1,ny1])

  if(n_elements(nthreads) eq 0) then nthreads=long(4) $
  else nthreads = max([long(nthreads),long(1)])


  ;; missing values?
  if(n_elements(missing) eq 0) then missing = !VALUES.f_nan
  
  
  ;; Call C++ interpolation routine
  
  libfile = red_libfile('creduc.so')

  
  if(keyword_set(nearest)) then begin
    
    dum = call_external(libfile, 'nearest2D_wrap', ny, nx, double(y), double(x), $
                        double(im), ny1, nx1, double(yy), double(xx), res, nthreads, double(missing))
    
  endif else begin

    dum = call_external(libfile, 'bilint2D_wrap', ny, nx, double(y), double(x), $
                        double(im), ny1, nx1, double(yy), double(xx), res, nthreads, double(missing))
  endelse  
  
  return, res
end
