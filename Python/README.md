## SALAT | Python routines

#### :round_pushpin: SALAT_ALMA_READFITSDATA
> Read all FITS in a folder and create DataCube, an array with times and extract pixelsize
```JavaScript
In [1]: run salat_alma_readfitsdata.py

In [2]: path_alma_fba = '/test_data/b3.2017-04-22/'

In [3]: dfba_alma_soap,tfba_alma_soap,arpx_alma_soap = ALMA_fits_reader(path_alma_fba) 
````

#### :round_pushpin: SALAT_ALMA_READFITSHEADER
> Read a FITS file and return the header
```JavaScript
In [1]: run salat_alma_readfitsheader.py

In [2]: file = file = '/test_data/b3.2017-04-22/solaralma.b3.2017-04-22-17:54:44.s17.sw0123.sip.fba.level3.v011.image.pbcor.in_K.nof.fits'

In [3]: header = alma_readheader(file,showheader = True)
````

#### :round_pushpin: SALAT_ALMA_SPLITSCANS
> Use the FITS READER to read data and create a cube split in all the scans for the observation
```JavaScript
In [1]: run salat_alma_readfitsheade.py

In [2]: path_alma_fba = '/test_data/b3.2017-04-22/'
        dfba_alma_soap,tfba_alma_soap,arpx_alma_soap = ALMA_fits_reader(path_alma_fba,Shahin_format=False)
        dfba_scans_alma,tfba_scans_alma = ALMA_splitcube_scans(tfba_alma=tfba_alma_soap,dfba_alma=dfba_alma_soap)
        print('')
        print('Number of scans: ',len(tfba_scans_alma))
        print('')
        print('Done!')
````

#### :round_pushpin: SALAT_ALMA_HELIOPROJECTIVE_SUNP
> Use a reference FITS file to compute the Helioprojective position from the original Coordinates 'gcrs'
```JavaScript
In [1]: run salat_alma_helioprojective_sunP.py

In [2]: file = '/test_data/b3.2017-04-22/solaralma.b3.2017-04-22-17:20:13.s11.sw0123.sip.fba.level3.v011.image.pbcor.in_K.nof.fits'
    	frame_ctro,frame_ctrh,sunpangle,tref = compute_helioprojective_sunp(file)
    	#To print the Central Poisition (x,y) found
    	print("(x,y) arcsec: ",frame_ctrh.Tx,frame_ctrh.Ty)
````

#### :round_pushpin: SALAT_ALMA_GETBEAM
> From the FITS file extract the beam major, minor axis and angle and create a numpy array with each. 
```JavaScript
In [1]: run salat_alma_getbeam.py

In [2]: path_alma_fba = '/SALAT/test_data/b3.2017-04-22/'
		bmaj_obs,bmin_obs,bpan_obs = get_ALMA_obs_beam(path_alma_fba)
````

#### :round_pushpin: SALAT_ALMA_ART_CONVOLVER_BEAM
> This script takes an ART cube and convolved with a chosen ALMA beam using DASK for parallelizing
> It has been tested in Viscacha producing the convolution of 3660 frames of simulation in about 5.5 hours
> It makes use of other scripts and needs to be generalized
