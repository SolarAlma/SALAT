pro salat_fits2crispex, fitscube, savedir=savedir, filename=filename

; FITSCUBE	a fits cube. 
; 			THe cube should in this format: [x,y,t]
;
; SAVEDIR	directory to save the output
; FILENAME	output file name
;
; @SJ
; ---------------------------------------------------------------------------------

if n_elements(savedir) eq 0 then savedir='./'
if n_elements(filename) eq 0 then filename='cube'
; -----------------------------------------------------------------

imcube = readfits(fitscube,hdr)

sz = size(imcube)
nx = sz(1)
ny = sz(2)
nt = sz(3)

print, '... data set of dimensions x,y: '+strtrim(nx,2)+', '+strtrim(ny,2)
print, '... and number of frames: '+strtrim(nt,2)

imfilename=savedir+filename+'.fcube'

header=make_lp_header(fltarr(nx,ny), nt=nt)
openw, luwr, imfilename, /get_lun
wc2=assoc(luwr, bytarr(512)) & wc2[0]=byte(header)
print, '...writing CRISPEX cube'
wc2=assoc(luwr, imcube, 512)
wc2[0]=imcube
free_lun, luwr

print, ' '
print, ' >>> finished writing cube: '+imfilename

stop
end
