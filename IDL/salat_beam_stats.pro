;+
; NAME: SALAT_BEAM_STATS
;       part of -- Solar Alma Library of Auxiliary Tools (SALAT) --
;
; PURPOSE: 
;   Print statistics aboout synthesised beam
;	and plot variation of the beam parameters with time.
;
; CALLING SEQUENCE:
;   salat_beam_stats, cube
;
; + INPUTS:
;   CUBE    The SALSA data cube in FITS format
;
; + OUTPUTS:
; 	The plotted statistics.
;
; + RESTRICTIONS:
;   None
;
; EXAMPLE:
;   IDL> cube = './solaralma.b3.fba.20161222_141931-150707.2016.1.00423.S.level4.k.fits'
;   IDL> salat_beam_stats, cube
;
; MODIFICATION HISTORY:
;   Shahin Jafarzadeh (Rosseland Centre for Solar Physics, University of Oslo, Norway), July 2021
;-
pro salat_beam_stats, cube

alma = reform(readfits(cube,header,/silent))
variables = reform(readfits(cube,header_var,ext=1,/silent))

BMAJ = reform(variables[*,0])*3600.  ; in arcsec
BMIN = reform(variables[*,1])*3600.  ; in arcsec
BPA = reform(variables[*,2])  ; in degrees
time = reform(variables[*,3]) ; in sec

print, '  '
print, ' ----------------------------------------------'
print, ' |  Beam Statistics:'
print, ' ----------------------------------------------'
print, ' |  -- Major axis (arcsec):'
print, ' |  Min = '+strtrim(min(BMAJ,/nan),2)
print, ' |  Max = '+strtrim(max(BMAJ,/nan),2)
print, ' |  Median = '+strtrim(median(BMAJ),2)
print, ' | '
print, ' |  -- Minor axis (arcsec):'
print, ' |  Min = '+strtrim(min(BMIN,/nan),2)
print, ' |  Max = '+strtrim(max(BMIN,/nan),2)
print, ' |  Median = '+strtrim(median(BMIN),2)
print, ' | '
print, ' |  -- Angle (degrees):'
print, ' |  Min = '+strtrim(min(BPA,/nan),2)
print, ' |  Max = '+strtrim(max(BPA,/nan),2)
print, ' |  Median = '+strtrim(median(BPA),2)
print, ' ----------------------------------------------'
print, '  '

!p.charsize=1.5
!x.thick=1.5
!y.thick=1.5

window, 8, xs=800, ys=800, title='Beam Statistics'
!P.Multi = [0, 2, 2]
pos = cgLayout([2,2], OXMargin=[10,4], OYMargin=[7,5], XGap=12, YGap=12)

cgplot, time-time[0], BMAJ, xtitle='time (s)', ytitle='Major axis (arcsec)', thick=2, color=cgColor('DarkGreen'), $
	pos=pos[*,0], xs=1, yr=[min(BMAJ)-0.5*(max(BMAJ)-min(BMAJ)),max(BMAJ)+0.5*(max(BMAJ)-min(BMAJ))]

cgplot, time-time[0], BMIN, xtitle='time (s)', ytitle='Minor axis (arcsec)', thick=2, color=cgColor('DarkGreen'), $
	pos=pos[*,1], xs=1, yr=[min(BMIN)-0.5*(max(BMIN)-min(BMIN)),max(BMIN)+0.5*(max(BMIN)-min(BMIN))]

cgplot, time-time[0], BPA, xtitle='time (s)', ytitle='Angle (degrees)', thick=2, color=cgColor('DarkGreen'), $
	pos=pos[*,2], xs=1, yr=[min(BPA)-0.5*(max(BPA)-min(BPA)),max(BPA)+0.5*(max(BPA)-min(BPA))]

end