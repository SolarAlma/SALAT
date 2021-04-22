;+
; NAME: SALAT_CONTRAST
;		part of -- Solar Alma Library of Auxiliary Tools (SALAT) --
;
; PURPOSE: 
;	Compute and plot "mean intensity" and "rms intensity contrast" of a cube and indicate bad/good frames based on a given threshold.
;
; CALLING SEQUENCE:
;	bestframe = salat_contrast(cube, limit=limit, badframes=badframes, goodframes=goodframes)
;
; + INPUTS:
; 	CUBE		The ALMA data cube in [x,y,t] format.
;			
; + OPTIONAL KEYWORDS:
; 	FITS		It should be set if the cube is a fits file.
; 	LIMIT		A limit for the rms intensity contrast, with which 'good' and 'bad' frames are identified.
; 	SIDE		Number of pixels to be excluded from sides of the field of view prior to calculations of the mean intensity and rms contrast.
; 	SHOW_BEST	If set, location of the best frame (i.e., that with the largest rms contrast) is indicated on the plot.
; 	TITLE		It should be set if the cube is a fits file.
;			
; + OUTPUTS:
;	BESTFRAME	Index of the best frame (i.e., that with the largest rms contrast).
; 	GOODFRAMES	Indices of 'good' frames, i.e., those above the LIMIT, only if the LIMIT is defined (optional)
; 	BADFRAMES	Indices of 'bad' frames, i.e., those below the LIMIT, only if the LIMIT is defined (optional)
; 
; © Shahin Jafarzadeh (RoCS/SolarALMA)
;-
function salat_contrast, cube, fits=fits, limit=limit, side=side, show_best=show_best, badframes=badframes, goodframes=goodframes, title=title

if n_elements(title) eq 0 then title=' '
if n_elements(show_best) eq 0 then show_best=0
if n_elements(fits) eq 0 then fits=0
if n_elements(side) eq 0 then side=20
if n_elements(limit) eq 0 then alimit=0 else alimit=1

if fits then im = readfits(cube) else im = cube

nx = n_elements(reform(im[*,0,0]))
ny = n_elements(reform(im[0,*,0]))
nt = n_elements(reform(im[0,0,*]))

print, ' '
print, ' ---> calculating "Mean Brightness" and "RMS Intensity Contrast" of the time series ...........'
print, ' '

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

; !p.charsize=2.5
; !x.thick=3.
; !y.thick=3.
!x.ticklen=0.05
!y.ticklen=0.01

window, 0, xs=2000, ys=1000, title='Variations of: mean brightness (top) & rms intensity contrast (bottom) | '+title
!P.MULTI=[0,1,2]
cgplot, imean, /ynozero, ytitle='Mean brightness', xs=1, pos=[0.1,0.59,0.99,0.99]

cgplot, rmsCont*100, /ynozero, xtitle='Frame number', ytitle='RMS intensity contrast [%]', xs=1, pos=[0.1,0.1,0.99,0.49]
ii= where(rmsCont*100 eq max(rmsCont*100))
xmax = x(ii)
rmsc = rmsCont*100
indx = sort(rmsc)
rmconts = rmsc(indx)
nrmscs = n_elements(rmsc)
if alimit eq 1 then sjhline, limit, color=cgColor('RED')

if show_best then begin
	sjvline, xmax, thick=2, color=cgColor('DodgerBlue'), linestyle=2
	xyouts, 0.14, 0.43, alignment=0.0, 'Best frame no.: '+strtrim(fix(xmax), 2), $
		color=cgColor('DodgerBlue'), /normal, charsize=2., charthick=1.2
	xyouts, 0.94, 0.43, alignment=1.0, 'Variation: '+strtrim(string(varper2, format='(F20.2)'),2)+' %', $
		color=cgColor('RED'), /normal, charsize=2., charthick=1.2
endif

bestframe = xmax

!P.MULTI=0 

mean = imean
rms = rmsCont*100

print, ' '
print, ' ----------------------------------------------------'
print, ' '
print, ' Variation of mean brightness (imean): '+strtrim(string(varper1, format='(F20.2)'),2)+' %'
print, ' '
print, ' Variation of rms intensity contrast (rmsCont): '+strtrim(string(varper2, format='(F20.2)'),2)+' %'
print, ' '
print, ' ----------------------------------------------------'
print, ' '

if alimit eq 1 then begin
	ii= where(rmsCont*100. le limit)
	bf = '['+strtrim(ii[0],2)
	for i=1L, n_elements(ii)-1 do bf = bf+','+strtrim(ii[i],2)
	bf =  bf+']'
	iii= where(rmsCont*100. gt limit)
	gf = '['+strtrim(iii[0],2)
	for i=1L, n_elements(iii)-1 do gf = gf+','+strtrim(iii[i],2)
	gf =  gf+']'
	bfi = ii
	gfi = iii
	print, ' '
	print, ' >>>>> Bad-frame index numbers (bfi): '+bf
	print, ' '
	print, ' '
	print, ' >>>>> Good-frame index numbers (gfi):'+gf
	print, ' '
	print, ' '
	goodframes = iii
	badframes = ii
endif

return, bestframe

end