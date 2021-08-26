A notebook tutorial can be also downloaded [here](https://github.com/SolarAlma/SALAT/blob/main/Python/SALAT_python_tutorial.ipynb) or revised online [here](https://github.com/SolarAlma/SALAT/blob/main/Python/Tutorial/SALAT_python_tutorial.md) 


!!! success "[SALAT_READ](python/salat_read.md)"
	Reads in a SALSA level4 FITS cubes and provides information about the cube's dimension and other parameters stored as extensions, such as arrays of observing time, beam's size and angle.
	```python
	>>> import salat
	>>> almacube,header,timesec,timeutc,beammajor,beamminor,beamangle = salat.read(file,timeout=True,beamout=True,HEADER=True,SILENT=False,fillNan=False)
	```

!!! success "[SALAT_READ_HEADER](python/salat_read_header.md)"
	Reads in a SALSA level4 FITS cubes and outputs selected important header's parameters with meaningful names as a structure (default). These are also printed in terminal (unless otherwise omitted). All header parameters or the most important parameters with their original name tags can also be outputted (optional). Optionally, the original header is returned. 	
	```python
	>>> import salat
	>>> hdr = salat.read_header(file,)
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
!!! success "[SALAT_BEAM_STATS](python/salat_beam_stats.md)"
	Print statistics aboout synthesised beam and plot variation of the beam parameters with time.
	```python
	>>> import salat
	>>> salat.beam_stats(beammajor1,beamminor1,beamangle1,timesec1,plot=True)
	```

!!! success "[SALAT_CONTRAST](python/salat_contrast.md)"
	Compute and plot "mean intensity" and "rms intensity contrast" of a cube and indicate bad/good frames based on a given threshold. 
	```python
	>>> import salat
	>>> bfrs = salat.contrast(almacube,timesec,show_best=True)
	```
!!! success "[SALAT_CONVOLVE_BEAM](python/salat_convolve_beam.md)"
	Convolve a specified synthetic beam (from an ALMA observations) to a user-provided map (e.g. from a simulation or observations with other instruments). 
	```python
	>>> import salat
	>>> convolve_image = salat.convolve_beam(data,[beammajor1,beamminor1,beamangle1],pxsize=pxsize)
	```

!!! success "[SALAT_PREP_DATA](python/salat_prep_data.md)"
	Take a standard SALSA level 4 cube and convert it such that it is accepted by external viewers, such as CARTA. This involves removal of empty dimensions or - if all 5 dimensions are in use - removing a dimension as selected by the user. Right now: Reduce dimensions.
	```python
	>>> import salat
	>>> salat.prep_data(file)
	```