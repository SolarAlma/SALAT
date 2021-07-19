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


def salat_info(file):
	"""
	Name: salat_info
		part of -- Solar Alma Library of Auxiliary Tools (SALAT) --

	Purpose: This function computes basic stats for beam

	Parameters
	----------

	Returns
	-------
	Display information in terminal


	Examples
	--------
	>>> import salat_info as sin
	>>> sin.salat_info(file)

	Modification history:
	---------------------
	© Guevara Gómez J.C. (RoCS/SolarALMA), July 2021
	"""
	print("")
	print("----------------------------------------------")
	print("SALAT INFO part of -- Solar Alma Library of Auxiliary Tools (SALAT) --")
	print("")
	print("----------------------------------------------")

	############### Reading Header ################

	hdr0,hdr1,hdr2 = srhdr.salat_read_header(file,SILENT=True)

	############### Printing in terminal ################

	print("")
	print("----------------------------------------------")
	print("| Data feat.: ")
	print("----------------------------------------------")
	print("|  ALMA BAND: ",int(hdr0["BAND"][-1]))
	print("|  Obs. Date: ",hdr0["DATE-OBS"][:10])
	print("|  ALMA proj: ",hdr0["PROPCODE"])	
	print("|  Pix. Unit: ",hdr0["BUNIT"])
	print("|  Pix. Size: ",hdr0["CDELT1A"]," arcsec.")
	print("|  Beam mean: ",float(hdr0["SPATRES"])*u.deg.to(u.arcsec)," arcsec")
	print("|  FOV. diam: ",hdr0["EFFDIAM"])
	print("----------------------------------------------")
	print("| Data range ")
	print("----------------------------------------------")
	print("|  Min = ", hdr0["DATAMIN"]," Kelvin")
	print("|  Max = ", hdr0["DATAMAX"]," Kelvin")
	print("----------------------------------------------")
	print("")