"""SALAT script for plotting single frame with beam in arcsec or pixels"""

#SALAT routines
import salat_getbeam as sgbm
import salat_readfitsdata as srfd
import salat_readfitsheader as srfh
import salat_splitscans as ssps
#Python routines
import numpy as np
import matplotlib.pyplot as plt
import matplotlib
from mpl_toolkits.axes_grid1 import make_axes_locatable
from datetime import datetime,timedelta


def plotALMAframe(path_alma,scnum=True,plarcs=True):
    """
	Author: Guevara Gomez J.C.

	Using the path of the fits file it plots a screenshot(frame) and the beam.
    By default it plots the frame number 50 of first scan but it can be modified in parameters

	Parameters
	----------
	file: string
		Fits path
    scnum: Boolean
        if True, it will plot defaults frame and scan
    plarcs: Boolean
        If True, it will plot the frame centered at (0,0) in arcsec units
    savefig: Boolean
        If True, Figure is saved as png with 150 dpi
    
	Returns
	-------
    
    Fig


	Example
	-------
    import salat_plotframeandbeam as spfb
    spfb.plotframeandbeam(path_alma) #PLotting default scan and frame
    #To plot custom scand and frame
    spfb.plotframeandbeam(path_alma,scnum=False) #PLotting custom scan and frame
	"""
    
    #Reading data
    dfba_alma_soap,tfba_alma_soap,arpx_alma_soap,banda = srfd.ALMA_fits_reader(path_alma,Shahin_format=False)
    #Splitting data in scans
    dfba_scans_alma,tfba_scans_alma = ssps.ALMA_splitcube_scans(tfba_alma=tfba_alma_soap,dfba_alma=dfba_alma_soap)
    nscans = len(tfba_scans_alma)
    print("")
    print("This dataset has %i scans."%(nscans))
    print("")
    [print("Scan %i got %i frames"%(i,len(dfba_scans_alma[i]))) for i in range(nscans)]
    print("")
    #Getting all beams
    bmaj_med,bmin_med,bpan_med = sgbm.get_ALMA_obs_beam(path_alma,SOAP=True,Bmed=True)

    
    if scnum == False:
        scnum = eval(input("Input desired scan: "))
        frnum = eval(input("Input desired frame: "))
        
    else:
        scnum = 0 #By default scnum 0
        frnum = 50#By default frnum 50
    
    
    #Image to plot
    implot = dfba_scans_alma[scnum][frnum].copy()
    imtime = tfba_scans_alma[scnum][frnum] 
    imsrti = datetime.strftime(imtime,"%Y-%d-%m %H:%M:%S")
    imylen = implot.shape[0]*arpx_alma_soap
    imxlen = implot.shape[1]*arpx_alma_soap
    #Extent for arcsec plots
    extplot = [-imylen/2,imylen/2,-imxlen/2,imxlen/2]

    #MAKIN FIG
    fig, ax = plt.subplots(ncols=1,nrows=1,figsize=(12,10))

    #Beam artist to add to plot
    ell_beam = matplotlib.patches.Ellipse(((-imylen/2)+5,(-imxlen/2)+5),bmaj_med,bmin_med,angle= bpan_med,fc='k',ec='b')
    #colormap
    cmap = "hot"

    #PLot
    im1 = ax.imshow(implot,origin='lower',cmap=cmap,extent=extplot)
    #Colorbar
    divider = make_axes_locatable(ax)
    cax = divider.append_axes('right', size='5%', pad=0.05)
    cb = fig.colorbar(im1, cax=cax, orientation='vertical')
    #Add beam
    ax.add_patch(ell_beam)

    #Miscelanoues
    ax.tick_params(axis='both', which='major', labelsize=18)
    ax.set_title(r'ALMA B%i %s'%(banda,imsrti),fontsize=24)
    ax.set_xlabel(r'arcsec',fontsize=22)
    ax.set_ylabel(r'arcsec',fontsize=22)
    cb.set_label(label='Temperature [K]', fontsize=22)
    cb.ax.tick_params(labelsize=18)
    plt.tight_layout()

    plt.savefig('ALMA_sc%i_fr%i_%s'%(scnum,frnum,datetime.strftime(imtime,"%Y%d%m")),dpi=150)