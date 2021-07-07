;+
; NAME: SALAT_INTENSITY_TO_K
;		part of -- Solar Alma Library of Auxiliary Tools (SALAT) --
;
; PURPOSE:
;	 Converts intensity to brightness temperature by multiplying the data with the conversion facotr.
;
; + INPUT: 
;   ALMACUBE	The ALMA cube, wither 3D [x,y,t] or 4D [x,y,sw,t]
;	CONVERSION	The conversion vector: 1D if the there are no spectral windows (SW), or 2D if the ALMA cube is 4D.
;
; + OUTPUTS:
;	CONVERTEDCUBE	The ALMA cube in K (same dimension as the ALMACUBE)
;	
; © Shahin Jafarzadeh (RoCS/SolarALMA)
;-

pro salat_alma_intensity_to_K, ALMAcube, conversion

; needs a conversion factor's vector
 
cf = readfits('solaralma.b3.2016-12-22.cube.sw0123.sip.asc.level2.v010.image.pbcor.Jy_to_K.fits')

for sp = 0L, 3 do begin

cube = readfits('solaralma.b3.2016-12-22.cube.sw'+strtrim(sp,2)+'.sip.asc.level2.v010.image.pbcor_corrected_aper.fits',hdr)

restore, 'solaralma.b3.2016-12-22.cube.sw'+strtrim(sp,2)+'.sip.asc.level2.v010__parameters.save', /v

conv = reform(cf[sp,*,*])

Kcube = fltarr(320,320,128,115)

for t=0L, 114 do begin
	for s=0L, 127 do begin
		for x=0L, 319 do begin
			for y=0L, 319 do begin
				Kcube[x,y,s,t] = cube[x,y,s,t]*conv[s,t]
			endfor
		endfor
	endfor
endfor

mwrfits, Kcube, ofil, hdr, /create
mwrfits, TIME, ofil
mwrfits, FREQUENCY_HZ, ofil
mwrfits, BMAJ, ofil
mwrfits, BMIN, ofil
mwrfits, BPA, ofil

endfor

done
stop	
end
