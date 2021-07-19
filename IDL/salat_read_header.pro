;+
; NAME: SALAT_READ_HEADER --> NOT WORKING YET!
;       part of -- Solar Alma Library of Auxiliary Tools (SALAT) --
;
; PURPOSE: 
;   Reads in a SALSA level4 FITS cubes
;   and outputs its (most important and/or all) header's parameters as a structure.
;   The most important parameters may also be printed in terminal (optional).
;
; CALLING SEQUENCE:
;   alma_header = salat_read_header(cube)
;
; + INPUTS:
;   CUBE        The SALSA data cube in FITS format
;
; + OPTIONAL KEYWORDS/INPUT PARAMETERS:
;   SILENT      If set, no information is printed in terminal
;   ORIGINAL    If set, the outpt parameters (from the header) is returned with their original name (abbreviation)
;               otherwise, the mote important parameters are returend with meanningful names (by default)
;
; + OUTPUTS:
;   ALMA_HEADER The header parameters as a structure
;
; + RESTRICTIONS:
;   None
;
; EXAMPLE:
;   IDL> cube = './solaralma.b3.fba.20161222_141931-150707.2016.1.00423.S.level4.k.fits'
;   IDL> alma_header = salat_read_header(cube)
;   IDL> help, alma_header
;   IDL> pixel_size = alma_header.CDELT1A ; (in arcsec)
;
; MODIFICATION HISTORY:
;   Sven Wedemeyer (Rosseland Centre for Solar Physics, University of Oslo, Norway), May 2021
;   Shahin Jafarzadeh (Rosseland Centre for Solar Physics, University of Oslo, Norway), July 2021
;-
function salat_read_header, cube, header=header, all=all, original=original, silent=silent

if n_elements(header) eq 0 then hd = headfits(cube) else hd = header

nl=n_elements(hd)

struct = create_struct( $
    'BMAJ', 0.0, $
    'BMIN', 0.0, $
    'BPA', 0.0, $
    'LONPOLE', 0.0, $
    'LATPOLE', 0.0, $
    'PC1_1', 0.0, $
    'PC2_1', 0.0, $
    'PC3_1', 0.0, $
    'PC4_1', 0.0, $
    'PC1_2', 0.0, $
    'PC2_2', 0.0, $
    'PC3_2', 0.0, $
    'PC4_2', 0.0, $
    'PC1_3', 0.0, $
    'PC2_3', 0.0, $
    'PC3_3', 0.0, $
    'PC4_3', 0.0, $
    'PC1_4', 0.0, $
    'PC2_4', 0.0, $
    'PC3_4', 0.0, $
    'PC4_4', 0.0, $
    'CRVAL1', 0.0, $
    'CDELT1', 0.0, $
    'CRPIX1', 0.0, $
    'CRVAL2', 0.0, $
    'CDELT2', 0.0, $
    'CRPIX2', 0.0, $
    'CRVAL3', 0.0, $
    'CDELT3', 0.0, $
    'CRPIX3', 0.0, $
    'PV2_1', 0.0, $
    'PV2_2', 0.0, $
    'RESTFRQ', 0.0, $
    'ALTRVAL', 0.0, $
    'ALTRPIX', 0.0, $
    'VELREF', 0.0, $
    'OBSERVER', ' ', $
    'DATE-OBS', ' ', $
    'OBSRA', 0.0, $
    'OBSDEC', 0.0, $
    'OBSGEO-X', 0.0, $
    'OBSGEO-Y', 0.0, $
    'OBSGEO-Z', 0.0, $
    'DATE', ' ', $
    'BAND', ' ', $
    'DATAMIN', 0.0, $
    'DATAMAX', 0.0, $
    'CASAVER', ' ', $
    'PWV', 0.0, $
    'SPATRES', 0.0, $
    'BNDCTR', 0.0, $
    'CO_OBS', ' ', $
    'CHNRMS', 0.0, $
    'CRPIX1A', 0.0, $
    'CRPIX2A', 0.0, $
    'CDELT1A', 0.0, $
    'CDELT2A', 0.0, $
    'CRVAL1A', 0.0, $
    'CRVAL2A', 0.0, $
    'DSUN_OBS', 0.0, $
    'RSUN_REF', 0.0, $
    'RSUN_OBS', 0.0, $
    'SOLAR_P', 0.0, $
    'REF_TIME', ' ', $
    'DATEREF', ' ', $
    'DATE-BEG', ' ', $
    'PROPCODE', ' ', $
    'PRVER1', ' ' $
        )

; --- Read header line by line --- 
for i=0, nl-1 do begin 
     stmp0=strupcase(strtrim(hd[i],2))
     ipos=strpos(stmp0, "=")
     stmp1=strtrim(strmid(stmp0, 0, ipos),2)
     stmp2=strtrim(strmid(stmp0, ipos+1),2)
     
     case stmp1 of
             'BMAJ': struct.BMAJ = float(sxpar(hd,'BMAJ'))
             'BMIN': struct.BMIN = float(sxpar(hd,'BMIN'))
             'BPA': struct.BPA = float(sxpar(hd,'BPA'))
             'LONPOLE': struct.LONPOLE = float(sxpar(hd,'LONPOLE'))
             'LATPOLE': struct.LATPOLE = float(sxpar(hd,'LATPOLE'))
             'PC1_1': struct.PC1_1 = float(sxpar(hd,'PC1_1'))
             'PC2_1': struct.PC2_1 = float(sxpar(hd,'PC2_1'))
             'PC3_1': struct.PC3_1 = float(sxpar(hd,'PC3_1'))
             'PC4_1': struct.PC4_1 = float(sxpar(hd,'PC4_1'))
             'PC1_2': struct.PC1_2 = float(sxpar(hd,'PC1_2'))
             'PC2_2': struct.PC2_2 = float(sxpar(hd,'PC2_2'))
             'PC3_2': struct.PC3_2 = float(sxpar(hd,'PC3_2'))
             'PC4_2': struct.PC4_2 = float(sxpar(hd,'PC4_2'))
             'PC1_3': struct.PC1_3 = float(sxpar(hd,'PC1_3'))
             'PC2_3': struct.PC2_3 = float(sxpar(hd,'PC2_3'))
             'PC3_3': struct.PC3_3 = float(sxpar(hd,'PC3_3'))
             'PC4_3': struct.PC4_3 = float(sxpar(hd,'PC4_3'))
             'PC1_4': struct.PC1_4 = float(sxpar(hd,'PC1_4'))
             'PC2_4': struct.PC2_4 = float(sxpar(hd,'PC2_4'))
             'PC3_4': struct.PC3_4 = float(sxpar(hd,'PC3_4'))
             'PC4_4': struct.PC4_4 = float(sxpar(hd,'PC4_4'))
             'CRVAL1': struct.CRVAL1 = float(sxpar(hd,'CRVAL1'))
             'CDELT1': struct.CDELT1 = float(sxpar(hd,'CDELT1'))
             'CRPIX1': struct.CRPIX1 = float(sxpar(hd,'CRPIX1'))
             'CRVAL2': struct.CRVAL2 = float(sxpar(hd,'CRVAL2'))
             'CDELT2': struct.CDELT2 = float(sxpar(hd,'CDELT2'))
             'CRPIX2': struct.CRPIX2 = float(sxpar(hd,'CRPIX2'))
             'CRVAL3': struct.CRVAL3 = float(sxpar(hd,'CRVAL3'))
             'CDELT3': struct.CDELT3 = float(sxpar(hd,'CDELT3'))
             'CRPIX3': struct.CRPIX3 = float(sxpar(hd,'CRPIX3'))
             'PV2_1': struct.PV2_1 = float(sxpar(hd,'PV2_1'))
             'PV2_2': struct.PV2_2 = float(sxpar(hd,'PV2_2'))
             'RESTFRQ': struct.RESTFRQ = float(sxpar(hd,'RESTFRQ'))
             'ALTRVAL': struct.ALTRVAL = float(sxpar(hd,'ALTRVAL'))
             'ALTRPIX': struct.ALTRPIX = float(sxpar(hd,'ALTRPIX'))
             'VELREF': struct.VELREF = float(sxpar(hd,'VELREF'))
             'OBSERVER': struct.OBSERVER = string(sxpar(hd,'OBSERVER'))
             'DATE-OBS': struct.DATE-OBS = string(sxpar(hd,'DATE-OBS'))
             'OBSRA': struct.OBSRA = float(sxpar(hd,'OBSRA'))
             'OBSDEC': struct.OBSDEC = float(sxpar(hd,'OBSDEC'))
             'OBSGEO-X': struct.OBSGEO-X = float(sxpar(hd,'OBSGEO-X'))
             'OBSGEO-Y': struct.OBSGEO-Y = float(sxpar(hd,'OBSGEO-Y'))
             'OBSGEO-Z': struct.OBSGEO-Z = float(sxpar(hd,'OBSGEO-Z'))
             'DATE': struct.DATE = string(sxpar(hd,'DATE'))
             'BAND': struct.BAND = string(sxpar(hd,'BAND'))
             'DATAMIN': struct.DATAMIN = float(sxpar(hd,'DATAMIN'))
             'DATAMAX': struct.DATAMAX = float(sxpar(hd,'DATAMAX'))
             'CASAVER': struct.CASAVER = string(sxpar(hd,'CASAVER'))
             'PWV': struct.PWV = float(sxpar(hd,'PWV'))
             'SPATRES': struct.SPATRES = float(sxpar(hd,'SPATRES'))
             'BNDCTR': struct.BNDCTR = float(sxpar(hd,'BNDCTR'))
             'CO_OBS': struct.CO_OBS = string(sxpar(hd,'CO_OBS'))
             'CHNRMS': struct.CHNRMS = float(sxpar(hd,'CHNRMS'))
             'CRPIX1A': struct.CRPIX1A = float(sxpar(hd,'CRPIX1A'))
             'CRPIX2A': struct.CRPIX2A = float(sxpar(hd,'CRPIX2A'))
             'CDELT1A': struct.CDELT1A = float(sxpar(hd,'CDELT1A'))
             'CDELT2A': struct.CDELT2A = float(sxpar(hd,'CDELT2A'))
             'CRVAL1A': struct.CRVAL1A = float(sxpar(hd,'CRVAL1A'))
             'CRVAL2A': struct.CRVAL2A = float(sxpar(hd,'CRVAL2A'))
             'DSUN_OBS': struct.DSUN_OBS = float(sxpar(hd,'DSUN_OBS'))
             'RSUN_REF': struct.RSUN_REF = float(sxpar(hd,'RSUN_REF'))
             'RSUN_OBS': struct.RSUN_OBS = float(sxpar(hd,'RSUN_OBS'))
             'SOLAR_P': struct.SOLAR_P = float(sxpar(hd,'SOLAR_P'))
             'REF_TIME': struct.REF_TIME = string(sxpar(hd,'REF_TIME'))
             'DATEREF': struct.DATEREF = string(sxpar(hd,'DATEREF'))
             'DATE-BEG': struct.DATE-BEG = string(sxpar(hd,'DATE-BEG'))
             'PROPCODE': struct.PROPCODE = string(sxpar(hd,'PROPCODE'))
             'PRVER1': struct.PRVER1 = string(sxpar(hd,'PRVER1'))
              else: stmp2=''
          endcase
     
  endfor

  print
  print, ' ---------------------------------------------------'
  print, ' -- Solar Alma Library of Auxiliary Tools (SALAT) --'
  print, ' ---------------------------------------------------'
  print
  
  return, struct
end