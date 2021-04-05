function salat_alma_fillgaps, cube, cadence, time, boxcar=boxcar, clip=clip, nofillgap=nofillgap, help=help
	
; (1) fill gaps in time-series data by linear interpolation
; (2) apply a temporal boxcar average

IF keyword_set(help) THEN BEGIN
  PRINT,' '
  PRINT,' Calling sequence:
  PRINT,' salat_alma_fillgaps, cube, cadence, time, boxcar=boxcar, clip=clip, nofillgap=nofillgap'
  PRINT,' '
  ; RETURN
ENDIF

if n_elements(boxcar) eq 0 then boxcar=0
if n_elements(nofillgap) eq 0 then nofillgap=0

nx = n_elements(cube[*,0,0])
ny = n_elements(cube[0,*,0])
nim = n_elements(cube[0,0,*])

if n_elements(clip) gt 0 then begin
	cube = cube[clip[0]:clip[1],clip[2]:clip[3],*]
	nx = n_elements(cube[*,0,0])
	ny = n_elements(cube[0,*,0])
endif

if boxcar gt 0 then begin
	scube = fltarr(nx,ny,nim)
	for ix=0L, nx-1 do for iy=0L, ny-1 do scube[ix,iy,*] = SMOOTH(reform(cube[ix,iy,*]), 10, /edge_truncate, /nan)
	cube = scube
endif

if nofillgap eq 0 then begin
	; interpolated the gaps ==> regularly spaced
	timesec0=time-time(0)
	nt1=nim
	ddt=float(cadence)
	ntt=fix(timesec0(nt1-1)/ddt)
	timenew=findgen(ntt)*ddt
	interpolatedcube=fltarr(nx,ny,ntt)
	for i=0,nx-1 do for j=0,ny-1 do interpolatedcube(i,j,*)=interpol(reform(cube(i,j,*)),timesec0,timenew)
endif else interpolatedcube = cube

return, interpolatedcube

end