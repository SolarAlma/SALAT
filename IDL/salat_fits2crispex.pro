;+
; NAME: SALAT_FITS2CRISPEX
;		part of -- Solar Alma Library of Auxiliary Tools (SALAT) --
;
; PURPOSE: 
;	Create a CRISPEX cube from the ALMA fits cube (any level)
;	for quick inspections using the CRISPEX tool
;
; CALLING SEQUENCE:
;	salat_fits2crispex, cube, savedir=savedir, filename=filename
;
; + INPUTS:
; 	CUBE		The ALMA data cube in [x,y,t] format.
;			
; + OPTIONAL KEYWORDS:
; 	FITS		It should be set if the cube is a fits file (default = 0).
; 	SAVEDIR		A directory (as a string) in where the CRISPEX (.fcube) file is stored (default = './').
; 	FILENAME	Name of the CRISPEX cube, as a string (default = 'CRISPEX_cube').
;			
; + OUTPUTS:
;	The CRISPEX cube (.fcube) stored in the given location.
; 
; © Shahin Jafarzadeh (RoCS/SolarALMA)
;-
pro salat_fits2crispex, cube, savedir=savedir, filename=filename, fits=fits

if n_elements(savedir) eq 0 then savedir='./'
if n_elements(filename) eq 0 then filename='CRISPEX_cube'
if n_elements(fits) eq 0 then fits=0

if fits then imcube = readfits(cube,hdr) else imcube = cube

sz = size(imcube)
nx = sz(1)
ny = sz(2)
nt = sz(3)

print, '... data set of dimensions x,y: '+strtrim(nx,2)+', '+strtrim(ny,2)
print, '... and number of frames: '+strtrim(nt,2)

imfilename=savedir+filename+'.fcube'

header=make_lp_header(fltarr(nx,ny), nt=nt)
openw, luwr, imfilename, /get_lun
wc2=assoc(luwr, bytarr(512)) & wc2[0]=byte(header)
print, '...writing CRISPEX cube'
wc2=assoc(luwr, imcube, 512)
wc2[0]=imcube
free_lun, luwr

print, ' '
print, ' >>> .... writing cube: '+imfilename
print, ' '

end
