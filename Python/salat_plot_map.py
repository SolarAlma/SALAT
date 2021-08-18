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


def salat_plot_map(almadata,beam,pxsize,cmap='hot',average=False,timestp=0,savepng=False,savejpg=False,outputpath="./"):
	"""
	Name: salat_plot_map
		part of -- Solar Alma Library of Auxiliary Tools (SALAT) --

	Purpose: This function makes map plot centered at (0,0) arcsec

	Parameters
	----------
	almadata: np.array
		Data array from user, can be 2D or 3D
	beam: list of np.arrays, [bmaj,bmin,bang]
		List with np.arrays of beam info
	pxsize: float,
		Pixel size in arcsec
	cmap: str, "hot" default
		Matplotlib colormap for imshow
	average: Boolean, False default
		If True, it plots average image
	timestp: int, 0 default
		Integer, Index of timestep to plot
	savepng: Boolean, False default
		If True it saves image to path in PNG
	savejpg: Boolean, False default
		If True it saves image to path in JPG
	outputpath: str, "./" Default
		Path for saving image, current as default


	Returns
	-------
	fig: matplotlib fig


	Examples
	--------
		>>> import salat_plot_map as spm
		#Plot map timestp=0
		>>> salat_plot_map(almadata,beam,pxsize,cmap='hot',average=False,timestp=0,savepng=False,savejpg=False,outputpath="./")


	Modification history:
	---------------------
	© Guevara Gómez J.C. (RoCS/SolarALMA), July 2021
	"""
	print("---------------------------------------------------")
	print("------------ SALAT PLOT MAP part of ---------------")
	print("-- Solar Alma Library of Auxiliary Tools (SALAT) --")
	print("")


	############### Getting image to plot ################

	#Image to plot
	almadatashape = np.shape(almadata)
	if len(almadatashape) == 3:
		if average == True:
			implot = np.nanmean(almadata,axis=(0))
			imylen = almadatashape[1]*pxsize
			imxlen = almadatashape[2]*pxsize
			beamval = np.nanmean(beam,axis=(1))
			bmaj = beamval[0]
			bmin = beamval[1]
			bang = beamval[2]
		else:
			implot = almadata[timestp].copy()
			imylen = almadatashape[1]*pxsize
			imxlen = almadatashape[2]*pxsize
			bmaj = beam[0][timestp]
			bmin = beam[1][timestp]
			bang = beam[2][timestp]
	else:
		implot = almadata.copy()
		imylen = almadatashape[0]*pxsize
		imxlen = almadatashape[1]*pxsize
		beamval = np.nanmean(beam,axis=(1))
		bmaj = beamval[0]
		bmin = beamval[1]
		bang = beamval[2]

	############### PLotting ################

	extplot = [-imylen/2,imylen/2,-imxlen/2,imxlen/2] #Plot Extent
	fig, ax = plt.subplots(ncols=1,nrows=1,figsize=(12,10))
	im1 = ax.imshow(implot,origin='lower',cmap=cmap,extent=extplot)
	divider = make_axes_locatable(ax)
	cax = divider.append_axes('right', size='5%', pad=0.05)
	cb = fig.colorbar(im1, cax=cax, orientation='vertical')
	#Beam artist to add to plot
	ell_beam = matplotlib.patches.Ellipse(((-imylen/2)+5,(-imxlen/2)+5),bmaj,bmin,angle=bang,fc='k',ec='b')
	#Add beam
	ax.add_patch(ell_beam)
	#Miscelanoues
	ax.tick_params(axis='both', which='major', labelsize=18)
	# ax.set_title(r'ALMA B%i %s'%(banda,imsrti),fontsize=24))
	ax.set_xlabel(r'arcsec',fontsize=20)
	ax.set_ylabel(r'arcsec',fontsize=20)
	cb.set_label(label='Temperature [K]', fontsize=20)
	cb.ax.tick_params(labelsize=18)
	plt.tight_layout()

	############### Saving ################
	
	if savepng == True:
		plt.savefig(outputpath+'ALMA_map_timestp%.4i.png'%(timestp),dpi=150)
	if savejpg == True:
		plt.savefig(outputpath+'ALMA_map_timestp%.4i.jpg'%(timestp),dpi=150)