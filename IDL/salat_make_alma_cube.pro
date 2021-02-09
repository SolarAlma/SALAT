pro salat_make_alma_cube, filesearch, savedir=savedir, filename=filename, date=date, $
						  mkcube=mkcube, cleancube=cleancube, polish=polish, $
						  badframes=badframes


; (1) create ALMA cubes from individual files outputed by SoAP
; (2) create 'clean' ceubs, where the faulty frames are excluded
;
; INPUTS
; FILESEARCH	example: 'solaralma.b6.2018-08-23-*.sw0123.sip.fba.level3.v011.image.pbcor.fits'
; DATE			example: '2018.08.23'
; BADFRAMES		Selected manually, with the help of contract plot. example: badframes = [0,598,599,600,601,602,1199]
; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

dir = './'
outdir = savedir
savefile = filename

if mkcube+cleancube+polish gt 1 and mkcube+cleancube+polish ne 3 then stop
if mkcube+cleancube+polish eq 0 then begin mkcube = 1 & cleancube = 1 & polish = 1 endif

; -------------------------------------------------------------------------------------------------------
; -------------------------------------------------------------------------------------------------------
; -------------------------------------------------------------------------------------------------------

if mkcube eq 1 then begin

	fl = file_search(filesearch)
	tmp = readfits(fl[0])
	nx = n_elements(reform(tmp[*,0]))
	ny = n_elements(reform(tmp[0,*]))
	nt1 = n_elements(fl)
	cube = fltarr(nx,ny,nt1)
	DATEOBS = strarr(nt1)
	BMAJ = fltarr(nt1)
	BMIN = fltarr(nt1)
	BPA = fltarr(nt1)
	RA = fltarr(nt1)
	DEC = fltarr(nt1)
	PIXSIZE = fltarr(nt1)
	TIME = fltarr(nt1)
	FREQ = fltarr(nt1)
	FREQDEL = fltarr(nt1)
	RESTFREQ = fltarr(nt1)

	for t=0L, nt1-1 do begin
		cube[*,*,t] = reform(readfits(fl[t],hdr,/silent))
	
		DATEOBS[t] = sxpar(hdr,'DATE-OBS')
		BMAJ[t] = sxpar(hdr,'BMAJ')
		BMIN[t] = sxpar(hdr,'BMIN')
		BPA[t] = sxpar(hdr,'BPA')
		RA[t] = sxpar(hdr,'CRVAL1')
		PIXSIZE[t] = ABS(sxpar(hdr,'CDELT1'))*3600. ; arcsec
		DEC[t] = sxpar(hdr,'CRVAL2')
		FREQ[t] = sxpar(hdr,'CRVAL3')
		FREQDEL[t] = sxpar(hdr,'CDELT3')
		RESTFREQ[t] = sxpar(hdr,'RESTFRQ')
	
	  	lll = strlen(DATEOBS[t])
	  	TIMEstr = strmid(DATEOBS[t],11)
		TIME[t] = string2time(TIMEstr)
	
		print,string(13b)+' % finished: ',float(t*100.)/(nt1-1),format='(a,f4.0,$)'	
	endfor

	print, 'creating ..... '+savedir+savefile

	cgplot, TIME, xs=1, ys=1

	writefits, outdir+savefile+'.fits', cube, hdr

	save,DATEOBS,TIME,BMAJ,BMIN,BPA,RA,DEC,PIXSIZE,FREQ,FREQDEL,RESTFREQ,file=outdir+savefile+'.save'

	sjim, cube, /mv, /mc, cc=.6, iris='NUV', fps=1000.

	cad = median(sjdiff(time[0:40],/silent))
	print, ' >>>>> Cadence: '+strtrim(cad,2)+' sec'
	td = sjdiff(time,/silent)
	ii = where(td gt cad*1.5)
	print, ii
	print, td(ii)
	print, ' '
	ii = where(td gt cad*10)
	print, ii
	print, td(ii)

	sjcontrast, cube

endif

; -------------------------------------------------------------------------------------------------------
; -------------------------------------------------------------------------------------------------------
; -------------------------------------------------------------------------------------------------------

if badframe then begin

	restore, outdir+savefile+'.save'
	cube = rf(outdir+savefile+'.fits',hdr)

	nx = n_elements(reform(cube[*,0,0]))
	ny = n_elements(reform(cube[0,*,0]))
	ntt = n_elements(reform(cube[0,0,*]))

	nb = n_elements(badframes)

	nt = ntt-nb

	DATEOBSa = strarr(nt)
	BMAJa = fltarr(nt)
	BMINa = fltarr(nt)
	BPAa = fltarr(nt)
	RAa = fltarr(nt)
	DECa = fltarr(nt)
	PIXSIZEa = fltarr(nt)
	TIMEa = fltarr(nt)
	FREQa = fltarr(nt)
	FREQDELa = fltarr(nt)
	RESTFREQa = fltarr(nt)

	aa = fltarr(nx,ny,nt)
	taa = fltarr(nt)

	j = 0
	for i=0L, ntt-1 do begin
		ii = where(badframes eq i, nn)
		if nn lt 1 then begin
			aa[*,*,j] = cube[*,*,i]
		
			DATEOBSa[j] = DATEOBS[i]
			BMAJa[j] = BMAJ[i]
			BMINa[j] = BMIN[i]
			BPAa[j] = BPA[i]
			RAa[j] = RA[i]
			DECa[j] = DEC[i]
			PIXSIZEa[j] = PIXSIZE[i]
			TIMEa[j] = TIME[i]
			FREQa[j] = FREQ[i]
			FREQDELa[j] = FREQDEL[i]
			RESTFREQa[j] = RESTFREQ[i]

			j=j+1
		endif else print, badframes(ii)
	endfor

	; j = 0
	; for i=0L, nt-1 do begin & ii = where(badframes eq i, nn) & if nn lt 1 then begin & aa[j] = JYB2K_FACTOR[i] & j=j+1 & endif else print, r(ii) & endfor

	DATEOBS = DATEOBSa
	BMAJ = BMAJa
	BMIN = BMINa
	BPA = BPAa
	RA = RAa
	DEC = DECa
	PIXSIZE = PIXSIZEa
	TIME = TIMEa
	FREQ = FREQa
	FREQDEL = FREQDELa
	RESTFREQ = RESTFREQa

	save,DATEOBS,TIME,BMAJ,BMIN,BPA,RA,DEC,PIXSIZE,FREQ,FREQDEL,RESTFREQ,badframes,file=outdir+savefile+'_clean.save'

	fileout = outdir+savefile+'_clean.fits'

	mwrfits, aa, fileout, hdr, /create
	mwrfits, TIME, fileout

	sjcontrast, aa

endif

if polish then begin
	
	aa = rf(outdir+savefile+'_clean.fits',hdr)
	restore, outdir+savefile+'_clean.save'

	nx = n_elements(aa[*,0,0])
	ny = n_elements(aa[0,*,0])
	ar = reform(aa[*,ny/2.,0])
	ii = where(~finite(ar),/null,nar)
	rad = (nx-nar)/2.
	dx = rad*cos(d2r(45))
	x0 = (nar/2.)+(rad-dx)
	x1 = (nar/2.)+(rad+dx)
	dy = dx
	y0 = (ny/2.)-dy
	y1 = (ny/2.)+dy
	xxxx = round(x1-x0)-5.

	p, xxxx

	; xbd =180,ybd =180 ; band3
	; xbd =165,ybd =165 ; band6

	alma_polish_tseries,cube=aa,outdir=outdir,filename=savefile+'_clean',tstep=7,np=7,/nostretch,$
		obstime=outdir+savefile+'_clean.save',date=date,pixelsize=PIXSIZE[0],xbd =xxxx,ybd =xxxx

endif

done
stop
end
