"""SALAT script for reading fits"""

# from __future__ import (absolute_import, division, print_function,
#                         unicode_literals)

###Numpy
import numpy as np
###Datetime tools for timing managament
from datetime import datetime,timedelta
###AstroPy tools for FITS, units, etc
import astropy.units as u
from astropy.io import fits
###Scipy
import scipy
from scipy import stats
###Miscelaneous
import tqdm
import glob

def ALMA_fits_reader(path_alma_fba,Shahin_format=False):
    """
    Using the path of the fitts file, the FBA cube is read.
    FOV is cropped to get rid of NAN values around image

    Parameters
    ----------
    path_alma: string
        path to fits files
    Shahin_format: boolean, default False
        if True, input path_alma with *.fits 
        if False, input path_alma as directory path containing .fits-Default SoAP

    Returns
    -------
    dfba_alma: numpy.ndarray
        cropped data cube with snapshots as a numpy array
    tfba_alma: numpy.ndarray
        numpy array with times as datetime format
    arpx_alma: float
        pixel size in arcsec

    Example
    -------
    run_example = input('Do you want to run default example? (y/n): ')
    if run_example == 'y':
        print('Please check that th path_alma points to the correct directory or file')
        print('')
        print('Reading format as Shahin cube')
        path_alma_fba = '/Users/juancg/Documents/ALMA/almaobs_level4/b3__2017-04-22/solaralma.b3.2017-04-22.17:20:13-17:42:37__2016.1.00050.S_clean_inK_sj_level4.fits'
        dfba_alma_shahin,tfba_alma_shahin,arpx_alma_shahin = ALMA_fits_reader(path_alma_fba,Shahin_format=True)
        print('Done!, check vaiables dfba_alma_shahin,tfba_alma_shahin,arpx_alma_shahin')
        print('')
        print('Reading format as SoAP output')
        path_alma_fba = '~/SALAT/test_data/b3.2017-04-22/'
        dfba_alma_soap,tfba_alma_soap,arpx_alma_soap = ALMA_fits_reader(path_alma_fba,Shahin_format=False)
        print('Done!, check vaiables dfba_alma_soap,tfba_alma_soap,arpx_alma_soap')

    """

    if Shahin_format:

        dfba = fits.open(path_alma_fba)[0].data
        afi_all = []
        aii_all = []
        #Finding cropping indexes
        print("Loading ALMA data")
        for af in tqdm.tqdm(dfba):
            afw = af.shape[0]
            afri = int(afw/2)
            aii = int(np.argwhere(~np.isnan(af[afri]))[0])
            afi = int(np.argwhere(~np.isnan(af[afri]))[-1])
            aii_all.append(aii)
            afi_all.append(afi)
            del afw,afri,aii,afi
            
        afi = int(stats.mode(afi_all).mode)
        aii = int(stats.mode(aii_all).mode)
        dfba_alma = dfba[:,aii:afi,aii:afi].copy() 

        #Time array extraction
        tfba_sec = fits.open(path_alma_fba)[1].data
        obsdate_fba = fits.open(path_alma_fba)[0].header['OBSDATE']
        tfba_alma = np.array([datetime.strptime(obsdate_fba,'%Y.%m.%d')+timedelta(seconds=int(item)) for item in tfba_sec])
        #get ARCPIX ALMA
        arpx_alma = fits.open(path_alma_fba)[0].header['PIXELSIZ']

        return dfba_alma,tfba_alma,arpx_alma

    else:
        f_nof = sorted(glob.glob(path_alma_fba+'*.image.pbcor.in_K.nof.fits')) #read and sort files names
        dfba_alma = []
        tfba_alma = []
        afi_all = []
        aii_all = []
        print("Loading ALMA data")
        for item in tqdm.tqdm(f_nof):
            af = np.squeeze(fits.open(item)[0].data)
            af = af #+ 7300 if data is not in abs T#+ np.abs(np.nanmin(af))
            afw = af.shape[0]
            afri = int(afw/2)
            aii = int(np.argwhere(~np.isnan(af[afri]))[0])
            afi = int(np.argwhere(~np.isnan(af[afri]))[-1])
            aii_all.append(aii)
            afi_all.append(afi)
            dfba_alma.append(af.copy())
            #Time array extraction
            ttmp = datetime.strptime(fits.open(item)[0].header['date-obs'],'%Y-%m-%dT%H:%M:%S.%f')
            tfba_alma.append(ttmp)
            del ttmp,aii,afi,af,afw,afri

        afi = int(stats.mode(afi_all).mode)
        aii = int(stats.mode(aii_all).mode)
        dfba_alma = np.array(dfba_alma)[:,aii:afi,aii:afi]
        tfba_alma = np.array(tfba_alma)
        #get arcpix ALMA
        arpx_alma = np.abs((fits.open(f_nof[0])[0].header['cdelt2']*u.deg).to(u.arcsec).value)

        return dfba_alma,tfba_alma,arpx_alma