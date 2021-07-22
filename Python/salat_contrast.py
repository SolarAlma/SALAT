import numpy as np
import matplotlib.pyplot as plt

def salat_contrast(almadata,timesec,side=5,show_best=False):
	"""
	Name: salat_convolve_beam
		part of -- Solar Alma Library of Auxiliary Tools (SALAT) --

	Purpose: This function calcualte RMS contrast and sort best frames

	Parameters
	----------
	almadata: np.array
		Data array from user, can be 2D or 3D from salat_read
	timesec: np.array
		Timesec array from salat_read
	side: int, 5 default
		Number of pixels to be excluded from sides of the field of view prior to calculations of the mean intensity and rms contrast.
	show_best: Boolean, False default
		If True, location of the best frame (i.e., that with the largest rms contrast) is indicated on the plot.

	Returns
	-------
	bestframes: array
		Indexes of the best frames sorted (i.e., that with the largest rms contrast).

	Examples
	--------
		>>> bfrs = slc.salat_contrast(almacube,timesec,show_best=True)

	Modification history:
	---------------------
	© Guevara Gómez J.C. (RoCS/SolarALMA), July 2021
	"""
	print("")
	print("----------------------------------------------")
	print("SALAT CONTRAST part of -- Solar Alma Library of Auxiliary Tools (SALAT) --")
	print("")
	print("----------------------------------------------")

	############### Caculate contrast RMS ################
	# almadatashape = np.shape(almadata)

	meanTbr = np.array([np.nanmean(item) for item in almadata[:,side:-side,side:-side]])
	if side > 0:
		rmsCont = np.array([np.nanstd(item)/np.nanmean(item) for item in almadata[:,side:-side,side:-side]])*100
	elif side ==0:
		meandat = np.array([np.nanmean(item) for item in almadata])
	bestframes = np.argsort(rmsCont)[::-1]

	if show_best == True:
		fig, ax = plt.subplots(ncols=1,nrows=2,sharex=True,figsize=(12,10))
		ax[0].plot(timesec,meanTbr,'--.k')
		ax[1].plot(timesec,rmsCont,'--.k')
		ax[0].tick_params(axis='both', which='major', labelsize=18)
		ax[1].tick_params(axis='both', which='major', labelsize=18)
		ax[0].set_title(r'Best frame = %i'%(bestframes[0]),fontsize=24)
		ax[1].set_xlabel(r'Time [sec]',fontsize=20)
		ax[0].set_ylabel(r'Temperature [K]',fontsize=20)
		ax[1].set_ylabel(r'% RMS Contrast',fontsize=20)
		ax[0].axvline(x=timesec[bestframes[0]],color='red',linestyle=':')
		ax[1].axvline(x=timesec[bestframes[0]],color='red',linestyle=':')
		plt.tight_layout()
		plt.show()

	return bestframes