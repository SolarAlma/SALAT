function sjdiff, array, silent=silent
	
; print differences between consecutive numbers in an array (the sampling space)

if n_elements(silent) eq 0 then silent = 0

num = n_elements(array)

diff = dblarr(num-1)
for i=0L, num-2 do diff[i] = array[i+1]-array[i]
	
if silent eq 0 then print, diff

return, diff

end