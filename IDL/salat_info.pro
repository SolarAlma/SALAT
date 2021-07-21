;+
; NAME: SALAT_INFO
;       part of -- Solar Alma Library of Auxiliary Tools (SALAT) --
;
; PURPOSE: 
;   Prints some relevant information about the data cube in terminal
;
; CALLING SEQUENCE:
;   salat_info, cube
;
; + INPUTS:
;   CUBE        The SALSA data cube in FITS format
;
; + OUTPUTS:
;   Information printed in terminal only.
;
; + RESTRICTIONS:
;   None
;
; EXAMPLE:
;   IDL> cube = './solaralma.b3.fba.20161222_141931-150707.2016.1.00423.S.level4.k.fits'
;   IDL> salat_info, cube
;
; MODIFICATION HISTORY:
;   Shahin Jafarzadeh (Rosseland Centre for Solar Physics, University of Oslo, Norway), July 2021
;-
pro salat_info, cube
    
hd = headfits(cube)
variables = reform(readfits(cube,header_var,ext=1,/silent))

print, '  '
print, ' --------------------------------------------------'
print, ' |  Info:'
print, ' --------------------------------------------------'
print, ' |  ALMA Band: '+strtrim(sxpar(hd,'INSTRUME'),2)
print, ' |  Time of observations: '+strtrim(sxpar(hd,'DATE-OBS'),2)
print, ' |  ALMA Project ID: '+strtrim(sxpar(hd,'PROPCODE'),2)
print, ' |  Pixel size (arcsec): '+strtrim(sxpar(hd,'CDELT1A'),2)
print, ' |  Beam average (arcsec): '+strtrim(sxpar(hd,'SPATRES'),2)
print, ' |  FOV diameter (arcsec): '+strtrim(sxpar(hd,'EFFDIAM'),2)
print, ' --------------------------------------------------'
print, ' |  Data range:'
print, ' --------------------------------------------------'
print, ' |  Min (K): '+strtrim(sxpar(hd,'DATAMIN'),2)
print, ' |  Max (K): '+strtrim(sxpar(hd,'DATAMAX'),2)
print, ' --------------------------------------------------'
print, '  '

print
print, ' ---------------------------------------------------'
print, ' -- Solar Alma Library of Auxiliary Tools (SALAT) --'
print, ' ---------------------------------------------------'
print

end