;; --- Solar Alma Library of Auxiliary Tools (SALAT) --- 
;;================================================================================
;; IDL - FUNCTION salad_combine_spectralwindows.pro 
;; 
;; PURPOSE: combines data cubes for different spectral windows and does check if all 
;;          time steps do exist in both cubes 
;;
;; KEYWORDS: 
;; - MIDNIGHTHOUR	If set, time is expected as seconds after midnight. Otherwise, Julian dates are expected by default.
;;
;; NOTE: to be reviewed. 
;;       - currently handles only two windows but should be more flexible 
;;================================================================================
function salad_combine_spectralwindows, dsw0, dsw1, nusw0, nusw1, time0, time1, $ 
    spectralwindow=specwin, $ ;; --- prescribed ID 
	error=timeerrs, $ 
    time=out_time, $ 
	nu=nu_out, $ 
	midnighthour=flag_midnighthour
;;=============================================================================
;;	
;;=============================================================================
;;
if not keyword_set(specwin) then specwin=0
if not keyword_set(timeerrs) then timeerrs=1E-3 ;; --- precision to which time stamps must agree to be identified as the same [s]
timeerr=double(timeerrs)/24./3600. ;; --- in days 
;;=============================================================================

ndim0=size(dsw0,  /n_dimensions) 
szd0 =size(dsw0,  /dimensions) 
szn0 =size(nusw0, /dimensions) 
nnu0 =n_elements(nusw0)
if ndim0 eq 4 then nt0=szd0[3] else nt0=1

ndim1=size(dsw1,  /n_dimensions) 
szd1 =size(dsw1,  /dimensions) 
szn1 =size(nusw1, /dimensions) 
nnu1 =n_elements(nusw1)
if ndim1 eq 4 then nt1=szd1[3] else nt1=1

help,szd0
print, szd0

;;=============================================================================
;; --- Check if dimensions match --- 
if szd0[2] ne nnu0 then message,'Input array for SW0: Number of frequency points differs from frequency axis.'
if szd1[2] ne nnu1 then message,'Input array for SW0: Number of frequency points differs from frequency axis.'
;;
if szd0[0] ne szd1[0] then message,'Input arrays: Number of elements in x dimension do not match.'
if szd0[1] ne szd1[1] then message,'Input arrays: Number of elements in y dimension do not match.'
;;
idx=where(time0 eq -1, ncnt0)
idx=where(time1 eq -1, ncnt1)
if (ncnt0+ncnt1) gt 0 or total(abs(time0)) eq 0.0 or total(abs(time1)) eq 0.0 then $ 
	message,'Time information missing. Cannot compare and combine.'
;;
if nt0 ne nt1 then $ 
   message,'Input arrays: Number of elements in time dimension do not match.', /continue 
;;
;;=============================================================================
;; --- compare time stamps in TIME0 and TIME1 --- 
;; --- round to second precision ---
if keyword_set(flag_midnighthour) then begin 
   time0s=double(time0)
   time1s=double(time1)
endif else begin 
   time0s=double(time0)*double(24.0*3600.0)
   time1s=double(time1)*double(24.0*3600.0)
endelse   
time0r=double(round(time0s,/L64))
time1r=double(round(time1s,/L64))
;;
;;=============================================================================
;; --- Collect all present time steps --- 
timea=time0r
times=time0s
;help, timea
for it=0,nt1-1 do begin 
    idx=where(abs(timea-time1r[it]) lt timeerr, ncnt)
	;print, it, timeerr, min(abs(timea-time1r[it])), ncnt 
    if ncnt eq 0 then begin
		;print,'Added:', it, abs(timea-time1r[it]) 
	   timea=[timea, time1r[it]]
   	   times=[times, time1s[it]]
	endif
endfor	
isort=sort(timea)
timea=timea[isort]
times=times[isort]
;help, timea & print, timea
;;
;;=============================================================================
;; --- Check which time step is present for data set 0 ---
ival=replicate(0, n_elements(timea))
for it=0,n_elements(time0r)-1 do begin 
    idx=where(abs(timea-time0r[it]) le timeerr, ncnt)
    if ncnt gt 0 then ival[idx[0]]=1
endfor	
;;
;; --- Check which time step is present for data set 1 --- 
for it=0,n_elements(time1r)-1 do begin 
    idx=where(abs(timea-time1r[it]) le timeerr, ncnt)
    if ncnt gt 0 then ival[idx[0]]=ival[idx[0]]+1
endfor
;;
;; --- Check which time step is present for both data sets --- 
idx=where(ival eq 2, ncnt)
print,'> Number of time steps in both sets: ',ncnt 
;;
;;=============================================================================
;; --- Prepare output array --- 
;;
nt=ncnt
out_data=fltarr(szd0[0],szd0[1], nnu0+nnu1, nt)
for i=0,nt-1 do begin
	it0=where(time0r eq timea[idx[i]])
	it1=where(time1r eq timea[idx[i]])
	;;
	;print,'===============',i,timea[idx[i]],time0r[it0],time1r[it1]
	out_data[*,*,0:nnu0-1,i]=reform(dsw0[*,*,*,it0])
	out_data[*,*,nnu0:*,  i]=reform(dsw1[*,*,*,it1])	
endfor	 
nu_out=reform([nusw0,nusw1])
;;=============================================================================
out_time=double(times[idx])
;;=============================================================================
return, out_data
end 

