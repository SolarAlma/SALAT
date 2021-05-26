function string2time, timestring
;
; +
; returns <timestring> of the form 10:05:12.42 to a variable of
; seconds from midnight
; -

 if n_params() eq 0 then begin
     message, /info, 'sec_from_midnight = string2time(timestring)'
     return, 0
 endif

 
 p1 = strpos(timestring, ':')
 if p1 eq -1 then begin
     message, /info, 'timestring has to be of the form 10:05:12.42'
     print, '      timestring: '+timestring
 endif

 p2 = strpos(timestring, ':', p1+1)
 if p2 eq -1 then begin
     message, /info, 'timestring has to be of the form 10:05:12.42'
     print, '      timestring: '+timestring
 endif

 ho = float(strmid(timestring, 0, p1))
 mi = float(strmid(timestring, p1+1, p2))
 secs = float(strmid(timestring, p2+1))
 return, ho*3600 + mi*60 + secs

end
