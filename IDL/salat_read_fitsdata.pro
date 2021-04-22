;; --- Solar Alma Library of Auxiliary Tools (SALAT) --- 
;;================================================================================
;; IDL - FUNCTION salat_read_fitsdata.pro 
;; 
;; PURPOSE: reads in a FITS file 
;;
;; KEYWORDS: 
;;   FILENAME: Names of the FITS files. Can be a single file or an array. Wildcards * are allowed. 
;;   SPECTRALbandWINDOW: 
;;   VERBOSE:   More output. 

;; NOTE: - Should be reviewed/updated to the final FITS format.  
;;       - Should be updated such that it can handle all data products (single maps, 
;;         cubes, TP for different data levels)
;;       - Functions like removal of NaNs and Tb conversion should be done as a call
;;         to other functions
;;================================================================================
function salat_read_fitsdata, filename, nu=nu, $ 
         time=time, $ 
	     header=out_header, $ 
	     kelvin=flag_kelvin, $ 
		 external_conversion=flag_kelvin_external, $ 
	     nfmax=nfmax, istart=istart, $ 
		 cutfov=flag_fovcut, $ 
	     verbose=flag_verbose, test=flag_test 
;;=============================================================================
;; 
nu=0.0
if not keyword_set(flag_kelvin) then flag_kelvin=0
if not keyword_set(flag_kelvin_external) then flag_kelvin_external=0
if not keyword_set(flag_test) then flag_test=0
if not keyword_set(istart) then istart=0


if not keyword_set(flag_fovcut) then flag_fovcut=50 ;; --- radius in pixels for mask to exclude less reliable data further out
nval=-99999.

if not keyword_set(time) then time=0

;;=============================================================================
sbmajor = 0.9416101574897766 ;; ---  extracted from CASA. ;;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
sbminor = 0.7735859155654907 ;; ---  — II — 
;
convKTP=5900.0 ;; --- Tb offset according to White et al. (2017) 
convKTP=0.0
;;=============================================================================

;;=============================================================================
;; --- Check if data files exist --- 
;;=============================================================================
;;
if keyword_set(flag_verbose) then print,'> Check if files exist'
fn=file_search(filename, count=nf)
if nf eq 0 then message,'No FITS file found!'

if keyword_set(nfmax) then begin 
	if nfmax gt 0 then fn=fn[istart:istart+nfmax-1]
	nf=nfmax	
endif
nt=nf
if nt eq 0 then message,'No FITS file found!'
;;=============================================================================
;; --- Read data files (loop) --- 
;;=============================================================================
for i=0,nt-1 do begin
	if keyword_set(flag_verbose) then print,'> Reading '+fn[i]
	tmp=readfits(fn[i], h)
	sz=size(tmp, /dim)
	ndim=size(tmp, /n_dim)
	multitime=0
	;nt=1
	if ndim eq 4 then begin 
		multitime=1
		nt=sz[3]
	endif 	
	;;
	hd=salat_read_fitsheader(h) 
	if total(hd.dateobs_jul) eq 0.0 or multitime eq 1 then begin 
		message,'WARNING! Missing time information. Reading header extension 1.', /continue
		time=readfits(fn[i], ext=1)
	endif
	;;
	;; --- first file - set dimensions and prepare arrays --- 
	if i eq 0  then begin 
		sz=size(tmp, /dim)
		nnu=sz[2]
		;;
		if keyword_set(flag_verbose) then print,'> Prepare data mask'
		mask=replicate(1, sz[0],sz[1])
		;;	   
		if flag_fovcut gt 0 then begin
			if keyword_set(flag_verbose) then print,'> Constraining data mask'	   
			;; --- calculate radius --- 
			tx=(findgen(sz[0])-sz[0]/2.0)^2
			tx=tx#replicate(1, sz[1]) 
			ty=(findgen(sz[1])-sz[1]/2.0)^2
			ty=replicate(1, sz[0])#ty
			grid=sqrt(tx+ty)
			idx3=where(grid gt flag_fovcut, ncnt3)
			if ncnt3 gt 0 then mask[idx3]=0	 
		endif
		;; --- remove empty rows and columns --- 
		mask_row=avg(mask, 1)
		mask_col=avg(mask, 0)
		ixr=minmax(where(mask_col gt 0))
		iyr=minmax(where(mask_row gt 0))
		   
		mask=mask[ixr[0]:ixr[1],iyr[0]:iyr[1]]
		   
		nx=ixr[1]-ixr[0]+1
		ny=iyr[1]-iyr[0]+1

		beammaj=fltarr(nf)
		beammin=fltarr(nf)

		if keyword_set(flag_verbose) then print,'> Preparing data arrays.'
		if multitime eq 0 then $ 
			d=fltarr(nx,ny,nnu,nf) $ 
				else $ 
					d=fltarr(nx,ny,nnu,nf,nt)
		;;	  
		nu=fltarr(nnu)
		header=strarr(n_elements(h),nf)
		if n_elements(time) eq 1 then time=dblarr(nf)
		itime=intarr(nf)
		;help, d, nu, time, itime 
		;;

	endif	
	tnu=hd.freq+findgen(nnu)*hd.dn
		
	tmp=tmp[ixr[0]:ixr[1],iyr[0]:iyr[1],*,*]	
	header[0:n_elements(h)-1,i]=h		

	if hd.dn lt 0.0 then begin 
		;; --- negative frequency increment, reverse channel order --- 
		if keyword_set(flag_verbose) then print,'> Negative frequency increment. Reversing channel order.'
		tmp=reverse(tmp, 3)
		tnu=reverse(tnu, 1)
	endif		   

	nu=tnu


	;; --- Check for NaNs --- 
	idx1=where(finite(tmp) eq 0, ncnt1)
	idx2=where(finite(reform(tmp[*,*,64])) eq 0, ncnt2)
	idxm=where(mask eq 0, ncntm)
	;;
	if ncnt1 gt 0 then tmp[idx1]=0.0  ;; --- Remove NaNs --- 
	if ncnt2 gt 0 then mask[idx2]=0 ;; --- Exclude NaN data from mask 
	if ncntm gt 0 then begin 
		for il=0,sz[2]-1 do begin
			ttmp=reform(tmp[*,*,il])
			ttmp[idxm]=0.0
			tmp[*,*,il]=ttmp
		endfor
	endif

	;; --- get time step info --- 
	;stmp=fn[i]
	;ipos=strpos(stmp, '_no_')
	;stmp=strmid(stmp, ipos+4, 3)
	;ipos=strpos(stmp, '.20')
	;stmp=strmid(stmp, ipos+1, 3)
	;itime[i]=fix(stmp)	
	;if n_elements(time) eq 1 then  time[i]=hd.timestamp
	time[i]=reform(hd.DATEOBS_JUL)
	if flag_test eq 1 then time[i]=itime[i]*2.0
	print, i, ': ',fn[i]
	print, hd.DATEOBS_JUL, hd.dateobs
		
	;; --- Store corrected data ---	
	if multitime eq 0 then $ 
		d[*,*,*,i]=tmp $ 
			else $ 
				d=tmp
		   
	tmp=0     
endfor

;;=============================================================================
;; --- Convert to K and add temperature offset 		
;;=============================================================================
;;	
if flag_kelvin eq 1 or flag_kelvin_external eq 1 then begin 
	if flag_kelvin_external eq 0 then begin 
		convKJb = float(13.6 * (300./nu)^2. * (1./sbmajor)*(1./sbminor))
		help, convKJb
		;;
		for inu=0,nnu-1 do $ 
			d[*,*,inu,*]=reform(d[*,*,inu,*])* replicate(convKJb[inu], nx,ny,nt) + $
				replicate(convKTP, nx, ny,nt)
	endif else begin 
		for it=0,nt-1 do begin
			fn_conv=fn[it]
			ipos=strpos(fn_conv, '.fits')
			fn_conv=strmid(fn_conv, 0, ipos)+'.Jy_to_K'+strmid(fn_conv, ipos)
			fi=file_info(fn_conv) 
			if fi.exists then convKJb=readfits(fn_conv) else $ 
				message, 'No Jy_to_K conversion file found. Using last previous conversion vector instead.', /continue
			;;
 			idx=where(convKJb le 0.0 or finite(convKJb) eq 0, ncnt)
			if ncnt ne 0 or n_elements(convKJb) ne nnu then message,'Error. Jy_to_K conversion incorrect.'
			print,'- Converting from Jy to K: factor min,max:',minmax(convKJb)
			for inu=0,nnu-1 do $
				d[*,*,inu,it]=reform(d[*,*,inu,it])* replicate(float(convKJb[inu]), nx,ny)
			
								; + replicate(convKTP, nx, ny,nt)
		endfor
	endelse
endif
;;
;;=============================================================================
out_header=hd ;; --- Needs to be changed! Return all header info for all files instead! Also, indices etc need to be adjusted.
;;=============================================================================
 if keyword_set(flag_verbose) then help, d, nu
return, d
end 

