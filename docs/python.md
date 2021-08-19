!!! success "[SALAT_READ](python/salat_read.md)"
	Reads in a SALSA level4 FITS cubes and provides information about the cube's dimension and other parameters stored as extensions, such as arrays of observing time, beam's size and angle.
	```python
	>>> import salat
	>>> almacube,header,timesec,timeutc,beammajor,beamminor,beamangle = salat.read(file,timeout=True,beamout=True,HEADER=True,SILENT=False,fillNan = False)
	```


