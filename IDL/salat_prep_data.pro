;+
; NAME: SALAT_PREP_DATA
;       part of -- Solar Alma Library of Auxiliary Tools (SALAT) --
;
; PURPOSE: 
;   Take a standard SALSA level 4 cube and convert it such that it is accepted by external viewers, such as CARTA. 
;	This involves removal of empty dimensions or - if all 5 dimensions are in use - removing a dimension as selected 
;	by the user. Right now: Reduce dimensions.
;
; CALLING SEQUENCE:
;   salat_prep_data, cube, savedir=savedir
;
; + INPUTS:
;   CUBE        The SALSA level4 data cube in FITS format
;       
; + OPTIONAL KEYWORDS/INPUT PARAMETERS:
;   SAVEDIR     A directory (as a string) in where the new cube is stored (default = './')
;
; + OUTPUTS:
;   The new cube stored in the given location (i.e., SAVEDIR)
;	With the same name as the input CUBE, but with a '_modified-dimension' added.
;	All headers and extensions are passed to the new cube without any changes.
;
; + RESTRICTIONS:
;   It will later be extended for cubes with full spectra and/or Stokes parameters.
;
; EXAMPLE:
;   IDL> cube = './solaralma.b3.fba.2016-12-22.14_19_31-15_07_07.2016.1.00423.S.level4.k.fits'
;   IDL> salat_prep_data, cube, savedir='~/'
;
; MODIFICATION HISTORY:
;   Shahin Jafarzadeh (Rosseland Centre for Solar Physics, University of Oslo, Norway), July 2021
;-
pro salat_prep_data, cube, savedir=savedir

if n_elements(savedir) eq 0 then savedir='./'

p1=strpos(cube, '.fits')
p0=strpos(cube, 'solaralma.', p1-1 , /reverse_search)
filename=strmid(cube, p0, p1-p0)

imcube = readfits(cube,hd)
imcube = reform(imcube[*,*,0,0,*])

variables = reform(readfits(cube,hd_var,ext=1,/silent))
soap_parameters = reform(readfits(cube,hd_soap,ext=2,/silent))

sz = size(imcube)
nx = sz(1)
ny = sz(2)
nt = sz(3)

print, '... data set of dimensions x,y: '+strtrim(nx,2)+','+strtrim(ny,2)
print, '... number of frames: '+strtrim(nt,2)

imfilename=savedir+filename+'_modified-dimension.fits'

writefits, imfilename, imcube;, hd
imcube = readfits(imfilename,hd,/silent)

mwrfits, imcube, imfilename, hd, /create
;mwrfits, variables, imfilename, hd_var
;mwrfits, soap_parameters, imfilename, hd_soap

print
print, ' ---------------------------------------------------'
print, ' -- Solar Alma Library of Auxiliary Tools (SALAT) --'
print, ' ---------------------------------------------------'
print

end
