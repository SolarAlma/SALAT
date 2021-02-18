pro salat_alma_modify_header_and_info


dir = '/mn/stornext/d13/alma/shahin/original_cubes/SolarAlma.b3.2017-04-22-17:20:13.to.17:42:37/'

for sp = 0L, 3 do begin

cube = readfits('solaralma.b3.2017-04-22.cube.sw'+strtrim(sp,2)+'.sip.asc.level3.v010.image.pbcor_corrected_aper.fits',hdr)
cleantime = readfits('solaralma.b3.2017-04-22.cube.sw'+strtrim(sp,2)+'.sip.asc.level3.v010.image.pbcor_corrected_aper.fits', ext=1)

restore, dir+'solaralma.b3.2017-04-22.cube.sw'+strtrim(sp,2)+'.sip.asc.level3.v010.image.pbcor__parameters.save', /v
restore, dir+'solaralma.b3.2017-04-22.cube.sw'+strtrim(sp,2)+'.sip.sba.level3.v010.image.pbcor__parameters.save', /v

nn = n_elements(cleantime)
ii = lonarr(nn)	
kk = 0
for jj=0L, nn-1 do begin
	iii = where(TIME eq cleantime[jj],cc)
	if cc gt 0 then ii[kk] = iii
	kk = kk+1
endfor
ii = ii(sort(ii))
help, ii

help, cube, TIME, FREQUENCY_HZ, BMAJ, BMIN, BPA

TIME = TIME(ii)
BMAJ = BMAJ(ii)
BMIN = BMIN(ii)
BPA = BPA(ii)

print, ' --------------------'
help, cube, TIME, FREQUENCY_HZ, BMAJ, BMIN, BPA
print, ' --------------------'


SXADDPAR, hdr, 'PIXELSIZE', 0.34, 'ARCSEC'
SXADDPAR, hdr, 'OBSTIME', 'SEE EXT=1 OF THE FITS FILE'
SXADDPAR, hdr, 'FREQUENCY', 'SEE EXT=2 OF THE FITS FILE. Frequency of the 128 Channels in Hz.'
SXADDPAR, hdr, 'BMAJ', 'SEE EXT=3 OF THE FITS FILE. Major axis of beam at each time step'
SXADDPAR, hdr, 'BMIN', 'SEE EXT=4 OF THE FITS FILE. Minor axis of beam at each time step'
SXADDPAR, hdr, 'BPA', 'SEE EXT=5 OF THE FITS FILE. Beam angle at each time step'

ofil = 'solaralma.b3.2017-04-22.cube.sw'+strtrim(sp,2)+'.sip.asc.level3.v010.image.pbcor_corrected_aper.fits'

mwrfits, cube, ofil, hdr, /create
mwrfits, TIME, ofil
mwrfits, FREQUENCY_HZ, ofil
mwrfits, BMAJ, ofil
mwrfits, BMIN, ofil
mwrfits, BPA, ofil

endfor

done
stop	
end
