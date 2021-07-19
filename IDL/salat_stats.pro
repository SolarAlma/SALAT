;+
; NAME: SALAT_STATS
;       part of -- Solar Alma Library of Auxiliary Tools (SALAT) --
;
; PURPOSE: 
;   Reads in a SALSA level4 FITS cubes
;   and outputs basic statistics of the data cube (or a frame) as a structure
;   and print them in terminal (optional). A histogram is also plotted (optional)
;
; CALLING SEQUENCE:
;   result = salat_stats(cube, /histogram)
;
; + INPUTS:
;   CUBE        The SALSA data cube in FITS format
;
; + OPTIONAL KEYWORDS/INPUT PARAMETERS:
;   FRAME       The frame number for which the statistics are calculated 
;               (if not set, they are measured for the entire time series)
;   SILENT      If set, no information is printed in terminal
;   HISTOGRAM   If set, a histogram is also plotted 
;               (i.e., brightness temperature distribution of the data cube or a frame)
;
; + OUTPUTS:
;   Statistics parameters as a structure
;
; + RESTRICTIONS:
;   None
;
; EXAMPLE:
;   IDL> cube = './solaralma.b3.fba.20161222_141931-150707.2016.1.00423.S.level4.k.fits'
;   IDL> result = salat_stats(cube, /histogram)
;	IDL> help, result
;
; MODIFICATION HISTORY:
;   Shahin Jafarzadeh (Rosseland Centre for Solar Physics, University of Oslo, Norway), July 2021
;-
function salat_stats, cube, frame=frame, histogram=histogram, silent=silent

data = reform(readfits(cube))

if n_elements(frame) ne 0 then data = reform(data[*,*,frame])

sz = size(data)
dimension = sz[0]
nx = sz[1]
ny = sz[2]
if dimension eq 3 then nt = sz[3]

moment4,data,avg,avgdev,stddev,var,skew,kurt
min_data = min(data,/nan)
max_data = max(data,/nan)
nfinal = n_elements(data)

if max_data gt min_data then begin
    
    mn = min(data, max = mx, /nan)
    nbin = 100.

    hg = histogram(data, min = mn, max = mx, bin = (mx-mn)/nbin)

    dmd1 = max(hg(1:*), imd, /nan)
    imd = imd+1

    md1 = imd *(mx-mn)/nbin + mn

    mn1 = (imd-2) * (mx-mn)/nbin + mn
    mx1 = (imd+2) * (mx-mn)/nbin + mn

    hg = histogram(data, min = mn1, max = mx1, bin = (mx1-mn1)/nbin)
    x = (findgen(nbin)+.5) * (mx1-mn1) / (nbin) + mn1
    x = (findgen(nbin)+.5) * (mx1-mn1) / (nbin) + mn1

    hgf = las_fit_gauss(x, hg(0:nbin-1), cff)

    if (keyword_set(plotit)) then begin
        plot, x, hg, /ylog
        oplot, x, hgf
        plots, replicate(cff(1), 2), 10^!y.crange
    endif

    modef = cff(1)
    
endif else modef = 0
nx=(size(data))[1]  &  ny=(size(data))[2]
med=median(data)

aa=where(finite(data) eq 1)
data=data[aa]
percentile1 = cgPercentiles(data, Percentiles=[0.01,0.99])
percentile5 = cgPercentiles(data, Percentiles=[0.05,0.95])

if n_elements(silent) eq 0 then begin
    print, '  '
    print, ' ----------------------------------------------'
    print, ' |  Statistics (data unit: K):'
    print, ' ----------------------------------------------'
    if dimension eq 3 then $
    print, ' |  Array size:  x = '+strtrim(nx,2)+'  y = '+strtrim(ny,2)+'  t = '+strtrim(nt,2) else $
    print, ' |  Array size:  x = '+strtrim(nx,2)+'  y = '+strtrim(ny,2)
    print, ' |  Number of data points = '+strtrim(nfinal,2)
    print, ' |  Min = '+strtrim(min_data,2)
    print, ' |  Max = '+strtrim(max_data,2)
    print, ' |  Mean = '+strtrim(avg,2)
    print, ' |  Median = '+strtrim(med,2)
    if max_data gt min_data then $
    print, ' |  Mode = '+strtrim(modef,2) else $
    print, ' |  Mode = Same value for all data points!'
    print, ' |  Standard deviation = '+strtrim(stddev,2)
    print, ' |  Variance = '+strtrim(var,2)
    print, ' |  Skew = '+strtrim(skew,2)
    print, ' |  Kurtosis = '+strtrim(kurt,2)
	print, ' |  Percentile1 (value range between the 1st and 99th percentile)= '+strtrim(percentile1[0],2)+' - '+strtrim(percentile1[1],2)
	print, ' |  Percentile5 (value range between the 5th and 95th percentile)= '+strtrim(percentile5[0],2)+' - '+strtrim(percentile5[1],2)
    print, ' ----------------------------------------------'
    print, '  '
endif

if max_data gt min_data then modef=modef else modef='Same value for all data points!'

stats = create_struct( $
    'Min', min_data, $
    'Max', max_data, $
    'Mean', avg, $
    'Median', med, $
    'Mode', modef, $
    'Standard_deviation', stddev, $
    'Variance', var, $
    'Skew', skew, $
    'Kurtosis', kurt, $
	'Percentile1', percentile1, $
	'Percentile5', percentile5 $
        )

if n_elements(histogram) ne 0 then begin
    in = where(finite(data), /null)
    param = data(in)
    if n_elements(nbins) eq 0 then nbins=40
    if n_elements(freq) eq 0 then freq=1 else freq=0
    if n_elements(xr) eq 0 then xr=[min(param)*1.05,max(param)*1.05]
    if freq eq 1 then yrange=[0,1.1]
    xtitle='!Cbrightness temperature (K)'
    if freq eq 1 then ytitle = 'normalised frequency'
    if dimension eq 3 then title = 'Histogram for the entire time series' else $
        title = 'Histogram for frame number '+strtrim(frame,2)
    !p.charsize=1.8
    !x.thick=1  
    !y.thick=1  
    !x.ticklen=0.03
    !y.ticklen=0.02
    window, 12, xs=700, ys=500, title=title
    cgHISTOPLOT_SJ2, param, /outline, nbins=nbins, thick=3, datacolorname=cgColor('DodgerBlue'), $
        yrange=yrange, xstyle=1, xrange=xr, nfrequency=freq, linestyle=0, xtitle=xtitle, ytitle=ytitle, $
        position=[0.12,0.17,0.96,0.96]
endif

print
print, ' ---------------------------------------------------'
print, ' -- Solar Alma Library of Auxiliary Tools (SALAT) --'
print, ' ---------------------------------------------------'
print

  return, stats
end