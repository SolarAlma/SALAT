;+
; NAME: SALAT_MAKE_MOVIE
;		part of -- Solar Alma Library of Auxiliary Tools (SALAT) --
;
; PURPOSE: 
;	Makes a movie (time series of images) from a polished (e.g., level4) data cube, 
;	along with an analog clock and beam size/shape depicted.
;
; CALLING SEQUENCE:
;	salat_make_movie, cube, pixelsize=pixelsize, savedir=savedir, filename=filename
;
; + INPUTS:
; 	CUBE 		The input (polished; level4) FITS cube.
;	PIXELSIZE	Pixel size in arcsec.
;
; + OPTIONAL KEYWORDS:
; 	SAVEDIR		A directory (as a string) in where the JPEG imgaes are stored.
; 	FILENAME	Base name of the JPEG imgaes, as a string (default = 'im').
;		
; + OUTPUTS:
;	JPEG frames of the movie.
; 
; © Shahin Jafarzadeh (RoCS/SolarALMA)
;-
pro salat_make_movie, cube, pixelsize=pixelsize, savedir=savedir, filename=filename

if n_elements(filename) eq 0 then filenames = 'im' else filenames = filename

!p.charsize=1.2
!x.thick=2.
!y.thick=2.

ztitle='Temperature [kK]'

numrad = 350

almacube = cube

alma = readfits(almacube)
timesec = readfits(almacube,ext=1)

sides = 5./pixelsize

nx = n_elements(alma[*,0,0])
ny = n_elements(alma[0,*,0])
ar = reform(alma[*,ny/2.,0])
ii = where(~finite(ar),/null,nar)
diameter = nx-nar
x0 = (nx-diameter)/2.
x1 = x0+diameter
y0 = (ny-diameter)/2.
y1 = y0+diameter

; sides = 0.05*diameter

clip = [round(x0)-sides,round(x1)+sides,round(y0)-sides,round(y1)+(1.5*sides)]

alma = alma[clip[0]:clip[1],clip[2]:clip[3],*]

range = minmax(alma,/nan)

nx = n_elements(alma[*,0,0])
ny = n_elements(alma[0,*,0])
nim = n_elements(alma[0,0,*])

ar = reform(alma[*,ny/2.,0])
ii = where(~finite(ar),/null,nar)
rad = (nx-nar)/2.
dx = rad*cos(d2r(45))
xlc = (nar/2.)+(rad-dx)
xrc = (nar/2.)+(rad+dx)
dy = dx
ny0 = ny-(0.5*sides)
ybc = (ny0/2.)-dy
ytc = (ny0/2.)+dy

colset
device, decomposed=0

!P.FONT = 0
DEVICE, SET_FONT = 'lucidasanstypewriter-bold-18'

cc = 0.5

help, im

newcube = fltarr(nx/cc,ny/cc,nim)
for trt=0L, nim-1 do begin
	im = reform(alma[*,*,trt])
	in = where(~finite(im), /null)
	im(in) = median(im)
	alma[*,*,trt] = im
	newcube[*,*,trt] = congrid(iris_histo_opt(im), nx/cc, ny/cc, /INTERP, /CENTER, /MINUS_ONE,cubic=-0.5)
endfor
ascale = minmax(newcube,/nan)
	
for i=0L, nim-1 do begin

	im = reform(alma[*,*,i])
	
	imm = congrid(iris_histo_opt(im),nx/cc, ny/cc, /INTERP, /CENTER, /MINUS_ONE,cubic=-0.5)
	
	; imm = bytscl(imm,ascale[0],ascale[1])
	imm = bytscl(imm,min(imm),max(imm))
	
	IRIS_LCT, 'FUV', r, g, b

	if i eq 0 then sjim, im, iris='FUV', cc=cc else tvscl, imm

	radius = ((diameter/2.)/cc)-(2./cc)
	for jjj=0L, numrad do begin
		draw_circle, nx/cc/2., (ny-(0.5*sides))/cc/2., radius, thick=2, linestyle=0, color=cgColor('White'), /dev
		radius = radius+1
	endfor
	
	xtc2 = (((nx-1)/cc)-((0.4*sides)/cc))
	xtc1 = (xtc2-((1.2*(nx-1-xrc))/cc))
	ytc1 = (((ytc/cc)+((ny-ytc)/2./cc))-(2.5/cc))-(5.5/cc)
	ytc2 = (((ytc/cc)+((ny-ytc)/2./cc))+(2.5/cc))-(5.5/cc)
	
	myTICKINTERVAL=1
	if ifn eq 1 then myTICKINTERVAL=2
	if ifn eq 2 then myTICKINTERVAL=2
	if ifn eq 3 then myTICKINTERVAL=2
	
	IRIS_LCT, 'FUV', r, g, b
	; cgColorbar, Range=[ascale[0]/1000.,ascale[1]/1000.], position=[xtc1/((nx-1)/cc),ytc1/((ny-1)/cc),xtc2/((nx-1)/cc),ytc2/((ny-1)/cc)], $
	; 	TITLE=ztitle, MINOR=1, /TOP, TICKLEN=-0.4, TICKINTERVAL=myTICKINTERVAL
	
	draw_circle, nx/cc/2., (ny-(0.5*sides))/cc/2., ((diameter/2.)/cc)-(2.5/cc), thick=2, linestyle=0, color=cgColor('Black'), /dev
	
	; sjbox, left=0, bottom=ytc, w=0, cc=cc, right=xlc, top=ny-1, /plotbox
	
	sjclock, time2string(timesec[i]), pos=[0.02*diameter/cc,(ytc/cc)-(0.01*diameter/cc)], size=(xlc/cc)-(0.015*diameter/cc), col=0, thick=5., /dev
	
	numpix = 5./(pixelsize*cc)
	rightside = 2./(pixelsize*cc)
	
	xt2 = ((nx-1)/cc)-rightside
	xt1 = xt2-numpix
	
	cgplots,[xt1,xt2], [ybc/cc/2.+5/cc,ybc/cc/2.+5/cc], thick=4, color=cgcolor('Black'), /dev

	cgplots,[xt1,xt1], [(ybc/cc/2.)-(3/cc)+5/cc,(ybc/cc/2.)+(3/cc)+5/cc], thick=3, color=cgcolor('Black'), /dev
	cgplots,[xt2,xt2], [(ybc/cc/2.)-(3/cc)+5/cc,(ybc/cc/2.)+(3/cc)+5/cc], thick=3, color=cgcolor('Black'), /dev

	if ifn lt 3 then $
		cgText, xt1+(numpix/2.), (ybc/cc/2.)-(12./cc)+5/cc, ALIGNMENT=0.5, CHARSIZE=1., color=cgColor('Black'), '10 arcsec', /dev else $
			cgText, xt1+(numpix/2.), (ybc/cc/2.)-(12./cc)+5/cc, ALIGNMENT=0.5, CHARSIZE=1., color=cgColor('Black'), '5 arcsec', /dev
	
	
	cgplots,[0,nx/cc-1], [(ny0+((ny-ny0)/2.))/cc,(ny0+((ny-ny0)/2.))/cc], thick=(0.5*sides)/cc, /dev, color=cgcolor('Black')
	cgText, 0.02*diameter/cc, (ny-2-((0.5*sides)/2.))/cc-2., ALIGNMENT=0., CHARSIZE=1., color=cgColor('White'), databand[ifn], /dev
	cgText, ((nx-1)/cc)-(0.03*diameter/cc), (ny-2-((0.5*sides)/2.))/cc-2., ALIGNMENT=1., CHARSIZE=1., color=cgColor('White'), datalabel[ifn], /dev
	
	; beam
	BMAJm = mean(BMAJ)*3600./2.
	BMINm = mean(BMIN)*3600./2.
	BPAm = mean(BPA)
	sjtvellipse, BMAJm/pixelsize/cc, BMINm/pixelsize/cc, (xlc/2./cc)+(0.2*sides)/cc, ybc/cc/2.+5/cc, 90.+BPAm, cgColor('Black'), /dev, /fill, npoints=1000
	
	void = cgSnapshot(filename=savedir+filenames+strtrim(long(1000+i),2), quality=100, /JPEG, /NODIALOG)
	
	erase

endfor

end