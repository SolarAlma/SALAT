;+
; NAME: SALAT_CONTRAST
;       part of -- Solar Alma Library of Auxiliary Tools (SALAT) --
;
; PURPOSE: 
;   Compute and plot "mean intensity" and "rms intensity contrast" of a cube and indicate bad/good frames based on a given threshold.
;   Gaps (due to ALMA calibration routines) are marked with Red dashed lines.
;
; CALLING SEQUENCE:
;   bestframe = salat_contrast(cube, limit=limit, badframes=badframes, goodframes=goodframes)
;
; + INPUTS:
;   CUBE        The ALMA FITS cube in [x,y,t] format.
;           
; + OPTIONAL KEYWORDS/INPUT PARAMETERS:
;   SHOW_BEST   If set, location of the best frame (i.e., that with the largest rms contrast) is indicated on the plot.
;   TITLE       It should be set if the cube is a fits file.
;   SIDE        Number of pixels to be excluded from sides of the field of view prior to calculations of the mean intensity and rms contrast.
;          
; + OUTPUTS:
;   BESTFRAME   Index of the best frame (i.e., that with the largest rms contrast).
;   TIME_INDEX  Name of a variable for the frame indices sorted from the highest to lowest rms-intensity-contrast image
; 
; + RESTRICTIONS:
;   None
;
; EXAMPLE:
;   IDL> cube = './solaralma.b3.fba.20161222_141931-150707.2016.1.00423.S.level4.k.fits'
;   IDL> bestframe = salat_contrast(cube, /show_best, time_index=time_index)
;	IDL> im = readfits(cube)
;	IDL> best_ten_frames_cube = im[*,*,time_index[0:9]]
;
; MODIFICATION HISTORY:
;   Shahin Jafarzadeh (Rosseland Centre for Solar Physics, University of Oslo, Norway), July 2021
;-
function salat_contrast, cube, fits=fits, show_best=show_best, time_index=time_index, title=title, side=side

if n_elements(show_best) eq 0 then show_best = 0
if n_elements(side) eq 0 then side = 5

im = reform(readfits(cube,hd))

variables = reform(readfits(cube,header_var,ext=1,/silent))
time = reform(variables[*,3]) ; in sec

default_title = 'ALMA '+strtrim(sxpar(hd,'INSTRUME'),2)+' '+strtrim(sxpar(hd,'DATE-OBS'),2)
if n_elements(title) eq 0 then title = default_title

nx = n_elements(reform(im[*,0,0]))
ny = n_elements(reform(im[0,*,0]))
nt = n_elements(reform(im[0,0,*]))

print
print, ' -- calculating "Mean Brightness" and "RMS Intensity Contrast" of the time series .....'
print

imean = fltarr(nt)
istd = fltarr(nt)
for i=0,nt-1 do begin
    imean[i]=mean(reform(im[side:nx-side,side:ny-side,i]),/nan)
    istd[i]=stddev(reform(im[side:nx-side,side:ny-side,i]),/nan)
endfor

rmsCont = istd/imean

x = findgen(nt)
coeffs1 = LINEAR_FIT(x,imean)
coeffs2 = LINEAR_FIT(x,rmsCont)

varper1 = (float(((coeffs1(0)+(coeffs1(1)*(nt-1))-coeffs1(0)))/coeffs1(0)))*100.
varper2 = (float(((coeffs2(0)+(coeffs2(1)*(nt-1))-coeffs2(0)))/coeffs2(0)))*100.

!p.charsize=1.9
!x.thick=2.
!y.thick=2.
!x.ticklen=0.030
!y.ticklen=0.012

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

xtime = time-time[0]

window, 8, xs=1200, ys=1000, title='Variations of: mean brightness (top) & rms intensity contrast (bottom) | '+title
!P.MULTI=[0,1,2]
cgplot, xtime, imean, /ynozero, ytitle='Mean brightness', xs=1, pos=[0.1,0.59,0.99,0.99], color=cgColor('DarkGreen'), thick=2
for i=0L, nim-1 do oplot, xtime[result[i,0]:result[i,1]], imean[result[i,0]:result[i,1]], thick=2, color=cgColor('WHITE')
for i=0L, nim-1 do oplot, xtime[result[i,0]:result[i,1]], imean[result[i,0]:result[i,1]], thick=2, color=cgColor('RED'), linestyle=2

rms100 = rmsCont*100
cgplot, xtime, rms100, /ynozero, xtitle='Time (sec)', ytitle='RMS intensity contrast [%]', xs=1, pos=[0.1,0.1,0.99,0.49], color=cgColor('DarkGreen'), thick=2
for i=0L, nim-1 do oplot, xtime[result[i,0]:result[i,1]], rms100[result[i,0]:result[i,1]], thick=2, color=cgColor('WHITE')
for i=0L, nim-1 do oplot, xtime[result[i,0]:result[i,1]], rms100[result[i,0]:result[i,1]], thick=2, color=cgColor('RED'), linestyle=2

ii= where(rmsCont*100 eq max(rmsCont*100))
xmax = x[ii]
xmaxt = xtime[ii]
rmsc = rmsCont*100
indx = sort(rmsc)
rmconts = rmsc(indx)
nrmscs = n_elements(rmsc)

if show_best then begin
    sjvline, xmaxt, thick=3, color=cgColor('DarkRED'), linestyle=1
    xyouts, 0.1, 0.502, alignment=0.0, 'Best frame number: '+strtrim(fix(xmax), 2), $
        color=cgColor('DarkRED'), /normal, charsize=2., charthick=1.2
    xyouts, 0.99, 0.502, alignment=1.0, 'Variation: '+strtrim(string(varper2, format='(F20.2)'),2)+' %', $
        color=cgColor('Navy'), /normal, charsize=2., charthick=1.2
endif

bestframe = xmax

!P.MULTI=0 

mean = imean
rms = rmsCont*100

time_index = reverse(sort(rms))

print
print, ' ----------------------------------------------------'
print
print, ' -- Variation of mean brightness (imean): '+strtrim(string(varper1, format='(F20.2)'),2)+' %'
print
print, ' -- Variation of rms intensity contrast (rmsCont): '+strtrim(string(varper2, format='(F20.2)'),2)+' %'
print
print, ' ----------------------------------------------------'
print

print
print, ' ---------------------------------------------------'
print, ' -- Solar Alma Library of Auxiliary Tools (SALAT) --'
print, ' ---------------------------------------------------'
print

return, bestframe
end