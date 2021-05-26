;+
; NAME: SALAT_MAKE_ALMA_CUBE
;		part of -- Solar Alma Library of Auxiliary Tools (SALAT) --
;
; PURPOSE: 
;	Create ALMA cubes from individual files outputted by SoAP (put them together, remove bad frames 
;	and polish the cube), i.e., creates both pre-level4 (aka 'clean') and level4 cubes.
;
; CALLING SEQUENCE:
;	salat_make_alma_cube, files, savedir=savedir, filename=filename, date=date
;
; + INPUTS:
;	DIR			Path to the directory in which the individual files are stored.
; 	FILES		A string representing filename template of the individual files from SoAP 
;				(i.e., replace time and scan number with *).
;				Example: 'solaralma.b6.2018-08-23-*.sw0123.sip.fba.level3.v011.image.pbcor.fits'
;	DATE		Date of observations (as a string) in 'YYYY.MM.DD' format. Example: '2016.12.22'
;	BADFRAMES	An array of 'bad frames' selected manually (e.g., with the help of 'salat_contrast').
;				Bad frames are also automatically identified.
;
; + OPTIONAL KEYWORDS:
; 	SAVEDIR		A directory (as a string) in where the FITS cubes are stored (default = '~/').
; 	FILENAME	Name of the FITS cubes, as a string (default = 'solaralma').
;		
; + OUTPUTS:
;	Various FITS cubes stored in the given location:
;	ORIGINAL	3D cube of individual SoAP files
;	CLEAN		Same as ORIGINAL with the 'bad' frames removed
;	LEVEL4		Polished cube (correct for temporal misalignments, atmospheric effects, etc.)
; 
; © Shahin Jafarzadeh (RoCS/SolarALMA)
;-
pro salat_make_alma_cube, dir, files, savedir=savedir, filename=filename, date=date, badframes=badframes

if n_elements(savedir) eq 0 then savedir='~/'
if n_elements(filename) eq 0 then filename='solaralma'

;------- Creating one FITS cube from individual files

fl = file_search(dir+files)
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

PRINT
PRINT, ' ..... creating 3D cube: ['+strtrim(long(nx),2)+','+strtrim(long(ny),2)+','+strtrim(long(nt1),2)+']'
PRINT

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

cad = median(sjdiff(time[0:40],/silent))
PRINT, ' Cadence: '+strtrim(cad,2)+' sec'

PRINT
PRINT, ' ..... writing cube as '+savedir+filename+'_original.fits'
PRINT

cgplot, TIME, xs=1, ys=1, ytitle='Time (sec)', xtitle='Frame number'

writefits, savedir+filename+'_original.fits', cube, hdr

PRINT
PRINT, ' ..... writing parameters as '+savedir+filename+'_original.save'
PRINT

save,DATEOBS,TIME,BMAJ,BMIN,BPA,RA,DEC,PIXSIZE,FREQ,FREQDEL,RESTFREQ,file=savedir+filename+'_original.save'

PRINT, ' displaying the time series as a movie ..... '
PRINT

sjim, cube, /mv, /mc, cc=.6, iris='NUV', fps=1000., w=1

td = sjdiff(time,/silent)
ii = where(td gt cad*1.5)
lbf = '['+strtrim(ii[0],2)
for i=1L, n_elements(ii)-1 do lbf = lbf+','+strtrim(ii[i],2)
lbf =  lbf+']'
PRINT
PRINT, ' ..... frame numbers with gaps from the previous frame larger than 1.5*Cadence: '+lbf
PRINT
ii = where(td gt cad*10.)
lbf = '['+strtrim(ii[0],2)
for i=1L, n_elements(ii)-1 do lbf = lbf+','+strtrim(ii[i],2)
lbf =  lbf+']'
PRINT, ' ..... frame numbers with gaps from the previous frame larger than 10*Cadence: '+lbf
PRINT
PRINT, ' performing SALAT_CONTRAST (to help identifying bad frames) ..... '
PRINT

bf = salat_contrast(cube)
limit = ' '
READ, limit, PROMPT=' -- Set a limit for the rms contrast, below which the bad frames are identified: '
bf = salat_contrast(cube, limit=limit, badframes=badframes)

selection = ' '
READ, selection, PROMPT=' -- Are the bad frames are satisfying? Type 1 (yes) or 0 (no): '
if selection eq 1 then GOTO, here else begin
	PRINT
	PRINT, ' Start over the code by providing the bad frames!'
	PRINT
endelse
here:

;------- Creating a 'clean' cube, where 'bad' frames are excluded.

restore, savedir+filename+'_original.save'
cube = readfits(savedir+filename+'_original.fits',hdr)

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

fileout = savedir+filename+'_clean.fits'

PRINT
PRINT, ' ..... writing the clean cube (bad-frames removed) as '+fileout
PRINT

mwrfits, aa, fileout, hdr, /create
mwrfits, TIME, fileout

PRINT
PRINT, ' ..... writing parameters of the clean cube as '+savedir+filename+'_clean.save'
PRINT

save,DATEOBS,TIME,BMAJ,BMIN,BPA,RA,DEC,PIXSIZE,FREQ,FREQDEL,RESTFREQ,badframes,file=savedir+filename+'_clean.save'

;------- Creating a 'level4' cube (postprocessing the cube to remove, e.g., shakes and atmospheric effects)

selection = ' '
READ, selection, PROMPT=' -- Run the SALAT_ALMA_POLISH_TSERIES procedure (to create a level4 data cube; recomended)? Type 1 (yes) or 0 (no): '
if selection eq 1 then GOTO, pos1 else GOTO, pos2
pos1:

aa = readfits(savedir+filename+'_clean.fits',hdr,/silent)
restore, savedir+filename+'_clean.save'

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

PRINT, ' performing SALAT_ALMA_POLISH_TSERIES (to create the level4 data cube) ..... '
PRINT

salat_alma_polish_tseries,cube=savedir+filename+'_clean.fits',savedir=savedir,filename=filename+'_clean',tstep=7,np=7,/nostretch,$
	     param=savedir+filename+'_clean.save',date=date,pixelsize=PIXSIZE[0], xybd = xxxx

pos2:

print, ' '
print, ' +++++++++++++++++++++++'
print, ' +                     +'
print, ' +       Done :)       +'
print, ' +                     +'
print, ' +++++++++++++++++++++++'
print, ' '

end