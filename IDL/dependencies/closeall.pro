pro closeall

; close all windows opened from the same IDL session

while !d.window ne -1 do wdelete, !d.window

end