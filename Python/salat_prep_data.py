import numpy as np
import matplotlib.pyplot as plt

def salat_prep_data(file,savedir="./"):
	"""
	Name: salat_prep_data
		part of -- Solar Alma Library of Auxiliary Tools (SALAT) --

	Purpose: This function make FITS cube ready to be used in FITS reader as CARTA

	Parameters
	----------
	file: str
		Original FITS file to be reduced
	savdir: str, "./" Default
		Output directory for new fits

	Returns
	-------
	bestframes: array
		Indexes of the best frames sorted (i.e., that with the largest rms contrast).

	Examples
	--------
		>>> bfrs = slc.salat_contrast(almacube,timesec,show_best=True)

	Modification history:
	---------------------
	© Guevara Gómez J.C. (RoCS/SolarALMA), August 2021
	"""
	print("")
	print("------------------------------------------------------")
	print("------------ SALAT PREP DATA part of -------------")
	print("---- Solar Alma Library of Auxiliary Tools (SALAT)----")
	print("")

	cubedata = fits.open(file) #Cube data dimensions [t,S,f,x,y] main
	imcube = cubedata[0].data[:,0,0,:,:].copy()
	#Assuming Stokes and Frequency dont apply yet

	outfile = file.split("/")[-1].split(".fits")[0]+"_modified-dimension.fits"

	new_hdul = fits.HDUList()
	new_hdul.append(fits.PrimaryHDU(data=imcube))
	new_hdul.writeto(savedir+outfile,overwrite=True)

	print("Done!")

	



