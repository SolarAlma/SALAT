;; --- Solar Alma Library of Auxiliary Tools (SALAT) --- 
;;================================================================================
;; IDL - ROUTINE alma_band_info.pro 
;;
;; PURPOSE: provide frequencies for ALMA receiver bands (currently only central frequencies)
;; TO DO: Provide sub-bands boundaries and central freqs for bands that are already 
;; commissioned for solar observing 
;;================================================================================
function salat_alma_band_info

  dat=[[1,  8.6,  6.0,   35,   50], $
       [2,  4.6,  3.3,   65,   90], $
       [3,  3.6,  2.6,   84,  116], $
       [4,  2.4,  1.8,  125,  163], $
       [5,  1.8,  1.4,  163,  211], $
       [6,  1.4,  1.1,  211,  275], $
       [7,  1.1,  0.8,  275,  373], $
       [8,  0.8,  0.6,  385,  500], $
       [9,  0.5,  0.4,  602,  720], $
       [10, 0.4,  0.3,  787,  950] ]

  out=create_struct( $
      'band', fix(reform(dat[0,*])), $ 
      'lam_mm_lw', reform(dat[2,*]), $ 
      'lam_mm_up', reform(dat[1,*]), $ 
      'frq_GHz_lw',reform(dat[3,*]), $ 
      'frq_GHz_up',reform(dat[4,*])  )
  
  return, out
end 
