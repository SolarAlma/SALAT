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
	© Guevara Gómez J.C. (RoCS/SolarALMA), July 2021
	"""
	print("")
	print("----------------------------------------------")
	print("SALAT PREP CUBE part of -- Solar Alma Library of Auxiliary Tools (SALAT) --")
	print("")
	print("----------------------------------------------")

	cubedata = fits.open(file) #Cube data dimensions [t,S,f,x,y] main
	#Assuming Stokes and Frequency dont apply yet
	sqcube = np.squeeze(cubedata[0].data) #Cube images squeezed to [t,x,y]

	



