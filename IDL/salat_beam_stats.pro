;+
; NAME: SALAT_BEAM_STATS
;       part of -- Solar Alma Library of Auxiliary Tools (SALAT) --
;
; PURPOSE: 
;   Print statistics aboout synthesised beam
;   and plot variation of the beam parameters with time.
;
; CALLING SEQUENCE:
;   salat_beam_stats, cube
;
; + INPUTS:
;   CUBE    The SALSA data cube in FITS format
;
; + OUTPUTS:
;   The plotted statistics.
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

!p.charsize=1.7
!x.thick=1.5
!y.thick=1.5

num = n_elements(time)
diff = dblarr(num-1)
for i=0L, num-2 do diff[i] = time[i+1]-time[i]
gap = 30. ; in sec
ii = where(diff gt gap, nim)
if nim gt 0 then begin
    result = intarr(nim,2)
    for it=0L, nim-1 do begin
        result[it,0]=ii[it]
        result[it,1]=ii[it]+1
    endfor
endif

window, 8, xs=1000, ys=800, title='Beam Statistics'
!P.Multi = [0, 2, 2]
pos = cgLayout([2,2], OXMargin=[10,4], OYMargin=[7,5], XGap=15, YGap=10)

xtime = time-time[0]

cgplot, xtime, BMAJ, xtitle='time (s)', ytitle='Major axis (arcsec)', thick=2, color=cgColor('DarkGreen'), $
    pos=pos[*,0], xs=1, yr=[min(BMAJ)-0.5*(max(BMAJ)-min(BMAJ)),max(BMAJ)+0.5*(max(BMAJ)-min(BMAJ))]
for i=0L, nim-1 do oplot, xtime[result[i,0]:result[i,1]], BMAJ[result[i,0]:result[i,1]], thick=2, color=cgColor('White')

cgplot, xtime, BMIN, xtitle='time (s)', ytitle='Minor axis (arcsec)', thick=2, color=cgColor('DarkGreen'), $
    pos=pos[*,1], xs=1, yr=[min(BMIN)-0.5*(max(BMIN)-min(BMIN)),max(BMIN)+0.5*(max(BMIN)-min(BMIN))]
for i=0L, nim-1 do oplot, xtime[result[i,0]:result[i,1]], BMIN[result[i,0]:result[i,1]], thick=2, color=cgColor('White')

cgplot, xtime, BPA, xtitle='time (s)', ytitle='Angle (degrees)', thick=2, color=cgColor('DarkGreen'), $
    pos=pos[*,2], xs=1, yr=[min(BPA)-0.5*(max(BPA)-min(BPA)),max(BPA)+0.5*(max(BPA)-min(BPA))]
for i=0L, nim-1 do oplot, xtime[result[i,0]:result[i,1]], BPA[result[i,0]:result[i,1]], thick=2, color=cgColor('White')

end