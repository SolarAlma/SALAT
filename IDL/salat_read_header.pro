;+
; NAME: SALAT_READ_HEADER
;       part of -- Solar Alma Library of Auxiliary Tools (SALAT) --
;
; PURPOSE: 
;   Reads in a SALSA level4 FITS cubes
;   and outputs selected important header's parameters with meaningful names as a structure (defualt).
;   Thees are also printed in terminal (unless otherwise omitted).
;   All header parameters or the most important parameters with their original name tags can also be 
;   outputted (optional).
;   In all cases, the outputted structure also includes the original header as a string (at the end of the structure)
;
; CALLING SEQUENCE:
;   alma_header = salat_read_header(cube)
;
; + INPUTS:
;   CUBE        The SALSA data cube in FITS format (if the header is not provided)
;   HEADER      The header of the SALSA cube (if specified, then the CUBE is ignored)
;
; + OPTIONAL KEYWORDS/INPUT PARAMETERS:
;   SILENT      If set, no information (i.e., selected important header's parameters) is printed in terminal.
;   ORIGINAL    If set, the selected important header's parameters are returned with their original name (abbreviation)
;               otherwise, they are returend with meanningful names (by default)
;   ALL         If set, all parametrs from the header (with their original tag names) are outputted in to the structure.
;               If set, other cases are ignored (i.e., the selected important header's parameters are not outputted).
;
; + OUTPUTS:
;   The header parameters as a structure
;
; + RESTRICTIONS:
;   None
;
; + IMPORTANT NOTE:
;   -- Please check the original header, always stored in the outputted structure as a string (called: 'ORIGINAL_HEADER') 
;      for comments on and unit of the parameters.
;   -- Please note that all hyphens (-) in the original header's tag names are converted to underlines (_) in the outputted structures.
;   -- SOLARX and SOLARY parameters are SOLAR coordinates based on pointing information 
;      and may have offsets from the actual coordinates.
;
; EXAMPLE:
;   IDL> cube = './solaralma.b3.fba.20161222_141931-150707.2016.1.00423.S.level4.k.fits'
;   IDL> header_structure = salat_read_header(cube)
;   IDL> help, header_structure
;   IDL> pixel_size = header_structure.CDELT1A ; (in arcsec) in case of the original name tags
;   IDL> pixel_size = header_structure.pixel_size ; (in arcsec) in case of the meaningful name tags (default output)
;
; MODIFICATION HISTORY:
;   Shahin Jafarzadeh (Rosseland Centre for Solar Physics, University of Oslo, Norway), July 2021
;-
function salat_read_header, cube, header=header, all=all, original=original, silent=silent

if n_elements(header) eq 0 then hd = headfits(cube) else hd = header

nl=n_elements(hd)

header_structure = create_struct('ORIGINAL_HEADER', hd)

hdr = reverse(hd)

for i=1, nl-1 do begin
     p0 = strupcase(strtrim(hdr[i],2))
     p0loc = strpos(p0, '=')
     tag = strtrim(strmid(p0, 0, p0loc),2)
     value = sxpar(hdr,tag,comment=comment)
 
     tag = tag.Replace('-', '_')
 
     if tag ne '' then header_structure = create_struct(tag, value, header_structure)

endfor
header_structure_all = header_structure

tagnames = tag_names(header_structure_all)
ntag = n_elements(tagnames)
tagnames = tagnames[0:ntag-2] ; remove the 'ORIGINAL_HEADER' tag, so only tag names from the header
ntag = n_elements(tagnames)

; the important tag names are manually defined
important_tags = ['BMAJ','BMIN','BPA','CRVAL1','CRVAL2','CRVAL3','CRVAL1A','CRVAL2A','RESTFRQ','DATE_OBS',$
                  'INSTRUME','DATAMIN','DATAMAX','PROPCODE','PWV','CDELT1A']

important_tags_meaningful = ['major_beam_mean','minor_beam_mean','beam_angle_mean','RA','Dec','Frequency','solarx','solary','Rest_frequency','DATE_OBS',$
                             'ALMA_Band','min_of_datacube','max_of_datacube','ALMA_project_id','water_vapour','pixel_size']

match2,important_tags,tagnames,ind,temp
nind = n_elements(ind)
nremove = ntag-nind

for j=0L, ntag-1 do begin
    ii = where(j eq ind, ncount)
    if ncount eq 0 then struct_delete_field, header_structure, tagnames[j]
endfor
header_structure_original = header_structure

for k=0L, n_elements(important_tags)-1 do $
    struct_replace_field, header_structure, important_tags[k], header_structure.(k+1), newtag=important_tags_meaningful[k]

if n_elements(original) ne 0 then header_structure = header_structure_original
if n_elements(all) ne 0 then header_structure = header_structure_all

if n_elements(silent) eq 0 then begin
    print, '  '
    print, ' -----------------------------------------------------------'
    print, ' |  Selected parameters from the header:'
    print, ' -----------------------------------------------------------'
    print, ' |  Time of observations: '+strtrim(sxpar(hd,'DATE-OBS'),2)
    print, ' |  ALMA Band: '+strtrim(sxpar(hd,'INSTRUME'),2)
    print, ' |  ALMA Project ID: '+strtrim(sxpar(hd,'PROPCODE'),2)
    print, ' |  Solar x (arcsec) ~ '+strtrim(sxpar(hd,'CRVAL1A'),2)
    print, ' |  Solar y (arcsec) ~ '+strtrim(sxpar(hd,'CRVAL2A'),2)
    print, ' |  Pixel size (arcsec): '+strtrim(sxpar(hd,'CDELT1A'),2)
    print, ' |  Mean of major axis of beam (deg): '+strtrim(sxpar(hd,'BMAJ'),2)
    print, ' |  Mean of minor axis of beam (deg): '+strtrim(sxpar(hd,'BMIN'),2)
    print, ' |  Mean of beam angle (deg): '+strtrim(sxpar(hd,'BMAJ'),2)
    print, ' |  Frequency (Hz): '+strtrim(sxpar(hd,'CRVAL3'),2)
    print, ' |  Water Vapour: '+strtrim(sxpar(hd,'PWV'),2)
    print, ' -----------------------------------------------------------'
    print
    print, ' ---------------------------------------------------'
    print, ' -- Solar Alma Library of Auxiliary Tools (SALAT) --'
    print, ' ---------------------------------------------------'
    print
end

  return, header_structure
end