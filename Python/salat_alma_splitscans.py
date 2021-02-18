"""SALAT script for spliting data into scans"""
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

###Other SALAT routines
from salat_reads_fitsdata import ALMA_fits_reader

def ALMA_splitcube_scans(tfba_alma,dfba_alma):
    """
    Using salat_reads_fitstada to get data and time cubes
    split the cubes in the scans of the observation

    Parameters
    ----------
    tfba_alma: numpy.ndarray
        numpy array with times as datetime format
    dfba_alma: numpy.ndarray
        cropped data cube with snapshots as a numpy array

    Returns
    -------
    dfba_scans_alma: numpy.ndarray
        ALMA data cube split in the corresponding scans
    tfba_scans_alma: numpy.ndarray
        ALMA time. array split in the corresponding scans

    Example
    -------
    run_example = input('Do you want to run default example? (y/n): ')
    if run_example == 'y':
        print('Reading format as SoAP output')
        path_alma_fba = '/Users/juancg/Documents/ALMA/data/Bart/'
        dfba_alma_soap,tfba_alma_soap,arpx_alma_soap = ALMA_fits_reader(path_alma_fba,Shahin_format=False)
        dfba_scans_alma,tfba_scans_alma = ALMA_splitcube_scans(tfba_alma=tfba_alma_soap,dfba_alma=dfba_alma_soap)
        print('')
        print('Number of scans: ',len(tfba_scans_alma))
        print('')
        print('Done!')

    """

    tfba_idxscans = [ti+1 for ti in range(len(tfba_alma)-2) if (tfba_alma[ti+1]-tfba_alma[ti]).seconds > 20] ##if diff >20 sec we can be sure is a new scan
    nl = len(tfba_idxscans)
    tfba_scans_alma = np.empty(nl+1,dtype=object)
    dfba_scans_alma = np.empty(nl+1,dtype=object)

    for i in range(0,nl+1):
        if i==0:
            tfba_scans_alma[i] = tfba_alma[:tfba_idxscans[i]].copy()
            dfba_scans_alma[i] = dfba_alma[:tfba_idxscans[i]].copy()
            itmp = i
        elif i != 0 and i!= nl:
            tfba_scans_alma[i] = tfba_alma[tfba_idxscans[itmp]:tfba_idxscans[i]].copy()
            dfba_scans_alma[i] = dfba_alma[tfba_idxscans[itmp]:tfba_idxscans[i]].copy()
            itmp = i
        else:
            tfba_scans_alma[i] = tfba_alma[tfba_idxscans[itmp]:].copy()
            dfba_scans_alma[i] = dfba_alma[tfba_idxscans[itmp]:].copy()

    return dfba_scans_alma,tfba_scans_alma