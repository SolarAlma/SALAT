;+
; NAME: SALAT_SALSA_TO_CRISPEX
;       part of -- Solar Alma Library of Auxiliary Tools (SALAT) --
;
; PURPOSE: 
;   Create a CRISPEX cube from the ALMA fits cube (3D, 4D, or 5D)
;   for quick inspections using the CRISPEX tool
;   Note: the CRISPEX tool should be installed separately (https://github.com/grviss/crispex)
;
; CALLING SEQUENCE:
;   salat_salsa_to_crispex, cube, savedir=savedir
;
; + INPUTS:
;   CUBE        The SALSA level4 data cube in FITS format
;       
; + OPTIONAL KEYWORDS/INPUT PARAMETERS:
;   SAVEDIR     A directory (as a string) in where the CRISPEX (.fcube) file is stored (default = './')
;
; + OUTPUTS:
;   The CRISPEX cube (.fcube) stored in the given location (i.e., SAVEDIR), with the same name as the input CUBE.
;
; + RESTRICTIONS:
;   Currently for 3D [x,y,t] cubes only. 
;   It will later be extended for cubes with full spectra and/or Stokes parameters.
;
; EXAMPLE:
;   IDL> cube = './solaralma.b3.fba.2016-12-22.14_19_31-15_07_07.2016.1.00423.S.level4.k.fits'
;   IDL> salat_salsa_to_crispex, cube, savedir='~/'
;   IDL> crispex, '~/solaralma.b3.fba.2016-12-22.14_19_31-15_07_07.2016.1.00423.S.level4.k.fcube'
;
; MODIFICATION HISTORY:
;   Shahin Jafarzadeh (Rosseland Centre for Solar Physics, University of Oslo, Norway), July 2021
;-
pro salat_salsa_to_crispex, cube, savedir=savedir

if n_elements(savedir) eq 0 then savedir='./'

p1=strpos(cube, '.fits')
p0=strpos(cube, 'solaralma.', p1-1 , /reverse_search)
filename=strmid(cube, p0, p1-p0)

imcube = readfits(cube,hdr)

sz = size(imcube)
nx = sz(1)
ny = sz(2)
nt = sz(3)

print, '... data set of dimensions x,y: '+strtrim(nx,2)+','+strtrim(ny,2)
print, '... number of frames: '+strtrim(nt,2)

imfilename=savedir+filename+'.fcube'

header=make_lp_header(fltarr(nx,ny), nt=nt)
openw, luwr, imfilename, /get_lun
wc2=assoc(luwr, bytarr(512)) & wc2[0]=byte(header)
print, '.... writing CRISPEX cube: '+imfilename
wc2=assoc(luwr, imcube, 512)
wc2[0]=imcube
free_lun, luwr

print
print, ' ---------------------------------------------------'
print, ' -- Solar Alma Library of Auxiliary Tools (SALAT) --'
print, ' ---------------------------------------------------'
print

end