;+
; NAME: SALAT_CONVOLVE_BEAM
;       part of -- Solar Alma Library of Auxiliary Tools (SALAT) --
;
; PURPOSE: 
;   Convolve a specified synthetic beam (from an ALMA observations) to a user-provided map 
;   (e.g. from a simulation or observations with other instruments)
;
; CALLING SEQUENCE:
;   convolved_cube = salat_convolve_beam(data, beam)
;
; + INPUTS:
;   DATA        A Cube or a frame (in FITS format; as a string) to be convolved with the ALMA beam
;   PIXEL_SIZE  The pixel size (i.e., sampling resolution) of the DATA (in arcsec).
;   BEAM        Beam parameters [major_axis, minor_axis, beam_angle] all in degrees.
;               It can be a 3-element array (i.e., mean of the beam parameters), or  a [3,nt] array for a time series (i.e., time-varying parameters).
;               If the latter, then nt (numebr of frames) should be equal to that in the DATA cube.
;
; + OPTIONAL KEYWORDS/INPUT PARAMETERS:
;   ALMA_CUBE   The SALSA level4 data cube in FITS format. 
;               If provided, the beam parameters are extracted from this cube (i.e., the BEAM keyword is ignored).
;
; + OUTPUTS:
;   Convolved Data cube or frame (same size as input DATA)
;
; + RESTRICTIONS:
;   None
;
; EXAMPLE:
;   IDL> data = './bifrost_b3_frame400.fits'
;	IDL> pixel_size = 0.066 ; arcsec
;	IDL> alma_cube = './solaralma.b3.fba.20161222_141931-150707.2016.1.00423.S.level4.k.fits'
;   IDL> convolved = salat_convolve_beam(data, pixel_size=pixel_size, alma_cube=alma_cube)
;	IDL> sjim, data, /fits, w=4, iris='FUV', title='original input image'
;	IDL> sjim, convolved, w=6, iris='FUV', title='convolved image'
;
; MODIFICATION HISTORY:
;   Shahin Jafarzadeh (Rosseland Centre for Solar Physics, University of Oslo, Norway), July 2021
;-
function salat_convolve_beam, data, pixel_size=pixel_size, beam=beam, alma_cube=alma_cube

im = readfits(data)

sz = size(im)
dimension = sz[0]
nx = sz[1]
ny = sz[2]
if dimension eq 3 then nt = sz[3]

if dimension eq 2 then begin
    if n_elements(alma_cube) ne 0 then begin
        alma_beam = salat_read_header(alma_cube,/silent)
        major = (alma_beam.major_beam_mean)*3600. ; in arcsec
        minor = alma_beam.minor_beam_mean*3600. ; in arcsec
        p_angle = alma_beam.beam_angle_mean ; in degrees
    endif else begin
        major = reform(beam[0])
        minor = reform(beam[1])
        p_angle = reform(beam[2])
    endelse
endif

if dimension eq 3 then begin
    if n_elements(alma_cube) ne 0 then begin
        variables = reform(readfits(alma_cube,header_var,ext=1,/silent))
        major = reform(variables[*,0])*3600.  ; in arcsec
        minor = reform(variables[*,1])*3600.  ; in arcsec
        p_angle = reform(variables[*,2])  ; in degrees
        nbeam = n_elements(major)
    endif else begin
        major = reform(beam[0,*])
        minor = reform(beam[1,*])
        p_angle = reform(beam[2,*])
        nbeam = n_elements(major)
    endelse
    if nt ne nbeam then begin
        print
        print, ' !!! For time series, the time dimension of the input DATA'
        print,'      must be same as that of the beam (or ALMA cube)'
        print
        stop
    endif
endif

; creating the ALMA PSF
NPIXEL = 21.
psf = psf_Gaussian(NPIXEL=NPIXEL, FWHM=[major,minor], /DOUBLE, /NORMALIZE)

; making the PSF the same pixel size as the input data
kernel = congrid(psf, NPIXEL/pixel_size, NPIXEL/pixel_size, /INTERP, /CENTER, cubic=-0.5)
kernel = rot(kernel, 90.-p_angle, missing=0, /INTERP, cubic=-0.5)

if dimension eq 3 then begin
	convolved = fltarr(nx,ny,nt)
	for it=0L, nt-1 do convolved[*,*,it] = convol(im[*,*,it], kernel, /edge_truncate, /norm)
endif else convolved = convol(im, kernel, /edge_truncate, /norm)

  return, convolved
end