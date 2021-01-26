;; --- Solar Alma Library of Auxiliary Tools (SALAT) --- 
;;================================================================================
;; IDL - FUNCTION salad_telluric_transmission.pro 
;; 
;; PURPOSE: provides transmission of Earth's atmosphere based tabulated data file  
;;
;; NOTE: - Should be reviewed/updated and expanded to all receiver bands  
;;================================================================================

function salad_telluric_transmission, band=band, pwv=pwv_req, frequency=freq_r, out_frequency=out_freq, out_pwv=out_pwv
;; ALMA 
	
if not keyword_set(band) then begin 
   message,'ALMA_transmission> No band specified. Returning Band 6 data.', /continue
   band=6
endif else begin 
   if band ne 6 and band ne 3 then $ 
         message,'ALMA_transmission> Data for requested band is not available.'
endelse 
;; 
if not keyword_set(freq_r) then begin 
   case band of 
      3: freq_r=[ 92.0, 108.0] 
      6: freq_r=[229.0, 249.0]
      else: message,'Requested band currently not supported.'
   endcase   
   ;;
   nfreq=round(((freq_r[1]-freq_r[0])/0.1)+1)
   freq_r=freq_r[0]+findgen(nfreq)*0.1
endif

case band of
   3: filename='~/project/alma/seeing/ALMACyc4_B3_transmission.dat'
   6: filename='~/project/alma/seeing/ALMACyc4_B6_transmission.dat'
   else: filename=''
endcase

;;--------------------------------------------------------------------------------
;; ---  open file --- 
get_lun, cunit
openr, cunit, filename
;;
iostring=''
exit_flag=0
icnt=-1
repeat begin 
   ;; --- read line from file ---
   readf,cunit,iostring
   iostring=strtrim(iostring,2)
   ;;
   stmp=strmid(iostring, 0, 1) 
   if stmp ne '#' then begin 
        stmp=STRSPLIT(iostring,/EXTRACT)
        sval=float(stmp)
        icnt=icnt+1

        if icnt eq 0 then begin 
           pwv=sval
        endif else begin 
           if icnt eq 1 then arr=sval else arr=[[arr],[sval]]
        endelse
   endif
endrep until EOF(cunit) 
;;
;; --- close file --- 
close, cunit
free_lun, cunit
;;
freq=reform(arr[0,*])
trans=arr[1:*,*]
help, pwv, trans, freq
;;
;;--------------------------------------------------------------------------------
;; --- select right data --- 
;;
if not keyword_set(pwv_req) then begin 
   ipwv=0 
   pwv_req=0
endif else begin  
   if pwv_req[0] eq -1 then begin
      ;; --- return all data for all PWV values ---
      ipwv=indgen(n_elements(pwv))
   endif else begin
      ipwv=round(interpol(findgen(n_elements(pwv)), pwv, pwv_req))
   endelse
endelse
;;
;; --- interpolate transmission data for requested frequency range --- 
;print, minmax(freq_r)
;print, minmax(freq)
;;
if pwv_req[0] eq -1 then begin
   for i=0,n_elements(pwv)-1 do begin 
      tmp=interpol(reform(trans[i,*]), freq, freq_r)
      if i eq 0 then out=fltarr(n_elements(pwv),n_elements(tmp))
      out[i,*]=tmp
   endfor
endif else begin
   print, ipwv
   for i=0,n_elements(ipwv)-1 do begin     
      tmp=interpol(reform(trans[i,*]), freq, freq_r)
help, i, tmp
      if i eq 0 then out=fltarr(n_elements(ipwv),n_elements(tmp))
      out[i,*]=tmp
   endfor
endelse
out_freq=freq_r
out_pwv=pwv[ipwv]
;;--------------------------------------------------------------------------------
out=reform(out)
return, out 
end
