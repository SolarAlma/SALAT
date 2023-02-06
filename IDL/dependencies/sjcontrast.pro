pro sjcontrast, cube, title=title, wl=wl, single=single, fits=fits, side=side, limit=limit

; compute "mean intensity" and "rms intensity contrast" of a cube in this format: [x,y,t]

if n_elements(wl) eq 0 then wl=0
if n_elements(title) eq 0 then title=' '
if n_elements(single) eq 0 then single=0
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

window, 0, xs=2200, ys=1000, title='Variations of: mean brightness (top) & rms intensity contrast (bottom) | '+title
!P.MULTI=[0,1,2]
cgplot, imean, /ynozero, xtitle='Frame number', ytitle='Mean brightness', xs=1, pos=[0.1,0.59,0.99,0.99]
;xyouts, 0.94, 0.93, alignment=1.0, 'Variation: '+strtrim(string(varper1, format='(F20.2)'),2)+' %', $
;	color=cgColor('RED'), /normal, charsize=1.6, charthick=1.2

cgplot, rmsCont*100, /ynozero, xtitle='Frame number', ytitle='RMS intensity contrast [%]', xs=1, pos=[0.1,0.1,0.99,0.49]
ii= where(rmsCont*100 eq max(rmsCont*100))
xmax = x(ii)
rmsc = rmsCont*100
indx = sort(rmsc)
rmconts = rmsc(indx)
nrmscs = n_elements(rmsc)
if alimit eq 1 then sjhline, limit, color=cgColor('RED')
;xyouts, 0.94, 0.43, alignment=1.0, 'Variation: '+strtrim(string(varper2, format='(F20.2)'),2)+' %', $
;	color=cgColor('RED'), /normal, charsize=1.6, charthick=1.2

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
endif

stop
end