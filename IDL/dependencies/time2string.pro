function time2string, sday
;
; +
; returns <sday>, seconds from midnight, in a nice string of format
; 13:01:12
; 
; -
 if n_params() eq 0 then begin
     message, /info, 'timestring = time2string(sec_from_midnight)'
     return, 0
 endif

 tformat = '(I2.2)'
 ho = long(sday) / 3600
 if ho ge 10 then hos=strtrim(ho,2) else hos = string(strtrim(ho,2),format=tformat)
 mi = long(sday - ho * 3600 ) / 60
 mis = string(strtrim(mi,2),format=tformat)
 se = sday - ho*3600 - mi*60
 ses = strtrim(se,2)
 if se lt 10 then ses = '0'+ses
 timestring = hos+':'+mis+':'+ses
 return, strmid(timestring,0,13)
end
