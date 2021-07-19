;+
; NAME: SALAT_TIMELINE
;       part of -- Solar Alma Library of Auxiliary Tools (SALAT) --
;
; PURPOSE: 
;   Displays a time line with missing frames and calibration gaps
;   and outputs corresponding info (time indices)
;
; CALLING SEQUENCE:
;   result = salat_timeline(cube)
;
; + INPUTS:
;   CUBE    The SALSA data cube in FITS format
;
; + OPTIONAL KEYWORDS/INPUT PARAMETERS:
;   GAP     Time difference in seconds that will be considered a gap (missing frames). default: cadence*1.5
;   TIME    Name of a variable for observing time, in seconds from UTC midnight. format: float
;   STIME   Name of a variable for observing time in UTC (optional). format: string
;
; + OUTPUTS:
;   Time index ranges of consequent sequences 
;   in the form of (n,2), where n is the number of onsequent sequences.
;
; + RESTRICTIONS:
;   None
;
; EXAMPLE:
;   IDL> cube = './solaralma.b3.fba.20161222_141931-150707.2016.1.00423.S.level4.k.fits'
;   IDL> result = salat_timeline(cube, time=time, stime=stime)
;	IDL> help, time, stime
;	IDL> print, time[result[0,1]], time[result[1,0]] ; time interval of first gap (if any)
;
; MODIFICATION HISTORY:
;   Shahin Jafarzadeh (Rosseland Centre for Solar Physics, University of Oslo, Norway), July 2021
;-
function salat_timeline, cube, gap=gap, time=time, stime=stime

variables = reform(readfits(cube,header_var,ext=1,/silent))
time = reform(variables[*,3])

num = n_elements(time)
diff = dblarr(num-1)
for i=0L, num-2 do diff[i] = time[i+1]-time[i]

window, 10, xs=1000, ys=100, title='Timeline'
cgplot, time-time[0], fltarr(n_elements(time))+0.5, ps=26, yr=[0,1], xs=1, pos=[.01,.5,.99,.95], color=cgColor('DarkRed'), $
    xtitle='time from beginning of observations (s)', ytickformat='(A1)', yticklen=0.00001, xticklen=0.2

cadence = median(diff)

if n_elements(gap) eq 0 then gap = cadence*1.5

ii = where(diff gt gap, nim)
if nim gt 0 then begin
    result = intarr(nim,2)
    init = 0
    for it=0L, nim-1 do begin
        result[it,0]=init
        result[it,1]=ii[it]
        init = ii[it]+1
    endfor
endif

stime = strarr(n_elements(time))
for i=0L, n_elements(time)-1 do stime[i] = time2string(time[i])

  return, result
end