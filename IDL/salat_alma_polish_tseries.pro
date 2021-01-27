;+
; 
; PURPOSE:
;
;    To remove miss-alignement between images in a time-series
;	 (due to, e.g., seeing variation with time and/or mispointing)
;	 NOTE: The effect usually is corrected by x/y shifts cross correllations, 
;	       but it is sometimes more complex and different part of the FoV is destored differently.
; 
; KEYWORDS:
; 
; dir  :	Dirrecoty where the input cube is stoted
; cube :	Name of input fits-cube in this format: (x,y,t)
; xbd  : 	Size of the box in x within which the transformation params are calculated
; ybd  : 	Size of the box in y within which the transformation params are calculated
; time : 	String of observing time of individual frames
; np  : 	larger shake usually needs larger np. Typically, np = 2, if not helpful then np = 6 or 7, ...
; clip  : 	
; tile  : 
; tstep  : 
; scale  : 
; ang  : 
; shift  : 
; square : 
; negang  : 
; crop : 
; outdir :	Directory for outputs. Default is the same as the input cube
; rad  :	Radius of the additional circular aperture, to cover wiggling of the edges! 
;			rad=18.4 for band 3, and rad=16.7 for band 6
; nostretch :	if set, no stretching is applied.
;
; OUTPUTS:
; corrected_cube.fits:			corrected cube
; corrected_cube_final.fits:	corrected cube, but with an additional circular aperture
; tseries.calib.sav:			transformation parameters (along with the input values)
; 
; EXAMPLES:
;	 alma_polish_tseries,dir='/mn/stornext/d9/shahinj/ALMA/',cube='cube_sw1+scan11.fits',xbd=180,ybd=180,np=3,tstep=6
;	 alma_polish_tseries,cube='alma_band3_20161222_141921-150715.fits',rad=22,outdir='/mn/stornext/d13/alma/shahin/polished_cubes/',tstep=2,np=7,file='alma_band3_20161222_141921-150715_corrected'
; 	 alma_polish_tseries,cube='alma_band3_20161222_141921-150715.fits',outdir='/mn/stornext/d13/alma/shahin/polished_cubes/',tstep=2,np=7,rad=18.4,/threeg,time=TIMESTRING,date='2016.12.22'
;
;	 IDL> cube = 'alma_band3_20170422_172004-175504.fits'
;	 IDL> restore, 'obstime_alma_band3_20170422_172004-175504.save'
;	 IDL> alma_polish_tseries,cube=cube,outdir='/mn/stornext/d13/alma/shahin/polished_cubes/',tstep=2,np=7,rad=18.4,time=TIMESTRING,date='2017.04.22',/fits
;	
; -- Modifed by SJ for ALMA time-series of images
; -- based on CRISPRED-pipeline routines
; -- External routines and DLMs from the CRISPRED pipeline are required
;-;-----------------------------------------------------------------------------------

function alma_aligncube, cub, np $
                        , xbd = xbd, ybd = ybd $
                        , cubic = cubic $
                        , aligncube = aligncube $
                        , xc = xc, yc = yc, centered = centered, noselect=noselect
  
  if n_elements(xbd) eq 0 then xbd = 200
  if n_elements(ybd) eq 0 then ybd = 200

  inam = 'alma_aligncube : '
  dim = size(cub, /dim)

  if keyword_set(centered) then begin
     xc = dim[0]/2
     yc = dim[1]/2
  endif
  if n_elements(xc) gt 0 and n_elements(yc) gt 0 then begin
    sec = [ (xc+[-1, 1]*xbd/2) >0 <dim[0], (yc+[-1, 1]*ybd/2) >0 <dim[1]]
  endif

  if n_elements(np) eq 0 then np = 4
  np = np < dim[2]
  
  ;; split the series into subcubes
  maxj = red_get_iterbounds(dim[2], np)
  shifts = dblarr(2, dim[2])
  k = 0L
  noref = 1
  
  for i = 0L, n_elements(maxj)-1 do begin

    ;; Current sub-cube
    cube = dblarr(dim[0], dim[1], maxj[i])
    rms = fltarr(maxj[i])
    for j = 0, maxj[i] - 1 do begin
      cube[*,*,j] = cub[*,*,k]
      rms[j] = red_getrms(cub[*,*,k])
      K += 1L
    endfor
    ;; Position of the image with highest RMS
	idx = 0
    dum = max(rms, idx)

    ;; Align
    if(noref) then begin
      refoffs=[0.0, 0.0]
      if n_elements(sec) eq 0 then begin
        window,0, xs = dim[0], ys = dim[1] $
               , title = 'Select subfield:  LMB moves,  RMB accepts'
		aatmp = cube[*,*,idx]
		aatmp(where(~finite(aatmp),/null)) = median(aatmp)
        tvscl, red_histo_opt(aatmp)
        if noselect eq 0 then red_box_cursor, x0, y0, xbd, ybd, /FIXED
        sec = [x0, x0+xbd-1, y0, y0+ybd-1]
      endif
      window,0, xs = xbd, ys = ybd, title = 'Reference for subset'
      tvscl, red_histo_opt(cube[sec[0]:sec[1],sec[2]:sec[3], idx])
      tempoff = red_getcoords(cube[sec[0]:sec[1],sec[2]:sec[3], *], idx)
      shifts[0, 0] = tempoff
      last = maxj[i]
      oldref = cube[sec[0]:sec[1],sec[2]:sec[3], idx] 
      noref = 0
    endif else begin
      nref = cube[sec[0]:sec[1], sec[2]:sec[3], idx]
      tvscl, nref
      tempoff = red_getcoords(cube[sec[0]:sec[1],sec[2]:sec[3], *], idx)
      ;; Alignment between old reference and new reference
      refoffs += red_shc(oldref, nref, /filt, /int) 
      for ii = 0, maxj[i]-1 do tempoff[*, ii] += refoffs
      shifts[0, last] = tempoff
      last += maxj[i]
      oldref = temporary(nref)
    endelse
  endfor
  
  ;; Subtract the average
  shifts[0,*] -= median(shifts[0,*])
  shifts[1,*] -= median(shifts[1,*])
  
  if keyword_set(aligncube) then for ii = 0L, dim[2]-1 do $
    cub[*, *, ii] = red_shift_im(cub[*, *, ii], shifts[0, ii], shifts[1, ii] $
                                 , cubic = cubic)

  return, shifts
  
end

; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

pro salat_alma_polish_tseries, dir = dir, cube = cube, xbd = xbd, ybd = ybd, np = np, clip = clip, $
                         	tile = tile, tstep = tstep, scale = scale, date=date, $
                         	ang = ang, shift = shift, square=square, twogirds=twogirds, threegirds=threegirds, $
                         	negang = negang, crop=crop, ext_time = ext_time, noselect=noselect, centered=centered, $
                         	outdir = outdir, rad = rad, ext_date = ext_date, filename=filename, fits=fits, grid=grid, $
						 	nostretch=nostretch, silent=silent, badframes=badframes, obstime=obstime, pixelsize=pixelsize

  if n_elements(dir) eq 0 then dir = './'
  if n_elements(outdir) eq 0 then outdir = dir
  if n_elements(date) eq 0 then date = ' '
  if n_elements(fits) eq 0 then fits=0
  if n_elements(silent) eq 0 then silent=0
  if n_elements(twogirds) eq 0 then twogirds = 0 else twogirds = 1
  if n_elements(threegirds) eq 0 then threegirds = 0 else threegirds = 1
  if n_elements(noselect) eq 0 then noselect = 0
  if n_elements(centered) eq 0 then centered = 0
  if n_elements(nostretch) eq 0 then nostretch = 0 else nostretch = 1
  if n_elements(pixelsize) eq 0 then begin
	  print, ' '
	  print, ' pixelsize = ?'
	  print, ' '
	  stop
  endif
  ;if n_elements(filename) eq 0 then filename = strsplit(cube, /EXTRACT, '.fits')
  if n_elements(filename) eq 0 then begin
	  lll = strlen(cube)
	  filename = strmid(cube,0,lll-5)
  endif

  data_dir = dir

  time_stamp = 'alma'

  ;; read cube
  if fits eq 1 then begin
	  wfiles = dir+cube
	  cub = reform(readfits(wfiles))
  endif else cub = cube
  
  nx = n_elements(reform(cub[*,0,0]))
  ny = n_elements(reform(cub[0,*,0]))
  ct = n_elements(reform(cub[0,0,*]))
  
  restore, obstime

	;   if n_elements(badframes) gt 0 then begin
	;   	iremove = badframes[sort(badframes)]
	;   	nrem = n_elements(iremove)
	; nim = ct
	;   	iall = fix(findgen(nim))
	;   	for pp=0L, nrem-1 do iall = where(iall ne iremove[pp])
	;   	; ---------- remove bad frames
	;   	ncin = fltarr(nx,ny,nim-nrem)
	;   	nTIME = fltarr(nim-nrem)
	;   	nTIMESTRING = strarr(nim-nrem)
	;
	;   	j=0
	;   	for i=0L, nim-1 do begin
	;   		ib = where(i ne iremove, nnm)
	;   		if nnm eq nrem then begin
	;   			ncin[*,*,j] = reform(cub[*,*,i])
	;   			nTIME[j] = TIME[i]
	;   			nTIMESTRING[j] = TIMESTRING[i]
	;   			j = j+1
	;   		endif
	;   	endfor
	;   	cub = ncin
	;   	TIME = nTIME
	;   	TIMESTRING = nTIMESTRING
	;     nx = n_elements(reform(cub[*,0,0]))
	;     ny = n_elements(reform(cub[0,*,0]))
	;     ct = n_elements(reform(cub[0,0,*]))
	;   endif
  
  ; times = fltarr(ct)
  ; for i=0L, ct-1 do times[i] = string2time(time[i])
  
  times = TIME
  
  ; if n_elements(time) eq 0 then begin
  ; 	  time = strarr(ct)
  ; 	  ttt = 3600.+(findgen(ct)*2)
  ; 	  for i=0L, ct-1 do time[i] = time2string(ttt[i])
  ; endif
  
  ;; Align cube
  if(~keyword_set(shift)) then begin
     if(~keyword_set(np)) then begin
        np = 0L
        read, np, prompt =  '-- Please introduce the factor to recompute the reference image: '
     endif

     print, '-- aligning images ... ', format = '(A, $)'
     shift = alma_aligncube(cub, np, xbd = xbd, ybd = ybd, cubic = cubic, /aligncube, noselect=noselect, $
		 centered=centered)
     print, 'done'
  endif else begin
     print, '-- Using external shifts'

     if(n_elements(shift[0,*]) NE ct) then begin
        print, '-- Error, incorrect number of elements in shift array'
        return
     endif 

     for ii = 0L, ct - 1 do cub[*,*,ii] = red_shift_im(cub[*,*,ii], reform(shift[0,ii]), $
		 reform(shift[1,ii]) , cubic = cubic)
  endelse
  ff = 0
  
  ;; De-stretch
  if nostretch eq 0 then begin

  if twogirds eq 1 or threegirds eq 1 then begin
	clip = [10,8,4,3]
	tile = [4,8,16,32]
	clip1 = clip
	tile1 = tile
  endif else begin
	  if(~keyword_set(clip)) then clip = [12,4,2,1]
	  if(~keyword_set(tile)) then tile = [6,8,14,24]
  endelse
  if(~keyword_set(scale)) then scale = 1.0 / pixelsize
  if(~keyword_set(tstep)) then begin
     dts = dblarr(ct)
     for ii = 0L, ct - 1 do dts[ii] = red_time2double(time[ii])
     tstep = fix(round(180. / median(abs(dts[0:ct-2] - dts[1:*])))) <ct
  endif
  
  print, '-- Using the following parameters for de-stretching the time-series: '
  print, '   tstep [~3 m. (?)]= ', tstep
  print, '   scale [pixels / arcsec] = ', scale
  print, '   tile = ['+strjoin(string(tile, format='(I3)'),',')+']'
  print, '   clip = ['+strjoin(string(clip, format='(I3)'),',')+']'

  print, "-- computing destretch-grid (using LMSAL's routines) ... ", format = '(A, $)'
  if(~keyword_set(grid)) then grid = red_destretch_tseries(cub, scale, tile, clip, tstep)
  for ii = 0L, ct - 1 do cub[*,*,ii] = red_stretch(cub[*,*,ii], reform(grid[ii,*,*,*]))
  print, 'done'

  ;; De-stretch: if multiple runs are desired:
  if threegirds eq 1 then begin
	  clip = [12,4,2,1]
	  tile = [6,8,14,24]
  	  clip2 = clip
  	  tile2 = tile
	  if(~keyword_set(scale)) then scale = 1.0 / pixelsize
	  if(~keyword_set(tstep)) then begin
	     dts = dblarr(ct)
	     for ii = 0L, ct - 1 do dts[ii] = red_time2double(time[ii])
	     tstep = fix(round(180. / median(abs(dts[0:ct-2] - dts[1:*])))) <ct
	  endif
  
	  print, '-- Using the following parameters for de-stretching the time-series: '
	  print, '   tstep [~3 m. (?)]= ', tstep
	  print, '   scale [pixels / arcsec] = ', scale
	  print, '   tile = ['+strjoin(string(tile, format='(I3)'),',')+']'
	  print, '   clip = ['+strjoin(string(clip, format='(I3)'),',')+']'

	  print, "-- computing destretch-grid (using LMSAL's routines) ... ", format = '(A, $)'
	  if(~keyword_set(grid)) then grid = red_destretch_tseries(cub, scale, tile, clip, tstep)
	  for ii = 0L, ct - 1 do cub[*,*,ii] = red_stretch(cub[*,*,ii], reform(grid[ii,*,*,*]))
	  print, 'done'
  endif
  
  if twogirds eq 1 or threegirds eq 1 then begin
	  clip = [6,3,2,1]
	  tile = [4,8,12,16]
  	  if twogirds eq 1 then begin
		  clip2 = clip
		  tile2 = tile
	  endif else begin
		  clip3 = clip
		  tile3 = tile
	  endelse
	  if(~keyword_set(scale)) then scale = 1.0 / pixelsize
	  if(~keyword_set(tstep)) then begin
	     dts = dblarr(ct)
	     for ii = 0L, ct - 1 do dts[ii] = red_time2double(time[ii])
	     tstep = fix(round(180. / median(abs(dts[0:ct-2] - dts[1:*])))) <ct
	  endif
  
	  print, '-- Using the following parameters for de-stretching the time-series: '
	  print, '   tstep [~3 m. (?)]= ', tstep
	  print, '   scale [pixels / arcsec] = ', scale
	  print, '   tile = ['+strjoin(string(tile, format='(I3)'),',')+']'
	  print, '   clip = ['+strjoin(string(clip, format='(I3)'),',')+']'

	  print, "-- computing destretch-grid (using LMSAL's routines) ... ", format = '(A, $)'
	  if(~keyword_set(grid)) then grid = red_destretch_tseries(cub, scale, tile, clip, tstep)
	  for ii = 0L, ct - 1 do cub[*,*,ii] = red_stretch(cub[*,*,ii], reform(grid[ii,*,*,*]))
	  print, 'done'
  endif
  
  endif
  
  nx = n_elements(reform(cub[*,0,0]))
  ny = n_elements(reform(cub[0,*,0]))
  nim = n_elements(reform(cub[0,0,*]))
  for i=0L, nim-1 do begin
  	im = reform(cub[*,*,i])
  	ii = where(~finite(im),/null, numf)
  	if numf gt 1 then im[ii] = median(im)
  	cub[*,*,i] = im
  endfor
  
  ;; Measure time-dependent intensity variation (sun move's in the Sky)
  tmean = total(total(cub,1),1) / float(nx) / float(ny)
  ; if silent ne 0 then begin
  ; 	  window, 1
  ; 	  if n_elements(tmean) gt 0 and min(tmean) gt -1000000. then plot, tmean, xtitle = 'Time Step', ytitle = 'Mean intensity', psym=-1
  ; endif

  if n_elements(rad) eq 0 then begin
	  print, ' '
	  print, ' ----------------------------------------------'
	  print, ' Manually find radius of final aperture:' 
	  print, ' ----------------------------------------------'
	  ii = where(shift[0,*] eq max(shift[0,*]))
	  print, ii
	  sjim, cub[*,*,ii], w=2 & 
	  print, ' Click on LEFT edge ---> ' & cursor, xl, yl, /up, /dev
	  ii = where(shift[0,*] eq min(shift[0,*]))
	  print, ii
	  sjim, cub[*,*,ii], w=2
	  print, ' Click on Right edge ---> ' & cursor, xr, yr, /up, /dev
	  aperture_radius_h = ((abs(xl-xr)/2.)*pixelsize)-0.5
	  ii = where(shift[1,*] eq max(shift[1,*]))
	  print, ii
	  sjim, cub[*,*,ii], w=2 & 
	  print, ' Click on BOTTOM edge ---> ' & cursor, xb, yb, /up, /dev
	  ii = where(shift[1,*] eq min(shift[1,*]))
	  print, ii
	  sjim, cub[*,*,ii], w=2 & 
	  print, ' Click on TOP edge ---> ' & cursor, xt, yt, /up, /dev
	  aperture_radius_v = ((abs(yt-yb)/2.)*pixelsize)-0.5
	  if aperture_radius_h le aperture_radius_v then aperture_radius = aperture_radius_h else aperture_radius = aperture_radius_v
  endif else aperture_radius = rad
  
  print, '-- aperture radius: ' + strtrim(aperture_radius,2) + ' arcsec'

  ;; Save angles, shifts and de-stretch grids
  odir = outdir
  ; file_mkdir, odir
  ; if n_elements(filename) eq 0 then ofil = 'tseries.calib.sav' else $
  ; 	  ofil = filename+'_tseries.calib.sav'
  ; print, '-- saving calibration data -> ' + odir + ofil
  ; if twogirds eq 0 and threegirds eq 0 then save, file = odir + ofil, tstep, clip, tile, scale, ang, shift, grid, time, date, wfiles, $
  ; 	  tmean, crop, ff, np, aperture_radius;, mang, x0, x1, y0, y1
  ;
  ; if twogirds eq 1 then save, file = odir + ofil, tstep, clip1, tile1, clip2, tile2, scale, ang, shift, grid, $
  ; 	  time, date, wfiles, tmean, crop, ff, np, aperture_radius;, mang, x0, x1, y0, y1
  ;
  ; if threegirds eq 1 then save, file = odir + ofil, tstep, clip1, tile1, clip2, tile2, clip1, tile1, $
  ; 	  scale, ang, shift, grid, time, date, wfiles, tmean, crop, ff, np, aperture_radius

  ; acube = fix(round(temporary(cub)))
  acube = cub

  ;; Normalize intensity
  ii = where(min(tmean) lt 0, ccii)
  if ccii gt 0 then tmean = tmean+ABS(min(tmean))
  icube = temporary(cub)
  me = mean(tmean)
  for ii = 0L, ct - 1 do icube[*,*,ii] *= (me / tmean[ii])
  tmeani = total(total(icube,1),1) / float(nx) / float(ny)
  ; if silent ne 0 then begin
  ; 	  wset, 1
  ; 	  if n_elements(tmeani) gt 0 and min(tmean) gt -1000000. then oplot, tmeani, ps=2, color=111
  ; endif
  
  ; ofil = filename+'_corrected.fits'
  ; print, '-- saving corrected cube (no aperture added) -> ' + odir + ofil
  
  
  ofil2 = filename+'_corrected_aper.fits'
  print, '-- saving corrected cube (with additional circular aperture) -> ' + odir + ofil2
  
  
  ofil4 = filename+'_sj_level4.fits'
  print, '-- saving corrected cube (with additional circular aperture), and boxcar 0f 10 frames -> ' + odir + ofil4
  
  
  ; ofil3 = filename+'_corrected_aper_int.fits'
  ; print, '-- saving corrected cube (with additional circular aperture) -> ' + odir + ofil3
  
  
  nx = n_elements(acube[*,0,0])
  ny = n_elements(acube[0,*,0])
  nim = n_elements(acube[0,0,*])

  ; add an extra circular aparture:
  dist_circle, mask, [nx,ny]
  mask = mask*pixelsize
  ; mask(where(mask gt 120)) = 10000.
  ; ii = where(mask gt 9000.)
  ;if n_elements(rad) eq 0 then aprad=16.7 else aprad = rad
  if n_elements(rad) eq 0 then aprad=aperture_radius else aprad = rad
  ii = where(mask gt aprad)

  adata = fltarr(nx,ny,nim)
  for i=0L, nim-1 do begin
  	fn = reform(acube[*,*,i])
  	fn(ii) = !VALUES.F_NAN
  	adata[*,*,i] = fn
  	fni = reform(icube[*,*,i])
  	fni(ii) = !VALUES.F_NAN
  	icube[*,*,i] = fni
  endfor
  
  rad = aprad
  
  scube = fltarr(nx,ny,nim)
  for ix=0L, nx-1 do for iy=0L, ny-1 do scube[ix,iy,*] = SMOOTH(reform(adata[ix,iy,*]), 10, /edge_truncate, /nan)
  
  mkhdr, hdr, adata
  
  cad = times[10]-times[9]
  
  SXADDPAR, hdr, 'CADENCE', cad, 'SEC'
  SXADDPAR, hdr, 'PIXELSIZE', pixelsize, 'ARCSEC'
  SXADDPAR, hdr, 'OBSDATE', date
  SXADDPAR, hdr, 'OBSTIME', 'SEE EXT=1 OF THE FITS FILE'
  SXADDPAR, hdr, 'aprad', aprad
  
  ; mwrfits, acube, odir+ofil, hdr, /create
  ; mwrfits, times, odir+ofil
  
  mwrfits, adata, odir+ofil2, hdr, /create
  mwrfits, times, odir+ofil2
  
  ; mwrfits, icube, odir+ofil3, hdr, /create
  ; mwrfits, times, odir+ofil3
  
  SXADDPAR, hdr, 'LEVEL4', '10-frames boxcar'
  mwrfits, scube, odir+ofil4, hdr, /create
  mwrfits, times, odir+ofil4
  
  ;original_cube = readfits(wfiles)
  
  save, tstep, np, rad, shift, time, date, file=odir+filename+'_tseries.calib.sav'
  
  if silent eq 0 then sjim, scube, /mv, /mc, iris='NUV', ref=original_cube, cc=.5, fps=1000.


done
; stop
end