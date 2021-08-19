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

!!! success "[SALAT_INFO](python/salat_info.md)"
	Prints some relevant information about the data cube in terminal.
	```python
	>>> import salat
	>>> salat.info(file)
	```

!!! success "[SALAT_PLOT_MAP](python/salat_plot_map.md)"
	This function makes map plot centered at (0,0) arcsec, save images as JPG or PNG files (optional).
	```python
	>>> import salat
	#Plot map timestp=100 using colormap='jet' ans saving as jpg
	>>> salat.plot_map(almadata,beam,pxsize,cmap='jet',average=False,timestp=100,savepng=False,savejpg=True,outputpath="./")
	```


!!! success "[SALAT_CONTRAST](python/salat_contrast.md)"
	Compute and plot "mean intensity" and "rms intensity contrast" of a cube and indicate bad/good frames based on a given threshold. 
	```python
	>>> import salat
	>>> bfrs = salat.contrast(almacube,timesec,show_best=True)
	```
