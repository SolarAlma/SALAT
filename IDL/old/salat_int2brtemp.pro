;; --- Solar Alma Library of Auxiliary Tools (SALAT) --- 
;;================================================================================
;; IDL - FUNCTION alma_int2brtemp.pro 
;; 
;; PURPOSE: convert intensity to brightness temperature
;;
;; NOTE: Should be reviewed/updated. 
;;================================================================================

function salat_int2brtemp, intensity, lambda, rh=rh
;;--------------------------------------------------------------------------------
;; intensity: intensity in units of erg cm^-2 s^-1 A^-1 sr^-1
;; lambda:    wavelength in A 
;; RH:        convert intensities from RH code, wavelengths in nm !
;;--------------------------------------------------------------------------------
;; The factor 10^8 is due to conversion between cgs and SI: 
;;   1 erg = 10^-7 J 
;;   1 mm  = 10^-1 m
;;--------------------------------------------------------------------------------
;
; --- wavelength in cm 
lamb=lambda*1E-8 
;
; --- all in cm
Tb = lamb^4./(2.*!con.kboltz*!con.clight) * intensity*1E8 
;
;--------------------------------------------------------------------------------

if keyword_set(rh) then begin 
  CLIGHT     = 2.99792458E+08
  HPLANCK    = 6.626176E-34
  KBOLTZMANN = 1.380662E-23
  NM_TO_M    = 1.0E-09
  lamb = lambda * NM_TO_M

  Tb = (HPLANCK*CLIGHT) / ((lamb*KBOLTZMANN) * $
             alog(1.0 + (2.0*HPLANCK*CLIGHT)/(lamb^3 * intensity)))

endif


;--------------------------------------------------------------------------------
return, Tb
end
