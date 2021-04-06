pro sjim, image, cc=cc, win=win, cb=cb, clbcolor=clbcolor, clt=clt, $
			fits=fits, rms=rms, f0=f0, nost=nost, stat=stat, $
			click=click, contrast=contrast, momfbd=momfbd, help=help, $
			nohist=nohist, scale=scale, cube=cube, dm=dm, axes=axes, $
			xtitle=xtitle, ytitle=ytitle, ztitle=ztitle, nobar=nobar, nocolor=nocolor, $
			ocontour=ocontour, clip=clip, title=title, ctfile=ctfile, $
			smt=smt, mask=mask, oc_color=oc_color, oc_thick=oc_thick, oc_fill=oc_fill, $
			oc_nlevels=oc_nlevels, crispex=crispex, fr=fr, fps=fps, mv=mv, $
			mcube=mcube, xpos=xpos, ypos=ypos, reverse=reverse, rot=rot, zm=zm, val=val, $
			imno=imno, ref=ref, velclt=velclt, aiaclt=aiaclt, hmiclt=hmiclt, irisclt=irisclt, gamma=gamma, $
			time=time, savedir=savedir, filename=filename, revclt=revclt, scan=scan, xcc=xcc, ycc=ycc, $
			textseries=textseries, myclt=myclt, actual=actual, bclt=bclt, bottom=bottom, ncolor=ncolor, $
		    tif=tif, eps=eps, sizeeps=sizeeps, mac=mac, clockcolor = clockcolor, center=center, sideclip=sideclip

;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; Purpose:
;         		Plot an image
;
; Inputs:
; IMAGE			Image as a 2D array
; CC			Compression cofficient for the size of image in respect to the 
;				original image size (keeping the same accpect ratio).
; XCC and YCC	Compression cofficient for the size of image in x or y directions
; W				IDL winodw number!
; CLT			IDL color table number, default: clt=0
; VELCLT		If chosen, then blue-white-red color table (for LOS vel.) is used.
; AIACLT		Given a SDO/AIA wavelength to use its defined color table!
;				aiaclt can be: 1600,1700,4500,94,131,171,193,211,304,335
; IRISCLT		['SJI_5000W', 'SJI_2832', 'SJI_2796', 'SJI_1600W', 'SJI_1400', 'SJI_1330', 'FUV', 'NUV', 'SJI_NUV']
; FITS			If the image format/extension is .fits
; F0			If the image format/extension is .f0 (ANA)
; MOMFBD		If the image format/extension is .momfbd
; CRISPEX		If the image is being read from a CRISPEX cube
; NOST			If not, a complete statistics of the image is shown.
; STAT			A short summary of image's statistics
; RMS			Show rms intensity contrast of the image
; CLICK			Returns (x,y) coordinates on mouse clicks on the image 
; CONTRAST		Opens an interactive window, allowing to select image's scale,
; NOHIST		Shows the image without iris_histo_opt option!
; SCALE			An array of two elements used for byte-scaling the image
; DM			Uses a red-white-blue color table, modified for, e.g. doppler maps
; AXES			Plots axes box around the image
; TITLE			Title of IDL window!
; XTITLE		xtitle of the plot, when AXES is selected!
; YTITLE		ytitle of the plot, when AXES is selected!
; ZTITLE		ztitle of the plot, when AXES is selected!
; CLB			Draws a color bar!
; CLBCOLOR		Color of color-bar's border!
; NOBAR			No color bar is shown, when AXES is selected!
; OCONTOUR		Overplot a contour map. Then MAKS has to be defined.
; OC_COLOR		IDL color table's number for overlaid contour
; OC_THICK		Thickness of overlaid contour
; OC_NLEVELS	Number of levels of overlaid contours
; MASK			The image used fo the overlaid contour
; CLIP			A 4-elements array in pixels indicating the sub-image to be plotted
; FR			Frame range for the movie from CRISPEX cubes
; FPS			Frame rate for the movie; default is fps=20
; SMT			Number of pixels for spatial smoothing
; CUBE			In this format: cube=[-1,-1,3] meaning image[*,*,3]; 
;				Both 3D and 4D cubes are accepted. If one of the dimensions is equal to
;				-100 then a movie for than dimension is displayed
; MV			Display a movie for the image template given instead of an image name:
;				for example: imshow, 'im_300*.fits', /fits
; IMNO			if used with /MV, the images are sorted based on their sequence numbers:
;				>> it only works for MOMFBDed ANA files (at the moment)
; REF			if used with /MV, a second movies are displayed side-by-side along with 
;				the first one. NOTE) they must have the same size, format and no. of images.
; MCUBE			Same as CUBE, but for individual frames, i.e., when /MV
; DM			The color table for doppler map, if set, a specific color-table
;				file may be also defined using ctfile keyword.
; ZM			Open a zoomable window
; CTFILE		An additional user-file for the color table of doppler map, if DM is selected.
; TIF			The output image's format
; EPS			The output image's format (preferred for publications, etc.)
; EPSSIZE		Size of the EPS output file in cm: as as 2D array. Default: [10.,30.]
; MAC			Works togethr with "eps" and when running IDL under mac 
;				(then another program is used to clip white edges around the EPS file)
;
; © Shahin Jafarzadeh
;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

if n_elements(help) eq 0 then help=0 else begin
	print, ' '
	print, ' -------------------------------------'
	print, ' sjim, image, cc=cc, w=w, cb=cb, clbcolor=clbcolor, clt=clt, $'
	print, ' fits=fits, rms=rms, f0=f0, nost=nost, stat=stat, $'
	print, ' click=click, contrast=contrast, momfbd=momfbd, help=help, $'
	print, ' nohist=nohist, scale=scale, cube=cube, dm=dm, axes=axes, $'
	print, ' xtitle=xtitle, ytitle=ytitle, ztitle=ztitle, nobar=nobar, $'
	print, ' ocontour=ocontour, clip=clip, title=title, ctfile=ctfile, $'
	print, ' smt=smt, mask=mask, oc_color=oc_color, oc_thick=oc_thick, $'
	print, ' oc_nlevels=oc_nlevels, crispex=crispex, fr=fr, fps=fps, mv=mv, $'
	print, ' mcube=mcube, xpos=xpos, ypos=ypos, reverse=reverse, rot=rot, zm=zm, val=val, $'
	print, ' imno=imno, ref=ref, velclt=velclt, aiaclt=aiaclt, hmiclt=hmiclt, gamma=gamma, $'
	print, ' time=time, savedir=savedir, revclt=revclt, scan=scan'
	print, ' -------------------------------------'
	print, ' '
	stop
endelse

 imageoriginal = image

 if n_elements(clt) eq 0 then nnocolor=1 else nnocolor=0
 if not keyword_set(cb) then nobar=1 else nobar=0
 
 if n_elements(clt) eq 0 then clt=0
 ct = clt
 if n_elements(win) eq 0 then win=0
 w = win
 if n_elements(velclt) eq 0 then velclt=0
 if n_elements(center) eq 0 then center=0 else center=1
 if n_elements(irisclt) eq 0 then airisclt=0 else airisclt=1
 if n_elements(aiaclt) eq 0 then aaiaclt=0 else aaiaclt=1
 if n_elements(bclt) eq 0 then abclt=0 else abclt=1
 if n_elements(nocolor) eq 0 then nocolor=0 else nocolor=1
 if n_elements(bottom) eq 0 then bottom=0
 if n_elements(zm) eq 0 then zm=0
 if aaiaclt eq 1 then if aiaclt eq 0 then begin
	 print, ' '
	 print, ' >> aiaclt = 094 , 131 , 171 , 193 , 211 , 304 , 335 , 1600 , 1700 '
	 print, ' '
	 stop
 endif
 if n_elements(xcc) eq 0 then xcc=1
 if n_elements(ycc) eq 0 then ycc=1
 if n_elements(cc) ne 0 then begin
	 xcc = cc
	 ycc = cc
 endif else cc=1
 if n_elements(textseries) eq 0 then atextseries=0 else atextseries=1
 if n_elements(zm) eq 0 then zm=0
 if n_elements(val) eq 0 then val=0
 if n_elements(actual) eq 0 then actual=0
 if n_elements(myclt) eq 0 then myclt=0
 if n_elements(w) eq 0 then w=14
 if n_elements(revclt) eq 0 then arevclt=0 else arevclt=1
 if n_elements(xpos) eq 0 then plxpos=0 else plxpos=1
 if n_elements(ypos) eq 0 then plypos=0 else plypos=1
 if n_elements(tif) eq 0 then atiffsavedir=0 else atiffsavedir=1
 if n_elements(eps) eq 0 then aeps=0 else aeps=1
 if n_elements(sizeeps) eq 0 then epssize=[10.,30.] else epssize=sizeeps
 if n_elements(smt) eq 0 then smt=1
 if n_elements(nost) eq 0 then stsj=0 else stsj=1
 if n_elements(imno) eq 0 then imno=0
 if n_elements(hmiclt) eq 0 then hmiclt=0
 if n_elements(scan) eq 0 then scan=0 else scan=1
 if n_elements(contrast) eq 0 then contrast=0
 if n_elements(click) eq 0 then click=0
 if n_elements(gamma) eq 0 then agamma=0 else agamma=1
 if n_elements(wfits) eq 0 then wfits=0
 if n_elements(filename) eq 0 then filename='sjim'
 if n_elements(savedir) eq 0 then savedir='./'
 if n_elements(mac) eq 0 then amac=0 else amac=1
 if n_elements(fps) eq 0 then fps=20.
 if n_elements(nohist) eq 0 then nohist=0
 if n_elements(clockcolor) eq 0 then clockcolor=cgColor('Black')
 if n_elements(stat) eq 0 then stat=0
 if n_elements(dm) eq 0 then dm=0 else dm=1
 if n_elements(ctfile) eq 0 then $
  	ctfile = '~/idlLibrary/doppler_colortable/colortable_Doppler_supersonic4.tbl'
 if n_elements(axes) eq 0 then axes=0
 if n_elements(clip) eq 0 then aclip=0 else aclip=1
 if n_elements(ocontour) eq 0 then ocontour=0
 if n_elements(oc_color) eq 0 then oc_color=111
 if n_elements(oc_thick) eq 0 then oc_thick=1
 if n_elements(oc_fill) eq 0 then oc_fill=0
 if n_elements(oc_nlevels) eq 0 then oc_nlevels=1
 if n_elements(nobar) eq 0 then nobar=0
 if n_elements(rms) eq 0 then rms=0
 if n_elements(cube) eq 0 then acube=0 else acube=1
 if n_elements(mcube) eq 0 then amcube=0 else amcube=1
 if n_elements(mv) eq 0 then mv=0
 if mv ne 0 and n_elements(mcube) eq 0 then amcube=1
 if n_elements(ref) eq 0 then aref=0 else aref=1
 if n_elements(cb) eq 0 then cb=0
 if keyword_set(title) then title='[ '+strtrim(w,2)+' ] '+title else title='[ '+strtrim(w,2)+' ]'
 if keyword_set(xtitle) then xtitle=xtitle else xtitle=' '
 if keyword_set(ytitle) then ytitle=ytitle else ytitle=' '
 if keyword_set(ztitle) then ztitle=ztitle+'!C' else ztitle=' '
 if n_elements(scale) eq 0 then ascale=0 else begin
	 if n_elements(scale) ne 2 then begin
		 print, ' --> sclae should be an array of two elements!'
		 stop
	 endif
	 ascale=1
 endelse
	 print, ''
 ; if n_elements(ct) eq 0 then ct=0
 if n_elements(clbcolor) eq 0 then clbcolor='yellow'
 if n_elements(fits) eq 0 then fits=0
 if n_elements(crispex) eq 0 then acrispex=0 else begin
	 if n_elements(crispex) eq 2 OR n_elements(crispex) eq 4 OR n_elements(crispex) eq 5 then acrispex=1 else begin
		 print, ' --> crispex should be an array of 2, 4 or 5 elements!'
		 print, ' ----> 2-elements: crispex=[cube-number, frame-number]'
		 print, ' ----> 4-elements: crispex=[im-cube-number, sp-cube-number, wavelength-position-index, scan-number]'
		 print, ' ----> 5-elements: crispex=[im-cube-number, sp-cube-number, wavelength-position-index, scan-number, IQUV-index]'
		 print, ' '
		 stop
	 endelse
 endelse
 if n_elements(f0) eq 0 then f0=0
 if n_elements(momfbd) eq 0 then momfbd=0
 
 if not mv then begin
 
 ; pf0 = strpos(image, '.', /reverse_search)
 ; imnamei = strmid(image, pf0)
 ; if fits OR imnamei eq '.fits' OR imnamei eq '.fits.gz' then begin
 ; 	 im=readfits(image, /silent)
 ; 	 image=im
 ; endif

 if fits then begin
   	 im=readfits(image, /silent)
   	 image=im
 endif
 
 ; ssnum = strsplit(imnamei, length=imnumlength)
 ; if f0 OR imnumlength eq 8 then begin
 ; 	fzread, im, image, h
 ; 	image=im
 ; endif
 
 if momfbd then begin
 	 image=red_readdata(image)
 endif
 
 if f0 then begin
 	fzread, im, image, h
 	image=im
 endif
 
 in = where(~finite(image), /null) & image(in) = median(image)
 
 if n_elements(sideclip) eq 1 then begin
	 aclip = 1
	 szim = size(image)
	 clip = [sideclip,szim[1]-sideclip-1,sideclip,szim[2]-sideclip-1]
 endif
 
 if agamma then image=GmaScl(image,gamma=gamma)
 
 if nocolor eq 0 then loadct, ct, /SILENT, bottom=bottom, ncolor=ncolor
 if velclt then begin
	 zrange=minmaxinv(image,/nan,perc=99.9)
	 userlct,neutral=0,glltab=7,/full,verbose=0, $
	        center=256.*(0.-zrange(0)) / (zrange(1)-zrange(0))
 endif
 if aaiaclt then aia_lct,r,g,b,wavelnth=aiaclt,/load
 if airisclt then IRIS_LCT, irisclt, r, g, b 
 if hmiclt then begin
	 restore, '~/idlLibrary/doppler_colortable/HMIclt_new.save'
	 tvlct, R, G, B 
 endif
 if myclt then userlct,/full,verbose=0,coltab=nnn
 if abclt eq 1 then begin
	 topColor = ncolor 
	 NColors= ncolor
	 loadct, bclt, file='~/idlLibrary/doppler_colortable/brewer.tbl', bottom=bottom, ncolor=ncolor
 endif
 
 if acrispex then begin
	if n_elements(crispex) eq 2 then begin
		ifim = crispex[0] ; selected cube number
		WLi = crispex[1] ; scan number
		fcube, f
		if WLi eq -1 then begin
			if n_elements(fr) eq 0 then begin
				print, ' '
				print, ' ---> Range of frames can be defined as: fr = [a,b] '
				print, ' '
				lp_header, f[ifim], nt=numim
				fr=[0, numim-1]
			endif
			imtemp = lp_get(f[ifim],0)
		    sizeIM = SIZE(imtemp, /DIMENSIONS)
			nxt=sizeIM[0]  &  nyt=sizeIM[1]
			print, "     "
			print, "To exit the movie, strike any key."
			print, "     "
			window, w, retain=2, xsize=nxt/xcc, ysize=nyt/ycc, $
				title='Press any key to exit', xpos=500
			whd = !d.window
			WHILE (get_kbrd(0) EQ '') DO BEGIN
			for mk=fr[0], fr[1] do begin
				im = lp_get(f[ifim],mk)
				im = smooth(im,smt)
				if aclip then im = im[clip[0]:clip[1],clip[2]:clip[3]]
				if actual then tvscl, congrid(iris_histo_opt(im),nxt/xcc,nyt/ycc), /nan else $
					tvscl, congrid(iris_histo_opt(im),nxt/xcc,nyt/ycc, /INTERP, /CENTER, /MINUS_ONE, cubic=-0.5), /nan 
	   	 	 	if cb then cgColorbar, Range=[min(im),max(im)], /vertical, color=clbcolor
	   		 	wait, 1./fps
				if get_kbrd(0) ne '' then GOTO, fhere1
			endfor
			ENDWHILE
			fhere1: wdelete, whd & done
			;wdelete, whd & done
			stop
		endif else image = lp_get(f[ifim],WLi)
	endif
	if n_elements(crispex) eq 4 then begin
		ifim = crispex[0] ; selected im-cube number
		ifsp = crispex[1] ; selected sp-cube number
		WLi = crispex[2] ; wavelength-position index in one full scan.
		iscan = crispex[3]  ; scan number
		fcube, f
		lp_header, f[ifsp], nx=nwl
		if WLi eq -1 OR iscan eq -1 then begin
			if n_elements(fr) eq 0 then begin
				print, ' '
				print, ' ---> Range of frames can be defined as: fr = [a,b] '
				print, ' '
				lp_header, f[ifsp], nx=numwl, ny=numim
				if WLi eq -1 then fr=[0, numim-1] else fr=[0, numwl-1]
			endif
			imtemp = lp_get(f[ifim],0)
		    sizeIM = SIZE(imtemp, /DIMENSIONS)
			nxt=sizeIM[0]  &  nyt=sizeIM[1]
			print, "     "
			print, "To exit the movie, strike any key."
			print, "     "
			window, w, retain=2, xsize=nxt/xcc, ysize=nyt/ycc, $
				title='Press any key to exit', xpos=500
			whd = !d.window
			WHILE (get_kbrd(0) EQ '') DO BEGIN
			for mk=fr[0], fr[1] do begin
				if WLi eq -1 then im = lp_get(f[ifim],mk+(nwl*iscan)) else $
					im = lp_get(f[ifim],WLi+(nwl*mk))
				im = smooth(im,smt)
				if aclip then im = im[clip[0]:clip[1],clip[2]:clip[3]]
				if actual then tvscl, congrid(iris_histo_opt(im),nxt/xcc,nyt/ycc), /nan else $
					tvscl, congrid(iris_histo_opt(im),nxt/xcc,nyt/ycc, /INTERP, /CENTER, /MINUS_ONE,cubic=-0.5), /nan 
	   	 	 	if cb then cgColorbar, Range=[min(im),max(im)], /vertical, color=clbcolor
	   		 	wait, 1./fps
				if get_kbrd(0) ne '' then GOTO, fhere2
			endfor
			ENDWHILE
			fhere2: wdelete, whd & done
			;wdelete, whd & done
			stop
		endif else image = lp_get(f[ifim],WLi+(nwl*iscan))
	endif
	if n_elements(crispex) eq 5 then begin
		ifim = crispex[0] ; selected im-cube number
		ifsp = crispex[1] ; selected sp-cube number
		WLi = crispex[2] ; wavelength-position index in one full scan.
		iscan = crispex[3]  ; scan number
		istokes = crispex[4]  ; IQUV-Stokes index number
		fcube, f
		lp_header, f[ifsp], nx=nwl
		if WLi eq -1 OR iscan eq -1 OR istokes eq -1 then begin
			if n_elements(fr) eq 0 then begin
				print, ' '
				print, ' ---> Range of frames can be defined as: fr = [a,b] '
				print, ' '
				lp_header, f[ifsp], nx=numwl, ny=numim
				if WLi eq -1 then fr=[0, numwl-1]
				if iscan eq -1 then fr=[0, numim-1]
				if istokes eq -1 then fr=[0,3]
			endif
			imtemp = lp_get(f[ifim],0)
		    sizeIM = SIZE(imtemp, /DIMENSIONS)
			nxt=sizeIM[0]  &  nyt=sizeIM[1]
			print, "     "
			print, "To exit the movie, strike any key."
			print, "     "
			window, w, retain=2, xsize=nxt/xcc, ysize=nyt/ycc, $
				title='Press any key to exit', xpos=500
			whd = !d.window
			WHILE (get_kbrd(0) EQ '') DO BEGIN
			for mk=fr[0], fr[1] do begin
				if WLi eq -1 then im = lp_get(f[ifim],(mk+(nwl*istokes))+(4.*nwl*iscan))
				if iscan eq -1 then im = lp_get(f[ifim],(WLi+(nwl*istokes))+(4.*nwl*mk))
				if istokes eq -1 then im = lp_get(f[ifim],(WLi+(nwl*mk))+(4.*nwl*iscan))
				im = smooth(im,smt)
				if aclip then im = im[clip[0]:clip[1],clip[2]:clip[3]]
				if actual then tvscl, congrid(iris_histo_opt(im),nxt/xcc,nyt/ycc), /nan else $
					tvscl, congrid(iris_histo_opt(im),nxt/xcc,nyt/ycc, /INTERP, /CENTER, /MINUS_ONE,cubic=-0.5), /nan 
	   	 	 	if cb then cgColorbar, Range=[min(im),max(im)], /vertical, color=clbcolor
	   		 	wait, 1./fps
				if get_kbrd(0) ne '' then GOTO, fhere3
			endfor
			ENDWHILE
			fhere3: wdelete, whd & done
			;wdelete, whd & done
			stop
		endif else image = lp_get(f[ifim],(WLi+(nwl*istokes))+(4.*nwl*iscan))
	endif
 endif

 if acube then begin
	 if n_elements(cube) eq 3 then begin
		 if cube[0] eq -1 and cube[1] eq -1 then imout = reform(image(*,*,cube[2]))
		 if cube[0] eq -1 and cube[2] eq -1 then imout = reform(image(*,cube[1],*))
		 if cube[1] eq -1 and cube[2] eq -1 then imout = reform(image(cube[0],*,*))
		 if cube[0] eq -100 or cube[1] eq -100 or cube[2] eq -100 then begin
 		    sizeIM = SIZE(image, /DIMENSIONS)
 			nxt=sizeIM[0]  &  nyt=sizeIM[1]  &  ntt=sizeIM[2]
			if cube[0] eq -100 then nt = nxt
			if cube[1] eq -100 then nt = nyt
			if cube[2] eq -100 then nt = ntt
			print, "     "
			print, "To exit the movie, strike any key."
			print, "     "
			window, w, retain=2, xsize=nxt/xcc, ysize=nyt/ycc, $
				title='Press any key to exit', xpos=500
			whd = !d.window
			WHILE (get_kbrd(0) EQ '') DO BEGIN
			for mk=0, nt-1 do begin
				if cube[0] eq -100 then im = reform(image(mk,*,*))
				if cube[1] eq -100 then im = reform(image(*,mk,*))
				if cube[2] eq -100 then im = reform(image(*,*,mk))
				im = smooth(im,smt)
				if aclip then im = im[clip[0]:clip[1],clip[2]:clip[3]]
				if actual then tvscl, congrid(iris_histo_opt(im),nxt/xcc,nyt/ycc), /nan else $
					tvscl, congrid(iris_histo_opt(im),nxt/xcc,nyt/ycc, /INTERP, /CENTER, /MINUS_ONE,cubic=-0.5), /nan 
	   	 	 	if cb then cgColorbar, Range=[min(im),max(im)], /vertical, color=clbcolor
	   		 	wait, 1./fps
				if get_kbrd(0) ne '' then GOTO, fhere5
			endfor
			ENDWHILE
			fhere5: wdelete, whd
			stop
	 	 endif
	 endif
	 if n_elements(cube) eq 4 then begin
		 if cube[0] eq -1 and cube[1] eq -1 then imout = reform(image(*,*,cube[2],cube[3]))
		 if cube[0] eq -1 and cube[2] eq -1 then imout = reform(image(*,cube[1],*,cube[3]))
		 if cube[0] eq -1 and cube[3] eq -1 then imout = reform(image(*,cube[1],cube[2],*))
		 if cube[1] eq -1 and cube[2] eq -1 then imout = reform(image(cube[0],*,*,cube[3]))
		 if cube[1] eq -1 and cube[3] eq -1 then imout = reform(image(cube[0],*,cube[2],*))
		 if cube[2] eq -1 and cube[3] eq -1 then imout = reform(image(cube[0],cube[1],*,*))
		 if cube[0] eq -100 or cube[1] eq -100 or cube[2] eq -100 or cube[3] eq -100 then begin
 		    sizeIM = SIZE(image, /DIMENSIONS)
 			nxt=sizeIM[0]  &  nyt=sizeIM[1]  &  ntt=sizeIM[2]  &  nzt=sizeIM[3]
			if cube[0] eq -100 then nt = nxt
			if cube[1] eq -100 then nt = nyt
			if cube[2] eq -100 then nt = ntt
			if cube[3] eq -100 then nt = nzt
			print, "     "
			print, "To exit the movie, strike any key."
			print, "     "
			window, w, retain=2, xsize=nxt/xcc, ysize=nyt/ycc, $
				title='Press any key to exit', xpos=500
			whd = !d.window
			WHILE (get_kbrd(0) EQ '') DO BEGIN
			for mk=0, nt-1 do begin
				if cube[0] eq -100 and cube[1] eq -1 and cube[2] eq -1 then im = reform(image(mk,*,*,cube[3]))
				if cube[0] eq -100 and cube[2] eq -1 and cube[3] eq -1 then im = reform(image(mk,cube[1],*,*))
				if cube[0] eq -100 and cube[1] eq -1 and cube[3] eq -1 then im = reform(image(mk,*,cube[2],*))
				if cube[1] eq -100 and cube[0] eq -1 and cube[2] eq -1 then im = reform(image(*,mk,*,cube[3]))
				if cube[1] eq -100 and cube[2] eq -1 and cube[3] eq -1 then im = reform(image(cube[0],mk,*,*))
				if cube[1] eq -100 and cube[0] eq -1 and cube[3] eq -1 then im = reform(image(*,mk,cube[2],*))
				if cube[2] eq -100 and cube[1] eq -1 and cube[0] eq -1 then im = reform(image(*,*,mk,cube[3]))
				if cube[2] eq -100 and cube[0] eq -1 and cube[3] eq -1 then im = reform(image(*,cube[1],mk,*))
				if cube[2] eq -100 and cube[1] eq -1 and cube[3] eq -1 then im = reform(image(cube[0],*,mk,*))
				if cube[3] eq -100 and cube[1] eq -1 and cube[2] eq -1 then im = reform(image(cube[0],*,*,mk))
				if cube[3] eq -100 and cube[2] eq -1 and cube[0] eq -1 then im = reform(image(*,cube[1],*,mk))
				if cube[3] eq -100 and cube[1] eq -1 and cube[0] eq -1 then im = reform(image(*,*,cube[2],mk))
				im = smooth(im,smt)
				if aclip then im = im[clip[0]:clip[1],clip[2]:clip[3]]
				if actual then tvscl, congrid(iris_histo_opt(im),nxt/xcc,nyt/ycc), /nan else $
					tvscl, congrid(iris_histo_opt(im),nxt/xcc,nyt/ycc, /INTERP, /CENTER, /MINUS_ONE,cubic=-0.5), /nan 
	   	 	 	if cb then cgColorbar, Range=[min(im),max(im)], /vertical, color=clbcolor
	   		 	wait, 1./fps
				if get_kbrd(0) ne '' then GOTO, fhere7
			endfor
			ENDWHILE
			fhere7: wdelete, whd
			stop
	 	 endif
	 endif
	 image = imout
 endif

 imageORG = image

 if aclip then image = image[clip[0]:clip[1],clip[2]:clip[3]]
 if ascale then image = bytscl(image,scale[0],scale[1]) else image = bytscl(image,min(image),max(image))

 sizeIM = SIZE(image, /DIMENSIONS)
 nx=sizeIM[0]
 ny=sizeIM[1]
 
 if n_elements(mask) eq 0 then mask=fltarr(nx/xcc,ny/ycc)
 
 ct = 0
 !P.Background = 255
 ct = clt
 
 if aeps eq 1 and acrispex eq 0 then sjeps, size=epssize
 
 if aeps eq 0 then  begin
	 if not zm then begin
	 if plxpos eq 0 and plypos eq 0 then window, w, xsize=nx/xcc, ysize=ny/ycc, title=title else $
		 window, w, xsize=nx/xcc, ysize=ny/ycc, title=title, xpos=xpos, ypos=ypos
	 endif
 endif

 image = smooth(image,smt)
 
 if n_elements(reverse) ne 0 then image=reverse(image,reverse)
 if n_elements(rot) ne 0 then image=rotate(image,rot)
 
 if not axes then begin
 if not nohist then begin
	 if actual then if not zm then tvscl, congrid(iris_histo_opt(image),nx/xcc,ny/ycc)  else $
	 cgzimage, congrid(iris_histo_opt(image),nx/xcc,ny/ycc)
	 if not actual then if not zm then tvscl, congrid(iris_histo_opt(image),nx/xcc,ny/ycc, /INTERP, /CENTER, /MINUS_ONE,cubic=-0.5)  else $
	 cgzimage, congrid(iris_histo_opt(image),nx/xcc,ny/ycc, /INTERP, /CENTER, /MINUS_ONE,cubic=-0.5)
 endif
 if nohist then begin
	 if not actual then if not zm then $
	 tvscl, congrid(image,nx/xcc,ny/ycc,/INTERP, /CENTER, /MINUS_ONE, cubic=-0.5), /nan  else $
		 cgzimage, congrid(image,nx/xcc,ny/ycc, /INTERP, /CENTER, /MINUS_ONE,cubic=-0.5)
 endif
 if nohist then begin
	 if actual then if not zm then $
	 tvscl, congrid(image,nx/xcc,ny/ycc), /nan  else $
		 cgzimage, congrid(image,nx/xcc,ny/ycc)
 endif
 if cb then cgColorbar, Range=[min(imageORG),max(imageORG)], /vertical, color=clbcolor
 endif
 
 if axes then begin
 xrg1=[0,sizeIM[0]-1]
 yrg1=[0,sizeIM[1]-1]
 image = imageORG
 !p.charsize=1.5
 !x.thick=2  
 !y.thick=2
 if actual then imagei = congrid(iris_histo_opt(image),nx/xcc,ny/ycc) else $
	 imagei = congrid(iris_histo_opt(image),nx/xcc,ny/ycc, /INTERP, /CENTER, /MINUS_ONE,cubic=-0.5)
 mask = congrid(mask,nx/xcc,ny/ycc, /INTERP, /CENTER, /MINUS_ONE,cubic=-0.5)
 zrg1=minmax(image,/nan)
 if nnocolor eq 1 then userlct,/full,verbose=0,coltab=nnn
 image_cont_sjnew, imagei,xrange=xrg1,yrange=yrg1, nobar=nobar, zrange=zrg1, $
		      contour=ocontour, nocolor=nnocolor, $
			  xtitle=xtitle, ytitle=ytitle, ztitle=ztitle,  $
		      exact=1, $ ;each pixel is plotted
		      aspect=1, $ ;if 1 ==> aspect ratio is preserved
		      cutaspect=1, $ ;plot is scaled down to aspect
              barpos=1, $ ;z-position scale (0=left, 1=top, 2=right, 3=bottom)
			  zlen=-0.4, distbar=0, $  ; zaxislen , colorbar distance
			  barthick=0, $
			  oc_im = mask, oc_color=oc_color, oc_thick=oc_thick, oc_nlevels=oc_nlevels, $
			  loadct_im = ct, noxval=0, zticks=6, dm=dm, ctfile=ctfile, oc_fill=oc_fill
 endif

 if aeps then if amac eq 0 then sjendeps_noclip, file=filename, outdir=savedir
 if aeps then if amac eq 1 then sjendeps, file=filename, outdir=savedir

 if rms then begin
	 rmsCont = stddev(imageORG)/mean(imageORG)
	 p, ' '
	 p, ' +++++++++++++++++++++++++++++++++++'
	 p, ' '
	 p, ' RMS intensity contrast: '+strtrim(rmsCont,2)
	 p, ' '
	 p, ' +++++++++++++++++++++++++++++++++++'
	 p, ' '
 endif
 
 if stat then sjst, imageORG

 if click then begin
	 num_points=30
	 qt=0
	 first=1
	 !mouse.button = 2
	 while (!mouse.button ne 4) do begin
		 cursor,x,y,/dev, /up
		 print, x*cc, y*cc
	     if (!mouse.button eq 4) then break
	     if first eq 1 then begin
	        coord_x=[x*cc] 
	        coord_y=[y*cc]
	        first=0
	     endif else begin
	        coord_x=[coord_x, x*cc]
	        coord_y=[coord_y, y*cc]
	        ncoordx = n_elements(coord_x)
	        ssx=intarr(ncoordx)
	        for i=0, n_elements(coord_x)-1 do ssx(i)=coord_x[i]
	        ncoordy = n_elements(coord_y)
	        ssy=intarr(ncoordy)
	        for i=0, n_elements(coord_y)-1 do ssy(i)=coord_y[i]
	     endelse
	endwhile
	print, ' '
	print, '------ Coordinates of the selected points:'
	print, 'x =', ssx
	print, 'y =', ssy
	print, '------------------------------------------'
	print, ' '
 endif

 if val then begin
 	CR=string("15B)
 	format='"X:",A," ; Y:",A," ; Z:",A,A,$'
 	format='("  DATA: ",'+format+')
 	device,GET_GRAPHICS=orig_mode
 	!mouse.button = 2
 	while (!mouse.button ne 4) do begin
		cursor, x, y, /dev, /change
		print, string(x*cc),string(y*cc),string(imageORG(x*cc,y*cc)),CR,FORMAT=format
		if (!mouse.button eq 4) then break
	endwhile
 endif

 if contrast then begin
	 cgStretch, imageORG
	 retall
 endif

 image = imageORG
 
 ; if wfits then writefits, filename+'.fits', image
 
 endif
 
 if mv then begin
	 
	 if n_elements(sideclip) eq 1 then begin
		 aclip = 1
		 szim = size(image)
		 clip = [sideclip,szim[1]-sideclip-1,sideclip,szim[2]-sideclip-1]
	 endif
	 
	 if nocolor eq 0 then loadct, clt, /SILENT, bottom=bottom, ncolor=ncolor
	 if myclt then userlct,/full,verbose=0,coltab=nnn
	 
	 if n_elements(time) eq 0 then atime=0 else atime=1
	 if atime then device, decomposed=1
	 
	 if not amcube then begin
		 imagename = image
		 searchpat=image
		 fl=file_search(searchpat)
		 nim=n_elements(fl)
		 
		 if aref then begin
			 refname = ref
			 searchpatr=ref
			 flr=file_search(searchpatr)
			 nimr=n_elements(flr)
		 endif

		 if fits then begin
			 im=readfits(fl[0], /silent)
		 	 image=im
			 if aclip then image = image[clip[0]:clip[1],clip[2]:clip[3]]
			 if aref then begin
				imr=readfits(flr[0], /silent)
				if aclip then imr = imr[clip[0]:clip[1],clip[2]:clip[3]]
			endif
		 endif

		 if f0 then begin
		 	fzread, im, fl[0], h
		 	image=im
			if aclip then image = image[clip[0]:clip[1],clip[2]:clip[3]]
			 if aref then begin
				fzread, imr, flr[0], h
				if aclip then imr = imr[clip[0]:clip[1],clip[2]:clip[3]]
			endif
		 endif
		 
		 if momfbd then begin
		 	image=red_readdata(fl[0])
		  	if aclip then image = image[clip[0]:clip[1],clip[2]:clip[3]]
		  	if aref then begin
				imr=red_readdata(flr[0])
		  		if aclip then imr = imr[clip[0]:clip[1],clip[2]:clip[3]]
		  	endif
		 endif
		 
		 in = where(~finite(image), /null) & image(in) = median(image)
		 if aref then begin
			 in = where(~finite(imr), /null) & imr(in) = median(imr)
		 endif
		 
		 if stat then sjst, image
		 
		 sizeIM = SIZE(image, /DIMENSIONS)
		 nx=sizeIM[0]
		 ny=sizeIM[1]
		 
		 if aref then begin
   		 sizeIM = SIZE(imr, /DIMENSIONS)
   		 nxr=sizeIM[0]
   		 nyr=sizeIM[1]
			 if nx ne nxr OR ny ne nyr or nim ne nimr then begin
				 print, ' '
				 print, ' >>>> Dimensions of the two series are not equal!'
				 print, ' '
				 stop
			 endif
	 	 endif
		 
		 i0=fltarr(nim)
		 print, "     "
		 print, "To exit the movie, strike any key."
		 print, "     "
		 
		 if imno then begin
			imnoo = fltarr(nim)
			for j=0L, nim-1 do begin
	 	        fn=fl[j]
				if f0 then begin
					p0=strpos(fn, '..')
	 	        	p1=strpos(fn, '.', /reverse_search)
	 	        	no=strmid(fn, p0+2, p1-(p0+2))
	 	        	imnoo[j]=no
				endif
		  	endfor
		  	indx=sort(imnoo)
		 	fl=fl[indx]
			if aref then begin
				imnoor = fltarr(nim)
				for j=0L, nim-1 do begin
		 	        fn=flr[j]
					if f0 then begin
						p0=strpos(fn, '..')
		 	        	p1=strpos(fn, '.', /reverse_search)
		 	        	no=strmid(fn, p0+2, p1-(p0+2))
		 	        	imnoor[j]=no
					endif
			  	endfor
			  	indxr=sort(imnoor)
			 	flr=flr[indxr]
			endif
	 	 endif
		 
		 if not aref then begin
		 window, w, retain=2, xsize=nx/xcc, ysize=ny/ycc, $
			title='Press any key to exit', xpos=500
	 	 endif else begin
		 window, 0, retain=2, xsize=nx/xcc, ysize=ny/ycc, $
			title=imagename+' | Press any key to exit', xpos=5
		 window, 2, retain=2, xsize=nx/xcc, ysize=ny/ycc, $
			title=refname+' | Press any key to exit', xpos=(nx/xcc)+10
	 	 endelse
	 

		 if aaiaclt then aia_lct,r,g,b,wavelnth=aiaclt,/load
		 if airisclt then IRIS_LCT, irisclt, r, g, b 
		 if hmiclt then begin
			 hmiclt = readtext('~/src/diffusivity-II/HMIclt_imax2.txt')
			 R = ((reform(hmiclt[0,*]))/max(reform(hmiclt[0,*])))*255
			 G = ((reform(hmiclt[1,*]))/max(reform(hmiclt[1,*])))*255
			 B = ((reform(hmiclt[2,*]))/max(reform(hmiclt[2,*])))*255
			 tvlct, R, G, B
		 endif
		 if abclt eq 1 then begin
			 topColor = ncolor 
			 NColors= ncolor
			 loadct, bclt, file='~/idlLibrary/doppler_colortable/brewer.tbl', bottom=bottom, ncolor=ncolor
		 endif
		 if velclt then begin
			 zrange=minmaxinv(im,/nan,perc=99.9)
			 userlct,neutral=0,glltab=7,/full,verbose=0, $
			        center=256.*(0.-zrange(0)) / (zrange(1)-zrange(0))
		 endif
		 
		 if scan then begin
			 prof = fltarr(nim)
			 for i=0L, nim-1 do begin
				 if fits then begin
					 im=readfits(fl[i], /silent)
					 if aclip then im = im[clip[0]:clip[1],clip[2]:clip[3]]
					 if arevclt then im = -1*im
				 endif
				 if f0 then begin
				 	fzread, im, fl[i], h
					if aclip then im = im[clip[0]:clip[1],clip[2]:clip[3]]
					if arevclt then im = -1*im
				 endif
				 if momfbd then begin
					 im=red_readdata(fl[i])
				 	 if aclip then im = im[clip[0]:clip[1],clip[2]:clip[3]]
				     if arevclt then im = -1*im
				 endif
				 prof[i] = mean(im[50:nx-50,50:ny-50])
			 endfor
		 endif
		 
		 whd = !d.window
		 WHILE (get_kbrd(0) EQ '') DO BEGIN
		 for i=0L, nim-1 do begin
			 if fits then begin
				 im=readfits(fl[i], /silent)
				 if aclip then im = im[clip[0]:clip[1],clip[2]:clip[3]]
				 if arevclt then im = -1*im
	 			 if aref then begin
	 				imr=readfits(flr[i], /silent)
	 				if aclip then imr = imr[clip[0]:clip[1],clip[2]:clip[3]]
					if arevclt then imr = -1*imr
	 			endif
			 endif

			 if f0 then begin
			 	fzread, im, fl[i], h
				if aclip then im = im[clip[0]:clip[1],clip[2]:clip[3]]
				if arevclt then im = -1*im
				 if aref then begin
					fzread, imr, flr[i], h
					if aclip then imr = imr[clip[0]:clip[1],clip[2]:clip[3]]
					if arevclt then imr = -1*imr
				endif
			 endif
			 
			 if momfbd then begin
				 im=red_readdata(fl[i])
			 	 if aclip then im = im[clip[0]:clip[1],clip[2]:clip[3]]
			 	 if arevclt then im = -1*im
			 	 if aref then begin
					 imr=red_readdata(flr[i])
			 	 	 if aclip then imr = imr[clip[0]:clip[1],clip[2]:clip[3]]
			 		 if arevclt then imr = -1*imr
			 	 endif
			 endif
			 
			 in = where(~finite(im), /null) & im(in) = median(im)
			 if aref then begin
				 in = where(~finite(imr), /null)
				 imr(in) = median(imr)
			 endif
			 
			 if not actual then begin
				 if aref then begin
					wset, 0
					if agamma then tvscl, GmaScl(congrid(iris_histo_opt(im),nxt/xcc,nyt/ycc,/INTERP, /CENTER, /MINUS_ONE, $
						cubic=-0.5),gamma=gamma), /nan  else $
				 	tvscl, congrid(iris_histo_opt(im),nx/xcc,ny/ycc, /INTERP, /CENTER, /MINUS_ONE,cubic=-0.5), /nan 
					if atime then sjclock, time[i], pos=[10,(ny/ycc)-((nx/ycc)*0.14)-10], size=(nx/xcc)*0.14, thick=4, /dev, col=clockcolor
					if atiffsavedir then $
						void = cgSnapshot(filename=savedir+'im'+strtrim(long(1000+i),2), quality=100, /PNG, /NODIALOG)
				 	wset, 2
					if agamma then tvscl, GmaScl(congrid(iris_histo_opt(imr),nxt/xcc,nyt/ycc,/INTERP, /CENTER, /MINUS_ONE, $
						cubic=-0.5),gamma=gamma), /nan  else $
					tvscl, congrid(iris_histo_opt(imr),nx/xcc,ny/ycc, /INTERP, /CENTER, /MINUS_ONE,cubic=-0.5), /nan 
					if atiffsavedir then $
					void = cgSnapshot(filename=savedir+'imr'+strtrim(long(1000+i),2), quality=100, /PNG, /NODIALOG)
				 endif else begin
					if agamma then tvscl, GmaScl(congrid(iris_histo_opt(im),nxt/xcc,nyt/ycc,/INTERP, /CENTER, /MINUS_ONE, $
						cubic=-0.5),gamma=gamma), /nan  else $
				 	tvscl, congrid(iris_histo_opt(im),nx/xcc,ny/ycc,/INTERP, /CENTER, /MINUS_ONE, cubic=-0.5), /nan 
					if atime then sjclock, time[i], pos=[10,(ny/ycc)-((nx/ycc)*0.14)-10], size=(nx/xcc)*0.14, thick=4, /dev, col=clockcolor
					if scan then begin
					cgPlot, prof
					cgPlots, prof[i], ps=16;, color=cgColor('Red')
					endif
					if atiffsavedir then $
					void = cgSnapshot(filename=savedir+'im'+strtrim(long(1000+i),2), quality=100, /PNG, /NODIALOG)
				 endelse
		 	 endif else begin
				 if aref then begin
					wset, 0
					if agamma then tvscl, GmaScl(congrid(iris_histo_opt(im),nxt/xcc,nyt/ycc),gamma=gamma), /nan  else $
				 	tvscl, congrid(iris_histo_opt(im),nx/xcc,ny/ycc), /nan 
					if atime then sjclock, time[i], pos=[10,(ny/ycc)-((ny/ycc)*0.14)-10], size=(nx/xcc)*0.14, thick=4, /dev, col=clockcolor
					if atiffsavedir then $
						void = cgSnapshot(filename=savedir+'im'+strtrim(long(1000+i),2), quality=100, /PNG, /NODIALOG)
				 	wset, 2
					if agamma then tvscl, GmaScl(congrid(iris_histo_opt(imr),nxt/xcc,nyt/ycc),gamma=gamma), /nan  else $
					tvscl, congrid(iris_histo_opt(imr),nx/xcc,ny/ycc), /nan 
					if atiffsavedir then $
					void = cgSnapshot(filename=savedir+'imr'+strtrim(long(1000+i),2), quality=100, /PNG, /NODIALOG)
				 endif else begin
					if agamma then tvscl, GmaScl(congrid(iris_histo_opt(im),nxt/xcc,nyt/ycc),gamma=gamma), /nan  else $
				 	tvscl, congrid(iris_histo_opt(im),nx/xcc,ny/ycc), /nan 
					if atime then sjclock, time[i], pos=[10,(ny/ycc)-((ny/ycc)*0.14)-10], size=(nx/xcc)*0.14, thick=4, /dev, col=clockcolor
					if scan then begin
					cgPlot, prof
					cgPlots, prof[i], ps=16;, color=cgColor('Red')
					endif
					if atiffsavedir then $
					void = cgSnapshot(filename=savedir+'im'+strtrim(long(1000+i),2), quality=100, /PNG, /NODIALOG)
				 endelse
		 	 endelse

		 	 if cb then cgColorbar, Range=[min(im),max(im)], /vertical, color=color
			 i0[i]=mean(im[50:nx-50,50:ny-50])  ; contrast
			 wait, 1./fps
			 if get_kbrd(0) ne '' then GOTO, fhere12
			 if atiffsavedir then if i eq nim-1 then GOTO, fhere12
		 endfor
		 ENDWHILE
		 fhere12: if aref then wdelete, 0, 2 else wdelete, whd
		 return
		 stop
	 endif
	 
	 if amcube then begin
		 
		 imagename = 'im'
		 refname = 'ref'
		 if aref then imri = ref
		 if fits then begin
			 imagename = image
			 im=readfits(image, /silent)
		 	 image=im
			 ;if aclip then image = image[clip[0]:clip[1],clip[2]:clip[3]]
			 if aref then begin
				 refname = ref
				 imri=readfits(ref, /silent)
				;if aclip then imri = imri[clip[0]:clip[1],clip[2]:clip[3]]
			endif
		 endif

		 if f0 then begin
			imagename = image
		 	fzread, im, image, h
		 	image=im
			;if aclip then image = image[clip[0]:clip[1],clip[2]:clip[3]]
			 if aref then begin
				refname = ref
				fzread, imri, ref, h
				;if aclip then imri = imri[clip[0]:clip[1],clip[2]:clip[3]]
			endif
		 endif
		 
		 in = where(~finite(image), /null) & image(in) = median(image)
		 if aref then begin
		 		in = where(~finite(imri), /null) & imri(in) = median(imri)
		 endif
		 
		 if stat then sjst, image
		 
		 if n_elements(mcube) eq 1 then mcube=[-1,-1,0]
		 
		 if n_elements(mcube) eq 3 then begin
			if mcube[0] eq -1 and mcube[1] eq -1 then begin
				imout = reform(image(*,*,0))
				nim = n_elements(reform(image(0,0,*)))
			endif
			if mcube[0] eq -1 and mcube[2] eq -1 then begin
				imout = reform(image(*,0,*))
				nim = n_elements(reform(image(0,*,0)))
			endif
			if mcube[1] eq -1 and mcube[2] eq -1 then begin
				imout = reform(image(0,*,*))
				nim = n_elements(reform(image(*,0,0)))
			endif
			
			if aclip then imout = imout[clip[0]:clip[1],clip[2]:clip[3]]
 		    sizeIM = SIZE(imout, /DIMENSIONS)
 			nxt=sizeIM[0]  &  nyt=sizeIM[1]
			
			print, "     "
			print, "To exit the movie, strike any key."
			print, "     "
			
			if not aref then begin
			window, w, retain=2, xsize=nxt/xcc, ysize=nyt/ycc, $
				title='Press any key to exit', xpos=500
		 	endif else begin
			window, 0, retain=2, xsize=nxt/xcc, ysize=nyt/ycc, $
				title=imagename+' | Press any key to exit', xpos=5
			window, 2, retain=2, xsize=nxt/xcc, ysize=nyt/ycc, $
				title=refname+' | Press any key to exit', xpos=(nxt/xcc)+10
		 	endelse
			
			if aaiaclt then aia_lct,r,g,b,wavelnth=aiaclt,/load
			if airisclt then IRIS_LCT, irisclt, r, g, b 
		    if hmiclt then begin
		   	 restore, '~/idlLibrary/doppler_colortable/HMIclt_new.save'
		   	 tvlct, R, G, B 
		    endif
		    if abclt eq 1 then begin
		   	 topColor = ncolor 
		   	 NColors= ncolor
		   	 loadct, bclt, file='~/idlLibrary/doppler_colortable/brewer.tbl', bottom=bottom, ncolor=ncolor
		    endif
			
			whd = !d.window
			medim = median(image)
			if aref then medimr = median(imri)
			WHILE (get_kbrd(0) EQ '') DO BEGIN
			for mk=0, nim-1 do begin
				if mcube[0] eq -1 and mcube[1] eq -1 then im = reform(image(*,*,mk))
				if mcube[0] eq -1 and mcube[2] eq -1 then im = reform(image(*,mk,*))
				if mcube[1] eq -1 and mcube[2] eq -1 then im = reform(image(mk,*,*))
				if smt gt 1 then im = smooth(im,smt)
				if aclip eq 1 then im = im[clip[0]:clip[1],clip[2]:clip[3]]
				
				if aref then begin
					if mcube[0] eq -1 and mcube[1] eq -1 then imr = reform(imri(*,*,mk))
					if mcube[0] eq -1 and mcube[2] eq -1 then imr = reform(imri(*,mk,*))
					if mcube[1] eq -1 and mcube[2] eq -1 then imr = reform(imri(mk,*,*))
					imr = smooth(imr,smt)
					if aclip eq 1 then imr = imr[clip[0]:clip[1],clip[2]:clip[3]]
				endif
				
	   			if mk eq 0 then in = where(~finite(im), /null)
				im(in) = medim
	   			if aref then begin
	   				 if mk eq 0 then inr = where(~finite(imr), /null)
	   				 imr(inr) = medimr
	   			endif
				
	   			if velclt then begin
	   				 zrange=minmaxinv(im,/nan,perc=99.9)
	   				 userlct,neutral=0,glltab=7,/full,verbose=0, $
	   				        center=256.*(0.-zrange(0)) / (zrange(1)-zrange(0))
	   			endif
				
				if not axes then begin
				
				if not actual then begin
					if aref then begin
						wset, 0
						if agamma then tvscl, GmaScl(congrid(iris_histo_opt(im),nxt/xcc,nyt/ycc,/INTERP, /CENTER, /MINUS_ONE, $
							cubic=-0.5),gamma=gamma), /nan  else $
	   			 		tvscl, congrid(iris_histo_opt(im),nxt/xcc,nyt/ycc, /INTERP, /CENTER, /MINUS_ONE,cubic=-0.5), /nan 
	   			 		if atime then sjclock, time[mk], pos=[10,(nyt/ycc)-((nxt/ycc)*0.14)-10], size=(nxt/xcc)*0.14, thick=4, /dev, col=clockcolor
						wset, 2
						if agamma then tvscl, GmaScl(congrid(iris_histo_opt(imr),nxt/xcc,nyt/ycc,/INTERP, /CENTER, /MINUS_ONE, $
							cubic=-0.5),gamma=gamma), /nan  else $
	   					tvscl, congrid(iris_histo_opt(imr),nxt/xcc,nyt/ycc, /INTERP, /CENTER, /MINUS_ONE,cubic=-0.5), /nan 
	   			 	endif else begin
						if agamma then tvscl, GmaScl(congrid(iris_histo_opt(im),nxt/xcc,nyt/ycc,/INTERP, /CENTER, /MINUS_ONE, $
							cubic=-0.5),gamma=gamma), /nan  else $
						tvscl, congrid(iris_histo_opt(im),nxt/xcc,nyt/ycc,/INTERP, /CENTER, /MINUS_ONE, cubic=-0.5), /nan
						if atime then sjclock, time[mk], pos=[10,(nyt/ycc)-((nxt/ycc)*0.14)-10], size=(nxt/xcc)*0.14, thick=4, /dev, col=clockcolor
						device, decomposed=0
						if atextseries then $
							XYOUTS, 0.1, 0.93, ALIGNMENT=0, CHARSIZE=2.5, /NORMAL, strtrim(textseries[mk],2), COLOR=FSC_Color('GOLD'), CHARTHICK=2.
						if atiffsavedir then $
							void = cgSnapshot(filename=savedir+'im'+strtrim(long(1000+mk),2), quality=100, /PNG, /NODIALOG)
					endelse
				endif else begin
	   			 	if aref then begin
						wset, 0
						if agamma then tvscl, GmaScl(congrid(iris_histo_opt(im),nxt/xcc,nyt/ycc),gamma=gamma), /nan  else $
	   			 		tvscl, congrid(iris_histo_opt(im),nxt/xcc,nyt/ycc), /nan 
	   			 		if atime then sjclock, time[mk], pos=[10,(nyt/ycc)-((nxt/ycc)*0.14)-10], size=(nxt/xcc)*0.14, thick=4, /dev, col=clockcolor
						wset, 2
						if agamma then tvscl, GmaScl(congrid(iris_histo_opt(imr),nxt/xcc,nyt/ycc),gamma=gamma), /nan  else $
	   					tvscl, congrid(iris_histo_opt(imr),nxt/xcc,nyt/ycc), /nan 
	   			 	endif else begin
						if agamma then tvscl, GmaScl(congrid(iris_histo_opt(im),nxt/xcc,nyt/ycc),gamma=gamma), /nan  else $
						tvscl, congrid(iris_histo_opt(im),nxt/xcc,nyt/ycc), /nan
						if atime then sjclock, time[mk], pos=[10,(nyt/ycc)-((nxt/ycc)*0.14)-10], size=(nxt/xcc)*0.14, thick=4, /dev, col=clockcolor
						device, decomposed=0
						if atextseries then $
							XYOUTS, 0.1, 0.93, ALIGNMENT=0, CHARSIZE=2.5, /NORMAL, strtrim(textseries[mk],2), COLOR=FSC_Color('GOLD'), CHARTHICK=2.
						if atiffsavedir then $
							void = cgSnapshot(filename=savedir+'im'+strtrim(long(1000+mk),2), quality=100, /PNG, /NODIALOG)
					endelse
				endelse
				
				if cb then cgColorbar, Range=[min(im),max(im)], /vertical, color=clbcolor
				
			    endif else begin
				    xrg1=[0,sizeIM[0]-1]
				    yrg1=[0,sizeIM[1]-1]
				    !p.charsize=1.5
				    !x.thick=2  
				    !y.thick=2
				    if not actual then imagei = congrid(iris_histo_opt(im),nxt/xcc,nyt/ycc, /INTERP, /CENTER, /MINUS_ONE,cubic=-0.5) else $
						imagei = congrid(iris_histo_opt(im),nxt/xcc,nyt/ycc)
				    zrg1=minmax(imagei,/nan)
				    if nnocolor eq 1 then userlct,/full,verbose=0,coltab=nnn
				    image_cont_sjnew, imagei,xrange=xrg1,yrange=yrg1, nobar=nobar, zrange=zrg1, $
				   		      contour=ocontour, nocolor=nnocolor, $
				   			  xtitle=xtitle, ytitle=ytitle, ztitle=ztitle,  $
				   		      exact=1, $ ;each pixel is plotted
				   		      aspect=1, $ ;if 1 ==> aspect ratio is preserved
				   		      cutaspect=1, $ ;plot is scaled down to aspect
				                 barpos=1, $ ;z-position scale (0=left, 1=top, 2=right, 3=bottom)
				   			  zlen=-0.4, distbar=0, $  ; zaxislen , colorbar distance
				   			  barthick=0, $  ; colorbar thickness
				   			  oc_im = mask, oc_color=oc_color, oc_thick=oc_thick, oc_nlevels=oc_nlevels, $
				   			  loadct_im = ct, noxval=0, zticks=6, dm=dm, ctfile=ctfile
			    
					if atextseries then $
						XYOUTS, 0.05, 0.95, ALIGNMENT=0, CHARSIZE=1.5, /NORMAL, strtrim(textseries[mk],2), COLOR=FSC_Color('Dodger Blue'), CHARTHICK=1
					
					if atiffsavedir then $
						void = cgSnapshot(filename=savedir+'im'+strtrim(long(1000+mk),2), quality=100, /PNG, /NODIALOG)
					
				endelse
				
				if atiffsavedir then if mk eq nim-1 then GOTO, fhere51
				
	   		 	wait, 1./fps
				if get_kbrd(0) ne '' then GOTO, fhere51
			endfor
			ENDWHILE
			fhere51: closeall
			return
			stop
		 endif
		 if n_elements(mcube) eq 4 then begin
			if mcube[0] eq -1 and mcube[1] eq -1 then imout = reform(image(*,*,mcube[2],mcube[3]))
			if mcube[0] eq -1 and mcube[2] eq -1 then imout = reform(image(*,mcube[1],*,mcube[3]))
			if mcube[0] eq -1 and mcube[3] eq -1 then imout = reform(image(*,mcube[1],mcube[2],*))
			if mcube[1] eq -1 and mcube[2] eq -1 then imout = reform(image(mcube[0],*,*,mcube[3]))
			if mcube[1] eq -1 and mcube[3] eq -1 then imout = reform(image(mcube[0],*,mcube[2],*))
			if mcube[2] eq -1 and mcube[3] eq -1 then imout = reform(image(mcube[0],mcube[1],*,*))
			if aclip then imout = imout[clip[0]:clip[1],clip[2]:clip[3]]
 		    sizeIM = SIZE(imout, /DIMENSIONS)
 			nxt=sizeIM[0]  &  nyt=sizeIM[1]
			print, "     "
			print, "To exit the movie, strike any key."
			print, "     "
			window, w, retain=2, xsize=nxt/xcc, ysize=nyt/ycc, $
				title='Press any key to exit', xpos=500

			if aaiaclt then aia_lct,r,g,b,wavelnth=aiaclt,/load
			if airisclt then IRIS_LCT, irisclt, r, g, b 
		    if hmiclt then begin
		   	 restore, '~/idlLibrary/doppler_colortable/HMIclt_new.save'
		   	 tvlct, R, G, B 
		    endif
		    if abclt eq 1 then begin
		   	 topColor = ncolor 
		   	 NColors= ncolor
		   	 loadct, bclt, file='~/idlLibrary/doppler_colortable/brewer.tbl', bottom=bottom, ncolor=ncolor
		    endif
   			if velclt then begin
   				 zrange=minmaxinv(im,/nan,perc=99.9)
   				 userlct,neutral=0,glltab=7,/full,verbose=0, $
   				        center=256.*(0.-zrange(0)) / (zrange(1)-zrange(0))
   			endif
			
			whd = !d.window
			WHILE (get_kbrd(0) EQ '') DO BEGIN
			for mk=0, nim-1 do begin
	   			 if fits then begin
	   				 im=readfits(fl[mk], /silent)
	   			 endif

	   			 if f0 then begin
	   			 	fzread, im, fl[mk], h
	   			 endif
				if mcube[0] eq -1 and mcube[1] eq -1 then im = reform(im(*,*,mcube[2],mcube[3]))
				if mcube[0] eq -1 and mcube[2] eq -1 then im = reform(im(*,mcube[1],*,mcube[3]))
				if mcube[0] eq -1 and mcube[3] eq -1 then im = reform(im(*,mcube[1],mcube[2],*))
				if mcube[1] eq -1 and mcube[2] eq -1 then im = reform(im(mcube[0],*,*,mcube[3]))
				if mcube[1] eq -1 and mcube[3] eq -1 then im = reform(im(mcube[0],*,mcube[2],*))
				if mcube[2] eq -1 and mcube[3] eq -1 then im = reform(im(mcube[0],mcube[1],*,*))
				im = smooth(im,smt)
				
	   			in = where(~finite(im), /null) & im(in) = median(im)
	   			if aref then begin
	   				 in = where(~finite(imr), /null)
	   				 imr(in) = median(imr)
	   			endif
				
				if aclip then im = im[clip[0]:clip[1],clip[2]:clip[3]]
				
				if agamma then im=GmaScl(im,gamma=gamma)
				if not actual then tvscl, congrid(iris_histo_opt(im),nxt/xcc,nyt/ycc,/INTERP, /CENTER, /MINUS_ONE, cubic=-0.5), /nan else $
					tvscl, congrid(iris_histo_opt(im),nxt/xcc,nyt/ycc), /nan 
	   	 	 	if cb then cgColorbar, Range=[min(im),max(im)], /vertical, color=clbcolor
				if atiffsavedir then $
					void = cgSnapshot(filename=savedir+'im'+strtrim(long(1000+mk),2), quality=100, /PNG, /NODIALOG)
	   		 	wait, 1./fps
				;i0[mk]=mean(im[50:nxt-50,50:nyt-50])
				;i0[mk]=mean(im[494:815,481:796]) 
				if get_kbrd(0) ne '' then GOTO, fhere71
				if atiffsavedir then if mk eq nim-1 then GOTO, fhere71
			endfor
			ENDWHILE
			fhere71: closeall
			return
			; plot, i0
			stop
		 endif
		 if n_elements(mcube) eq 5 then begin
			; ONLY if the individual scans are stored in tha last component: mcube[4]
			if mcube[0] eq -1 and mcube[1] eq -1 then imout = reform(image(*,*,mcube[2],mcube[3],0))
			if mcube[0] eq -1 and mcube[2] eq -1 then imout = reform(image(*,mcube[1],*,mcube[3],0))
			if mcube[0] eq -1 and mcube[3] eq -1 then imout = reform(image(*,mcube[1],mcube[2],*,0))
			if mcube[1] eq -1 and mcube[2] eq -1 then imout = reform(image(mcube[0],*,*,mcube[3],0))
			if mcube[1] eq -1 and mcube[3] eq -1 then imout = reform(image(mcube[0],*,mcube[2],*,0))
			if mcube[2] eq -1 and mcube[3] eq -1 then imout = reform(image(mcube[0],mcube[1],*,*,0))
 		    sizeIM = SIZE(imout, /DIMENSIONS)
 			nxt=sizeIM[0]  &  nyt=sizeIM[1]
			nim = n_elements(image(0,0,0,0,*))
			print, "     "
			print, "To exit the movie, strike any key."
			print, "     "
			window, w, retain=2, xsize=nxt/xcc, ysize=nyt/ycc, $
				title='Press any key to exit', xpos=500

			if aaiaclt then aia_lct,r,g,b,wavelnth=aiaclt,/load
			if airisclt then IRIS_LCT, irisclt, r, g, b 
		    if hmiclt then begin
		   	 restore, '~/idlLibrary/doppler_colortable/HMIclt_new.save'
		   	 tvlct, R, G, B 
		    endif
		    if abclt eq 1 then begin
		   	 topColor = ncolor 
		   	 NColors= ncolor
		   	 loadct, bclt, file='~/idlLibrary/doppler_colortable/brewer.tbl', bottom=bottom, ncolor=ncolor
		    endif
   			if velclt then begin
   				 zrange=minmaxinv(im,/nan,perc=99.9)
   				 userlct,neutral=0,glltab=7,/full,verbose=0, $
   				        center=256.*(0.-zrange(0)) / (zrange(1)-zrange(0))
   			endif
			
			whd = !d.window
			WHILE (get_kbrd(0) EQ '') DO BEGIN
			for mk=0, nim-1 do begin
	   			 if fits then im=readfits(fl[0], /silent)
	   			 if momfbd then im=red_readdata(fl[0])
	   			 ; if f0 then begin
	   			 ; 	fzread, im, fl[0], h
	   			 ; endif
				 im = reform(im(*,*,mcube[2],mcube[3],mk))
				; if mcube[0] eq -1 and mcube[1] eq -1 then im = reform(im(*,*,mcube[2],mcube[3],mk))
				; if mcube[0] eq -1 and mcube[2] eq -1 then im = reform(im(*,mcube[1],*,mcube[3],mk))
				; if mcube[0] eq -1 and mcube[3] eq -1 then im = reform(im(*,mcube[1],mcube[2],*,mk))
				; if mcube[1] eq -1 and mcube[2] eq -1 then im = reform(im(mcube[0],*,*,mcube[3],mk))
				; if mcube[1] eq -1 and mcube[3] eq -1 then im = reform(im(mcube[0],*,mcube[2],*,mk))
				; if mcube[2] eq -1 and mcube[3] eq -1 then im = reform(im(mcube[0],mcube[1],*,*,mk))
				; im = smooth(im,smt)
;				if aclip then im = im[clip[0]:clip[1],clip[2]:clip[3]]
				if agamma then im=GmaScl(im,gamma=gamma)
				if not actual then tvscl, congrid(iris_histo_opt(im),nxt/xcc,nyt/ycc, /INTERP, /CENTER, /MINUS_ONE, CUBIC=-0.5), /nan else $
					tvscl, congrid(iris_histo_opt(im),nxt/xcc,nyt/ycc), /nan
	   	 	 	if cb then cgColorbar, Range=[min(im),max(im)], /vertical, color=clbcolor
				if atiffsavedir then $
					void = cgSnapshot(filename=savedir+'im'+strtrim(long(1000+mk),2), quality=100, /PNG, /NODIALOG)
	   		 	wait, 1./fps
				if get_kbrd(0) ne '' then GOTO, fhere75
				if atiffsavedir then if mk eq nim-1 then GOTO, fhere75
			endfor
			ENDWHILE
			fhere75: closeall
			return
			; plot, i0
			stop
		 endif
		 ;image = imout
	 endif
	 
 endif

 image = imageoriginal
 
 if atiffsavedir then $
	void = cgSnapshot(filename=savedir+filename, quality=100, /PNG, /NODIALOG)

 print, ' '
 
 if center then sjtvellipse, 10/cc, 10/cc, (n_elements(image[*,0])/cc)/2., (n_elements(image[0,*])/cc)/2., 0, cgColor('DodgerBlue'), /dev, npoints=400
 

 return
end