;+
; NAME: SALAT_PLOT_MAP
;       part of -- Solar Alma Library of Auxiliary Tools (SALAT) --
;
; PURPOSE: 
;   Plot a map with optional features: color legend, synthesised beam etc.
;   and save images as JPG or PNG files (optional).
;
; CALLING SEQUENCE:
;   salat_plot_map, cube
;
; + INPUTS:
;   CUBE    The SALSA data cube in FITS format
;
; + OPTIONAL KEYWORDS/INPUT PARAMETERS:
;   COLOR_LEGEND    If set, a colorbar is also plotted
;   BEAM            If set, the beam shape/size is also depicted
;   AVERAGE         If set, the average image over the entire time series is plotted
;   TIMESTEP        The index of a frame to be plotted. If set, no movie is plotted.
;   SAVEDIR         A directory's location in which images are stored.
;   JPG             If SAVEDIR is defined, type of the stored image(s) is JPG
;   PNG             If SAVEDIR is defined, type of the stored image(s) is PNG (default)
;   CLOCK           If set, a clock displaying the observing time(s) is plotted
;
; + OUTPUTS:
;   The plotted image or the time series as a movie and optionally save them as JPG (or PNG)
;
; + RESTRICTIONS:
;   None
;
; EXAMPLE:
;   IDL> cube = './solaralma.b3.fba.20161222_141931-150707.2016.1.00423.S.level4.k.fits'
;   IDL> salat_plot_map, cube, /color_legend, /beam, /clock
;
; MODIFICATION HISTORY:
;   Shahin Jafarzadeh (Rosseland Centre for Solar Physics, University of Oslo, Norway), July 2021
;   Stian Aannerud (University of Oslo, Norway), July 2021: testing/debugging
;-
pro salat_plot_map, cube, color_legend=color_legend, beam=beam, average=average, timestep=timestep, savedir=savedir, jpg=jpg, png=png, clock=clock

!p.charsize=1.8
!x.thick=2.
!y.thick=2.

ztitle='Temperature [kK]'

numrad = 350

alma = reform(readfits(cube,header,/silent))
variables = reform(readfits(cube,header_var,ext=1,/silent))
timesec = reform(variables[*,3])

BMAJ = reform(variables[*,0])*3600.  ; in arcsec
BMIN = reform(variables[*,1])*3600.  ; in arcsec
BPA = reform(variables[*,2])  ; in degrees

nx = n_elements(alma[*,0,0])
ny = n_elements(alma[0,*,0])
ar = reform(alma[*,ny/2.,0])

pixelsize = float(sxpar(header,'CDELT1A'))

p1=strpos(cube, '.fits')
p0=strpos(cube, 'solaralma.', p1-1 , /reverse_search)
filename=strmid(cube, p0, p1-p0)

databand = 'Band '+strmid(cube, p0+11, 1)
date = strmid(cube, p0+17, 4)+'-'+strmid(cube, p0+21, 2)+'-'+strmid(cube, p0+23, 2)

sides = 5./pixelsize

ii = where(~finite(ar),/null,nar)
diameter = nx-nar
x0 = (nx-diameter)/2.
x1 = x0+diameter
y0 = (ny-diameter)/2.
y1 = y0+diameter

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

; !P.FONT = 0
; thisWindow = !D.Window
; DEVICE, SET_FONT = 'lucidasanstypewriter-bold-18'
; WDelete, !D.Window

cc = 0.35

newcube = fltarr(nx/cc,ny/cc,nim)
for trt=0L, nim-1 do begin
    im = reform(alma[*,*,trt])
    in = where(~finite(im), /null)
    im(in) = median(im)
    alma[*,*,trt] = im
    newcube[*,*,trt] = congrid(iris_histo_opt(im), nx/cc, ny/cc, /INTERP, /CENTER, /MINUS_ONE,cubic=-0.5)
endfor
ascale = minmax(newcube,/nan)

if n_elements(timestep) ne 0 then begin
    alma = reform(alma[*,*,timestep])
    timesec = reform(timesec[timestep])
    BMAJ = reform(BMAJ[timestep])
    BMIN = reform(BMIN[timestep])
    BPA = reform(BPA[timestep])
    nim = 1
endif

if n_elements(average) ne 0 then begin
	imavg = mean(alma,dimension=3,/nan)
	nim=1
endif

for i=0L, nim-1 do begin

    if n_elements(average) eq 0 then im = reform(alma[*,*,i]) else im = imavg

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

    IRIS_LCT, 'FUV', r, g, b
    if n_elements(color_legend) ne 0 then $
    cgColorbar, Range=[ascale[0]/1000.,ascale[1]/1000.], position=[xtc1/((nx-1)/cc),ytc1/((ny-1)/cc),xtc2/((nx-1)/cc),ytc2/((ny-1)/cc)], $
        TITLE=ztitle, MINOR=1, /TOP, TICKLEN=-0.4, TICKINTERVAL=myTICKINTERVAL

    draw_circle, nx/cc/2., (ny-(0.5*sides))/cc/2., ((diameter/2.)/cc)-(2.5/cc), thick=2, linestyle=0, color=cgColor('Black'), /dev

    if n_elements(clock) ne 0 then if n_elements(average) ne 0 then $
    sjclock, time2string(timesec[i]), pos=[0.02*diameter/cc,(ytc/cc)-(0.01*diameter/cc)], size=(xlc/cc)-(0.015*diameter/cc), col=0, thick=5., /dev

    numpix = 10./(pixelsize*cc)

    xt2 = ((14*nx/15.)/cc)
    xt1 = xt2-numpix
    scalen = numpix*pixelsize*cc ; 10
    scale = strtrim(long(scalen),2)+' arcsec'

    cgplots,[xt1,xt2], [ybc/cc/2.+5/cc,ybc/cc/2.+5/cc], thick=4, color=cgcolor('Black'), /dev
    cgplots,[xt1,xt1], [(ybc/cc/2.)-(3/cc)+5/cc,(ybc/cc/2.)+(3/cc)+5/cc], thick=3, color=cgcolor('Black'), /dev
    cgplots,[xt2,xt2], [(ybc/cc/2.)-(3/cc)+5/cc,(ybc/cc/2.)+(3/cc)+5/cc], thick=3, color=cgcolor('Black'), /dev
    cgText, xt1+(numpix/2.), (ybc/cc/2.)-(12./cc)+5/cc, ALIGNMENT=0.5, color=cgColor('Black'), scale, /dev


    cgplots,[0,nx/cc-1], [(ny0+((ny-ny0)/2.))/cc,(ny0+((ny-ny0)/2.))/cc], thick=(0.5*sides)/cc, /dev, color=cgcolor('Black')
    cgText, 0.02*diameter/cc, (ny-2-((0.5*sides)/2.))/cc-2., ALIGNMENT=0., color=cgColor('White'), databand, /dev
    cgText, ((nx-1)/cc)-(0.03*diameter/cc), (ny-2-((0.5*sides)/2.))/cc-2., ALIGNMENT=1., color=cgColor('White'), date, /dev

    if n_elements(beam) ne 0 then $
    sjtvellipse, (BMAJ[i]/2.)/pixelsize/cc, (BMIN[i]/2.)/pixelsize/cc, (xlc/2./cc)+(0.2*sides)/cc, ybc/cc/2.+5/cc, 90.+BPA[i], cgColor('Black'), /dev, /fill, npoints=1000
    
    if n_elements(savedir) ne 0 then begin
        if n_elements(JPG) ne 0 then dojpg = 1 else dojpg = 0
        if dojpg then void = cgSnapshot(filename=savedir+'frame_'+strtrim(long(1000+i),2), quality=100, /JPEG, /NODIALOG) else $
            void = cgSnapshot(filename=savedir+'frame_'+strtrim(long(1000+i),2), quality=100, /PNG, /NODIALOG)
    endif
    
    wait, 2

endfor

end