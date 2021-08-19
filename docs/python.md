!!! success "[SALAT_READ](python/salat_read.md)"
	Reads in a SALSA level4 FITS cubes and provides information about the cube's dimension and other parameters stored as extensions, such as arrays of observing time, beam's size and angle.
	```python
	>>> import salat
	>>> almacube,header,timesec,timeutc,beammajor,beamminor,beamangle = salat.read(file,timeout=True,beamout=True,HEADER=True,SILENT=False,fillNan=False)
	```



!!! success "[SALAT_STATS](python/salat_stats.md)"
	Reads in a SALSA level4 FITS cubes and outputs basic statistics of the data cube (or a frame) as a dictionary and print them in terminal (optional). A histogram is also plotted (optional)
	```python
	>>> import salat
	>>> datastats = salat.stats(almadata,Histogram=True,)
	```

!!! success "[SALAT_TIMELINE](python/salat_timeline.md)"
	Displays a timeline with missing frames and calibration gaps and outputs corresponding info (time indices)
	```python
	>>> import salat
	>>> scans_idxs,mfram_idxs = salat.timeline(timesec,gap=30)
	```

!!! success "[SALAT_CONTRAST](python/salat_contrast.md)"
	Compute and plot "mean intensity" and "rms intensity contrast" of a cube and indicate bad/good frames based on a given threshold. 
	```python
	>>> import salat
	>>> bfrs = salat.contrast(almacube,timesec,show_best=True)
	```
