;+
; NAME: SALAT_READ
;       part of -- Solar Alma Library of Auxiliary Tools (SALAT) --
;
; PURPOSE: 
;   Reads in a SALSA level4 FITS cubes.
;   and provide information about the cube's dimension and other parameters stored as extensions
;   such as arrays of observing time, beam's size and angle.
;   The SALSA datacubes have the following dimensions: [spatial (x), spatial (y), frequency (f), Stokes (s), time (t)]
;   Thus, depending on the availability of full spectra and/or Stokes parameters, the cube may have 3-5 dimensions.
;
; CALLING SEQUENCE:
;   alma = salat_read(cube, header=header, time=time, beammajor=beammajor, beamminor=beamminor, beamangle=beamangle)
;
; + INPUTS:
;   CUBE        The SALSA data cube in FITS format
;
; + OPTIONAL KEYWORDS/INPUT PARAMETERS:
;   NAN_VALUE   User deined value to replace all NAN values (outside the science field of view)
;   NAN_MEDIAN  If set, the NAN values are replaced with the median of the entire data cube
;               If set, the NAN_VALUE keyword is ignored
;   SILENT      If set, no information is printed in terminal
;
; + OUTPUTS:
;   ALMA        The SALSA cube as an array. Information about dimension is printed in terminal.
;   HEADER      Name of a an IDL structure to store header of the FITS cube (calls salat_load_header.pro)
;               By default, the most important header's parameters with meaningful names are outputted as a structure.
;               Extra keywords: add /all for all parameters in the header, and/or /original for their original names/abbreviations 
;   TIME        Name of a variable for observing time, in seconds from UTC midnight (optional)
;   BEAM_MAJOR  Name of a variable for Major axis of the beam (i.e., ALMA's sampling beam) in degrees (optional)
;   BEAM_MINOR  Name of a variable for Minor axis of the beam in degrees (optional)
;   BEAM_ANGLE  Name of a variable for Angle of the beam in respect to .... in degrees (optional)
;
; + RESTRICTIONS:
;   Currently wroks with SALSA level4 3D datacubes (i.e., no spectral and Stokes data)
;
; EXAMPLE:
;   IDL> cube = './solaralma.b3.fba.20161222_141931-150707.2016.1.00423.S.level4.k.fits'
;   IDL> alma = salat_read(cube, header=header, time=time, beammajor=beammajor, beamminor=beamminor, beamangle=beamangle)
;   IDL> help, header
;   IDL> print, header.pixel_size
;   IDL> help, time, beammajor, beamminor, beamangle
;
; MODIFICATION HISTORY:
;   Shahin Jafarzadeh (Rosseland Centre for Solar Physics, University of Oslo, Norway), July 2021
;   Stian Aannerud (University of Oslo, Norway), July 2021: testing/debugging
;-
function salat_read, cube, header=header, time=time, beam_major=beam_major, beam_minor=beam_minor, $
                     beam_angle=beam_angle, nan_value=nan_value, nan_median=nan_median, silent=silent, $
                     no_header=no_header all=all, original=original

alma = reform(readfits(cube,hd,/silent))
variables = reform(readfits(cube,hd_var,ext=1,/silent))
soap_parameters = reform(readfits(cube,hd_soap,ext=2,/silent))

sz = size(alma)
dimension = sz[0]
nx = sz[1]
ny = sz[2]
if dimension eq 3 then nt = sz[3] else begin
    print
    print, '  !!! Only SALSA level4 3D datacubes is currently acceptable.'
    print
endelse

beam_major = reform(variables[*,0])
beam_minor = reform(variables[*,1])
beam_angle = reform(variables[*,2])
time = reform(variables[*,3])

ii = where(~finite(alma[*,*,0]),/null, num)
if num gt 0 then begin
    if n_elements(nan_value) ne 0 then alma[ii] = nan_value
    if n_elements(nan_median) ne 0 then alma[ii] = median(alma)
endif

if n_elements(silent) eq 0 then begin
    print
    print, '... data cube dimension: 3D [x,y,time]'
    print, '... data set of dimensions x,y: '+strtrim(nx,2)+','+strtrim(ny,2)
    print, '... number of frames: '+strtrim(nt,2)
    print
    print, ' -- Output: Data cube (3D float array)'
    print, ' -- Optional: 1D arrays for observing time,'
    print, '    major and minor axes as well as angle of the sampling beam'
    print, '    as well the cube header can also be outputted as variables'
    print, '    IDL> alma = salat_load(cube, header=header, time=time, beammajor=beammajor, beamminor=beamminor, beamangle=beamangle)'
    print
    print, ' ---------------------------------------------------'
    print, ' -- Solar Alma Library of Auxiliary Tools (SALAT) --'
    print, ' ---------------------------------------------------'
    print
endif

if n_elements(all) eq 0 then all = 0 else all = 1
if n_elements(original) eq 0 then original = 0 else original = 1
if n_elements(no_header) ne 0 then header = salat_read_header(header=hd, all=all, original=original)

return, alma
end