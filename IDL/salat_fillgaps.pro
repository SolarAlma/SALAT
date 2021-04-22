;+
; NAME: SALAT_MAKE_MOVIE
;		part of -- Solar Alma Library of Auxiliary Tools (SALAT) --
;
; PURPOSE: 
;	Create ALMA cubes from individual files outputted by SoAP (put them together, remove bad frames 
;	and polish the cube), i.e., creates both pre-level4 (aka 'clean') and level4 cubes.
;
; CALLING SEQUENCE:
;	salat_make_alma_cube, files, savedir=savedir, filename=filename, date=date
;
; + INPUTS:
; 	CUBE 		The input (polished; level4) FITS cube.
;	CADENCE		Cadence of the observations (in seconds).
;	TIME		Observing time sequence (in seconds)
;
; + OPTIONAL KEYWORDS:
; 	BOXCAR		If set, a temporal boxcar average (of 10 frames) is applied.
; 	CLIP		A four elements array to clip the field of view: [x1,x2,y1,y2]
;	NOFILLGAP	If set, the fill gap option is disabled (e.g., for performing CLIP and/or BOXCAR)
;		
; + OUTPUTS:
;	A new cube, modified based on the options (default: filling gaps)
; 
; © Shahin Jafarzadeh (RoCS/SolarALMA)
;-
function salat_alma_fillgaps, cube, cadence, time, boxcar=boxcar, clip=clip, nofillgap=nofillgap
	
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