;+
; NAME: SALAT_READ_HEADER --> NOT WORKING YET!
;       part of -- Solar Alma Library of Auxiliary Tools (SALAT) --
;
; PURPOSE: 
;   Reads in a SALSA level4 FITS cubes
;   and outputs its most important header's parameters with meaningful names as a structure (defualt).
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
;   SILENT      If set, no information is printed in terminal
;   ORIGINAL    If set, the outpt parameters (from the header) is returned with their original name (abbreviation)
;               otherwise, the mote important parameters are returend with meanningful names (by default)
;   ALL         If set, all parametrs from the header (with their original tag names) are outputted in to the structure
;
; + OUTPUTS:
;   The header parameters as a structure
;
; + RESTRICTIONS:
;   None
;
; + IMPORTANT NOTE:
;   Please check the original header, stored in the structure as a string (called: 'ORIGINAL_HEADER') 
;   for comments and unit of parameters.
;
; EXAMPLE:
;   IDL> cube = './solaralma.b3.fba.20161222_141931-150707.2016.1.00423.S.level4.k.fits'
;   IDL> header_structure = salat_read_header(cube)
;   IDL> help, header_structure
;   IDL> pixel_size = header_structure.CDELT1A ; (in arcsec)
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
important_tags = ['BMAJ','BMIN','BPA','CRVAL1','CRVAL2','CRVAL3','RESTFRQ','DATE_OBS',$
                  'INSTRUME','DATAMIN','DATAMAX','PROPCODE','PWV','CDELT1A']

important_tags_meaningful = ['major_beam_mean','minor_beam_mean','beam_angle_mean','RA','Dec','Frequency','Rest_frequency','DATE_OBS',$
                             'ALMA_Band','min_of_datacube','max_of_datacube','ALMA_project_id','water_vapor','pixel_size']

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

if n_elements(all) ne 0 then header_structure = header_structure_original
if n_elements(all) ne 0 then header_structure = header_structure_all

print
print, ' ---------------------------------------------------'
print, ' -- Solar Alma Library of Auxiliary Tools (SALAT) --'
print, ' ---------------------------------------------------'
print

  return, header_structure
end