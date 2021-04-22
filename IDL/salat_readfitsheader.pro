;; --- Solar Alma Library of Auxiliary Tools (SALAT) --- 
;;================================================================================
;; IDL - FUNCTION alma_readfitsheader.pro 
;; 
;; PURPOSE: reads in a FITS header and provides it in a more convient form (IDL structure)
;;
;; NOTE: - Should be reviewed/updated to the final FITS header format.  
;;       - Should be updated such that it can handle all data products (single maps, 
;;         cubes, TP for different data levels)
;;================================================================================
function salat_alma_readfitsheader, h, override=flag_override 
  ;; --- reads the FITS header and extracts relevant information ---
  nl=n_elements(h)

  ;; --- prepare output structure ---
  out=create_struct( $
      'dateobs',      ' ',  $ ;; --- observation data as string 
      'dateobs_jul',  0.0D, $ ;; --- observation data as julian 
      'band',         0, $   ;; --- 
      'subband',      0, $   ;; --- 
      'freq',    0.0, $ ;; --- repres. frequency in GHz
      'lambda',  0.0, $ ;; --- repres. wavelength in mm 
      'dx', 0.0, $
      'dy', 0.0, $
      'dn', 0.0, $ ;; --- frequency increment
      'cx', 0, $ ;; --- index of centre pixel 
      'cy', 0,  $ ;; --- index of centre pixel 
	  ;;
	  'beam', create_struct('axmaj', 0.0, 'axmin', 0.0, 'angle', 0.0) $ 	  
  )
  ;;	
  ;; --- Read header line by line --- 
  for i=0,nl-1 do begin 
     stmp0=strupcase(strtrim(h[i],2))
     ipos=strpos(stmp0, "=")
     stmp1=strtrim(strmid(stmp0, 0, ipos),2)
     stmp2=strtrim(strmid(stmp0, ipos+1),2)
     ;;
                                ;print, i,': >>',stmp1, '<<--->>',stmp2,'<<'
     case stmp1 of
        'DATE-OBS': begin
           out.dateobs=strmid(stmp2,1,strlen(stmp2)-2)           
        end
        'CDELT1':   out.dx=float(stmp2)
        'CRPIX1':   out.cx=float(stmp2)
        'CDELT2':   out.dy=float(stmp2)
        'CRPIX2':   out.cy=float(stmp2)
        'CDELT3':   out.dn=float(stmp2)
        'CRVAL3':   out.freq=float(stmp2)
		;;
		'BMAJ':     out.beam.axmaj=float(stmp2)*3600.
		'BMIN':     out.beam.axmin=float(stmp2)*3600.
		'BPA':      out.beam.angle=float(stmp2)
        else: stmp2=''
     endcase
     
  endfor
  
  ;;--------------------------------------------------------------------------------
  ;; --- process extracted information --- 
  ;;--------------------------------------------------------------------------------
  ;; --- frequency/wavelength --- 
  out.lambda=2.9979001e+10/out.freq*10.0
  out.freq=out.freq/1E9   
  ;;------------------------------------------------------------
  ;; --- check which band ---
  if out.freq ge  93.0 and out.freq le 107.0 then out.band=3
  if out.freq ge 230.0 and out.freq le 248.0 then out.band=6
  if out.band eq 0 then begin
	 if not keyword_set(flag_override) then begin 
   	  	message,'Error. Could not extract receiver band from header. Please enter manually.', /continue
     	sk=''
     	read, sk
     	out.band=fix(sk)
    endif
  endif
  ;;------------------------------------------------------------  
  ;; --- detetect sub-band ---
  case round(out.freq) of
     ;; --- Band 3 --- 
     93: out.subband=0
     95: out.subband=1
     105:out.subband=2
     107:out.subband=3
     ;; --- Band 6 --- 
     230:out.subband=0
     232:out.subband=1
     246:out.subband=2
     248:out.subband=3 
     ;;
     else:out.subband=-1
  endcase
  ;;------------------------------------------------------------  
  ;; --- data and time of observation ---
  stmp=out.dateobs
  if strtrim(stmp,2) eq '' then begin 
	  out.dateobs_jul=-1
  endif else begin	  
	  syr=strmid(stmp, 0,4)
	  smo=strmid(stmp, 5,2)
	  sdy=strmid(stmp, 8,2)
	  ipos=strpos(stmp,'T')
	  stmp=strmid(stmp, ipos+1)
	  ;;
	  shr=strmid(stmp,0,2)
	  smi=strmid(stmp,3,2)
	  ssc=strmid(stmp,6)
	  ;help,out.dateobs                     
	  ;help, stmp							   
	  ;print, syr,' ',smo,' ',sdy, ' ', shr,' ',smi,' ', ssc 
	  out.dateobs_jul=julday(double(smo), double(sdy), double(syr), double(shr), double(smi), double(ssc))
  endelse 
  ;;--------------------------------------------------------------------------------
  return, out
end

  
