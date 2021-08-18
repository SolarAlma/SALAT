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


def salat_beam_stats(beammajor,beamminor,beamangle,timesec,plot=False):
	"""
	Name: salat_beam_stats
		part of -- Solar Alma Library of Auxiliary Tools (SALAT) --

	Purpose: This function computes basic stats for beam

	Parameters
	----------
	beammajor: np.array
		Beam major array (from salat_read)
	beamminor: np.array
		Beam minor array (from salat_read)
	beamangle: np.array
		Beam angle array (from salat_read)
	timsec: np.array
		Array with time in seconds (from salat_read)
	plot: Boolean, False default
		If True, plot Beam change on time

	Returns
	-------
	Display information on beam in terminal


	Examples
	-------
		>>> import salat_beam_stats as sbs
		#Get stats and plot
		>>> sbs.salat_beam_stats(beammajor,beamminor,beamangle,timesec=timesec,plot=True)


	Modification history:
	---------------------
	© Guevara Gómez J.C. (RoCS/SolarALMA), July 2021
	"""
	print("")
	print("---------------------------------------------------")
	print("------------ SALAT BEAM STATS part of -------------")
	print("-- Solar Alma Library of Auxiliary Tools (SALAT) --")
	print("")
	print("Computing Statistics")
	print("")
	print("---------------------------------------------------")

	############### Computing Stats (NaNs are ignored) ################

	beamarea = (beammajor/2)*(beamminor/2)*np.pi #Beam area sq. arcsec

	#Beam major
	minbmaj = np.nanmin(beammajor) #min data
	maxbmaj = np.nanmax(beammajor) #max data
	meanbmaj = np.nanmean(beammajor) #mean data
	medianbmaj = np.nanmedian(beammajor) #median data
	stdbmaj = np.nanstd(beammajor) #Std data
	#Beam minor
	minbmin = np.nanmin(beamminor) #min data
	maxbmin = np.nanmax(beamminor) #max data
	meanbmin = np.nanmean(beamminor) #mean data
	medianbmin = np.nanmedian(beamminor) #median data
	stdbmin = np.nanstd(beamminor) #Std data
	#Beam angle
	minbang = np.nanmin(beamangle) #min data
	maxbang = np.nanmax(beamangle) #max data
	meanbang = np.nanmean(beamangle) #mean data
	medianbang = np.nanmedian(beamangle) #median data
	stdbang = np.nanstd(beamangle) #Std data
	#Beam area
	minbarea = np.nanmin(beamarea) #min data
	maxbarea = np.nanmax(beamarea) #max data
	meanbarea = np.nanmean(beamarea) #mean data
	medianbarea = np.nanmedian(beamarea) #median data
	stdbarea = np.nanstd(beamarea) #Std data

	############### Printing in terminal ################

	print("")
	print("----------------------------------------------")
	print("|  Beam Statistics: ")
	print("----------------------------------------------")
	print("|  Min (major,minor,angle,area) = ", (minbmaj,minbmin,minbang,minbarea))
	print("|  Max (major,minor,angle,area) = ",(maxbmaj,maxbmin,maxbang,maxbarea))
	print("|  Mean (major,minor,angle,area) = ",(meanbmaj,meanbmin,meanbang,meanbarea))
	print("|  Median (major,minor,angle,area) = ",(medianbmaj,medianbmin,medianbang,medianbarea))
	print("|  Standard deviation (major,minor,angle,area) = ",(stdbmaj,stdbmin,stdbang,stdbarea))
	print("----------------------------------------------")
	print("")

	############### Plotting Histogram ################

	if plot == True:
		#Making figure
		fig, ax = plt.subplots(ncols=1,nrows=1,figsize=(12,6))
		ax.plot(timesec, beamarea,'.k')
		# ax.fill_between(bins,n,color='gray', step="mid", alpha=0.4,label = r'<T$_{med}$> = %.0f K'%(mediandata))
		ax.set_title(r'Beam Area',fontsize=21)
		ax.set_xlabel(r'Time [s]',fontsize=18)
		ax.set_ylabel(r'Area [arcsec$^2$]',fontsize=18)
		ax.tick_params(axis='both', which='major', labelsize=18)
		plt.tight_layout()
		plt.show()