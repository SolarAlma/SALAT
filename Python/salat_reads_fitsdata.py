"""SALAT script for reading fits"""

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

def ALMA_cube_reader_shahin(path_alma):
    """
    Using the path of the fitts file, the cube is read.
    FOV is cropped to get rid of NAN values around image

    Parameters
    ----------
    path_alma: path to fits file including .fits

    Returns
    -------
    dfba_nof: cropped data cube as a numpy array

    """

    dfba = fits.open(path_alma_fba)[0].data
    afi_all = []
    aii_all = []
    #Finding cropping indexes
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
    dfba_nof = dfba[:,aii:afi,aii:afi].copy()
    
    return dfba_nof

if __name__ == '__main__':
    ALMA_cube_reader_shahin()