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


def salat_stats(almadata,Histogram=False,SILENT=False):
	"""
	Name: salat_stats
		part of -- Solar Alma Library of Auxiliary Tools (SALAT) --

	Purpose: This function computes basic stats for data cube

	Parameters
	----------
	almadata: np.array
		Data array from user, can be 2D or 3D
	Histogram: Boolean, False default
		If True plots histogram
	SILENT: Boolean, False Default
		If True, it does not print out in terminal

	Returns
	-------
	datastats: Dictionary
		Dictionary with stats as detailed in Handbook


	Examples
	--------
		>>> import salat_stats as sst
		#Datacube or frame existing with name almadata
		#Create Stats printing in terminal and plotting histo
		>>> datastats = sst.salat_stats(almadata,Histogram=True,)


	Modification history:
	---------------------
	© Guevara Gómez J.C. (RoCS/SolarALMA), July 2021
	"""
	print("")
	print("---------------------------------------------------")
	print("--------------- SALAT STATS part of ----------------")
	print("-- Solar Alma Library of Auxiliary Tools (SALAT) --")
	print("")
	print("Computing Statistics")
	print("")
	print("----------------------------------------------")

	############### Computing Stats (NaNs are ignored) ################

	mindata = np.nanmin(almadata) #min data
	maxdata = np.nanmax(almadata) #max data
	meandata = np.nanmean(almadata) #mean data
	mediandata = np.nanmedian(almadata) #median data
	stddata = np.nanstd(almadata) #Std data
	vardata = np.nanvar(almadata) #Variance data
	skewdata = float(stats.skew(almadata,axis=None,nan_policy='omit').data) #Skewness data Fisher-Pearson coefficient of skewness
	kurtdata = stats.kurtosis(almadata,axis=None,nan_policy='omit') #Kurtosis data
	modedata = float(stats.mode(almadata,axis=None,nan_policy='omit')[0]) #Mode data
	percentile1 = np.nanpercentile(almadata,[1,99]) #Value range btw 1st and 99th percentile
	percentile5 = np.nanpercentile(almadata,[5,95]) #Value range btw 5th and 95th percentile

	############### Creating Dictionary ################

	datastats = {"MIN":mindata,
				"MAX":maxdata,
				"MEAN":meandata,
				"MEDIAN":mediandata,
				"MODE":modedata,
				"STD":stddata,
				"VAR":vardata,
				"SKEW":skewdata,
				"KURT":kurtdata,
				"PERCENTILE1":percentile1,
				"PERCENTILE5":percentile5}

	############### Print out in terminal ################

	if SILENT == False:
		shapedata = np.shape(almadata)
		print("")
		print("----------------------------------------------")
		print("|  Statistics: ")
		print("----------------------------------------------")
		if len(shapedata) == 2:
			print("|  Array size:  x = %i  y = %i"%(shapedata[1],shapedata[0]))
		else:
			print("|  Array size: t = %i x = %i  y = %i"%(shapedata[0],shapedata[2],shapedata[1]))
		print("|  Min = ",mindata)
		print("|  Max = ",maxdata)
		print("|  Mean = ",meandata)
		print("|  Median = ",mediandata)
		print("|  Mode = ",modedata)
		print("|  Standard deviation = ",stddata)
		print("|  Variance = ",vardata)
		print("|  Skew = ",skewdata)
		print("|  Kurtosis = ",kurtdata)
		print("|  Percentile 1 = ",percentile1)
		print("|  Percentile 5 = ",percentile5)
		print("----------------------------------------------")
		print("")

	############### Plotting Histogram ################

	if Histogram == True:
		flatdata = np.hstack(np.hstack(almadata.copy()))
		flatdata = flatdata[~np.isnan(flatdata)]
		#Making figure
		fig, ax = plt.subplots(ncols=1,nrows=1,figsize=(12,6))
		binwidth = int((maxdata-mindata)/50) #Make histogram beams of ~50 K
		n, bins= np.histogram(flatdata,binwidth)
		n = n/n.max()
		bins = bins[:-1]
		ax.plot(bins, n,color='black', drawstyle='steps-mid')
		ax.fill_between(bins,n,color='gray', step="mid", alpha=0.4,label = r'<T$_{med}$> = %.0f K'%(mediandata))
		ax.set_title(r'Histogram',fontsize=22)
		ax.set_xlabel(r'Temperature [K]',fontsize=20)
		ax.set_ylabel(r'Normalised frequency',fontsize=20)
		ax.legend(fontsize=20,loc=6)
		ax.tick_params(axis='both', which='major', labelsize=18)
		plt.tight_layout()
		plt.show()


	############### Return variables ################

	return datastats