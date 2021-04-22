pro sjbox, left=left, bottom=bottom, nx=nx, ny=ny, w=w, cc=cc, color=color, thick=thick, linestyle=linestyle, $
	right=right, top=top, label=label, plotbox=plotbox

if n_elements(nx) eq 0 then nx=0
if n_elements(ny) eq 0 then ny=0
if n_elements(left) eq 0 then aleft=0 else aleft=1
if n_elements(bottom) eq 0 then abottom=0 else abottom=1
if n_elements(right) eq 0 then aright=0 else aright=1
if n_elements(top) eq 0 then atop=0 else atop=1
if n_elements(w) eq 0 then w=14
if n_elements(cc) eq 0 then cc=1
if n_elements(color) eq 0 then color=cgColor('Red')
if n_elements(thick) eq 0 then thick=1
if n_elements(linestyle) eq 0 then linestyle=0
if n_elements(label) eq 0 then alabel=0 else alabel=1
if n_elements(plotbox) eq 0 then plotbox=0

wset, w

if not plotbox then begin
if nx gt 0 then begin
	
	if aleft ne 0 AND abottom ne 0 then begin
		xl=left
		yb=bottom
	endif else begin
		print, ' '
		print, ' Select in this order: left and bottom'
		print, ' '
		print, ' Left ---> ' & cursor, xl, yl, /up, /dev
		print, ' Bottom ---> ' & cursor, xb, yb, /up, /dev
	endelse
	tvbox, [nx/cc, ny/cc], (xl+(nx/2.))/cc, (yb+(ny/2.))/cc, color=color, thick=thick, linestyle=linestyle
	print, 'left='+strtrim(xl,2)+', bottom='+strtrim(yb,2)
	if alabel then $
		XYOUTS, (xl/cc)+10, ((ny+yb)/cc)-30, ALIGNMENT=0.0, CHARSIZE=2.5, CHARTHICK= 2.5, /DEVICE, label, color=cgColor('Red')
endif else begin
	print, ' '
	print, ' Select in this order --> left, bottom, right, top'
	print, ' '
	print, ' Left ---> ' & cursor, xl, yl, /up, /dev
	;xl=xl*cc & yl=yl*cc
	if aleft ne 0 then xl=left
	print, ' Bottom ---> ' & cursor, xb, yb, /up, /dev
	;xb=xb*cc & yb=yb*cc
	if abottom ne 0 then yb=bottom
	print, ' Right ---> ' & cursor, xr, yr, /up, /dev
	;xr=xr*cc & yb=yb*cc
	if aright ne 0 then xr=right
	print, ' Top ---> ' & cursor, xt, yt, /up, /dev
	;xt=xt*cc & yt=yt*cc
	if atop ne 0 then yt=top
	nx2 = xr-xl+1  &  ny2 = yt-yb+1
	tvbox, [nx2, ny2], (xl+(nx2/2.)), (yb+(ny2/2.)), color=color, thick=thick, linestyle=linestyle
	print, 'nx='+strtrim(nx2*cc,2)+', ny='+strtrim(ny2*cc,2)+', left='+strtrim(xl*cc,2)+', bottom='+strtrim(yb*cc,2)+', right='+strtrim(xr*cc,2)+', top='+strtrim(yt*cc,2)
	if alabel then $
		XYOUTS, (xl)+10, ((ny2+yb))-30, ALIGNMENT=0.0, CHARSIZE=2.5, CHARTHICK= 2.5, /DEVICE, label, color=cgColor('Red')
endelse
endif else begin
	xl=left
	yb=bottom
	xr=right
	yt=top
	nx2 = xr-xl+1  &  ny2 = yt-yb+1
	tvbox, [nx2/cc, ny2/cc], (xl+(nx2/2.))/cc, (yb+(ny2/2.))/cc, color=color, thick=thick, linestyle=linestyle
endelse

end