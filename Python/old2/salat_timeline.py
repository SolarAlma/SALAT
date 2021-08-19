###SALAT functions
import salat_read as sr
import salat_read_header as srhdr
###Numpy
import numpy as np
###Datetime tools for timing managament
from datetime import datetime,timedelta
###AstroPy tools for FITS, units, etc
import astropy.units as u
from astropy.io import fits
###Scipy
from scipy import stats
###Matplotlib
import matplotlib.pyplot as plt
import matplotlib
from mpl_toolkits.axes_grid1 import make_axes_locatable


def salat_timeline(timesec,gap=30):
    """
    Name: salat_timeline
        part of -- Solar Alma Library of Auxiliary Tools (SALAT) --

    Purpose: This function displays a timeline showing missing frames and gaps

    Parameters
    ----------
    file: np.array
        Time array in seconds
    gap: float, 30 seconds default
        Time gap to consider different scans

    Returns
    -------
    scans_idxs: Dict.
        Dictionary with indexes for all scans
    mfram_idxs: Dict.
        Dictionary with indexes for all consequent sequences

    Examples
    -------
        >>> import salat_timeline as stl
        >>> scans_idxs,mfram_idxs = stl.salat_timeline(timesec,gap=30)

    Modification history:
    ---------------------
    © Eklund H. (RoCS/SolarALMA), July 2021
    © Guevara Gómez J.C. (RoCS/SolarALMA), July 2021
    """
    print("")
    print("---------------------------------------------------")
    print("------------- SALAT TIME LINE part of -------------")
    print("-- Solar Alma Library of Auxiliary Tools (SALAT) --")
    print("")


    ############### Finding Scans and storing indexes in dictionary ################

    cadence = stats.mode(np.ediff1d(timesec))[0][0]
    tidx_scans = np.where(np.ediff1d(timesec)>(gap))[0]+1 #gap is defined for scans
    scans_idxs = {}
    nl = len(tidx_scans)
    for i in range(nl+1):
        if i == 0:
            scans_idxs["Sc. %i"%(i+1)] = [0,tidx_scans[i]-1]
            itmp = tidx_scans[i]
        elif i != 0 and i!= nl:
            scans_idxs["Sc. %i"%(i+1)] = [itmp,tidx_scans[i]-1]
            itmp = tidx_scans[i]
        else:
            scans_idxs["Sc. %i"%(i+1)] = [itmp,len(timesec)-1]

    ############### Finding indexes of missing frames ################

    tidx_mfram = np.where(np.ediff1d(timesec)>(cadence+1))[0]+1 #gap is defined as cadence+1sec
    mfram_idxs = {}
    nl = len(tidx_mfram)
    #Defining consequent secuences Sec.
    for i in range(nl+1):
        if i == 0:
            mfram_idxs["Sec. %i"%(i+1)] = [0,tidx_mfram[i]-1]
            itmp = tidx_mfram[i]
        elif i != 0 and i!= nl:
            mfram_idxs["Sec. %i"%(i+1)] = [itmp,tidx_mfram[i]-1]
            itmp = tidx_mfram[i]
        else:
            mfram_idxs["Sec. %i"%(i+1)] = [itmp,len(timesec)-1]

    ############### Plotting Time Frame ################

    fig, ax = plt.subplots(ncols=1,nrows=1,figsize=(12,3))
    #plot scans
    for key, value in scans_idxs.items():
        ax.plot((timesec[value[0]],timesec[value[-1]]),(1,1),'k')
        ax.text(timesec[value[0]]+(100*cadence),1.02,r'%s'%key,fontsize=20)
        
    for key, value in mfram_idxs.items():
        ax.plot(timesec[value[0]],1,'|r',ms=15)
        ax.plot(timesec[value[-1]],1,'|r',ms=15)

    ax.tick_params(axis='both', which='major', labelsize=18)
    ax.set_title(r'Observation timeline',fontsize=22)
    ax.set_xlabel(r'Time [s]',fontsize=20)
    plt.tight_layout()
    plt.show()

    ############### Returning variable ################

    return scans_idxs,mfram_idxs
