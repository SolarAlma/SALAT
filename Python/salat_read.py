###SALAT functions
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
###Miscelaneous
import tqdm
import glob

def salat_read(file,fillNan=False,timeout=False,beamout=False,HEADER=True,SILENT=False):
	"""
	Name: salat_read
		part of -- Solar Alma Library of Auxiliary Tools (SALAT) --

	Purpose: This function loads all type of data on level 4 fits

	Parameters
	----------
	file: string
		path to ALMA cube
	fillNan: Boolean, False default
		If True user will be asked to enter value
		or to choose if wants to use Median
	timeout: Boolean, False default
		If True it returns 1D array of time in seconds
	beamout: Boolean, False  default
		If True it returns 3 arrays being beam axes ang angles
	HEADER: Boolean, True default
		If False it does not returns original header (make use of salat_read_header)
	SILENT: Boolean, False default
		If True it does not print out info in terminal

	Returns
	-------
	sqcubecrop: np.array
		Squeezed and cropped ALMA cube with dimensions [t,x,y]
	hdr: astropy.io.fits.header.Header
		main header
	timesec: np.array
		Optional, array with time in seconds (0 s is start observation)
	timeutc: np.array of datetime.datetime
		Optional, it is returned if timeout=True
	beammajor: np.array
		Optional, array with beam major axes in arcsec
	beamminor: np.array
		Optional, array with beam minor axes in arcsec
	beamangle: np.array
		Optional, array with beam angles in degrees

	Examples
	--------
		>>> import sala_read as sr
		>>> file = "./solaralma.b3.fba.20161222_141931-150707.2016.1.00423.S.level4.k.fits"
		#To get only cube, note that _ are mandatory for non-asked variables
		>>> almacube,_,_,_,_,_,_ = sr.salat_read(file,SILENT=True)
		#To get cube and times and print out information in Terminal
		>>> almacube,_,timesec,timeutc,_,_,_ = sr.salat_read(file,timeout=True)
		#To get cube and beam info and print out information in Terminal
		>>> almacube,_,_,_,beammajor,beamminor,beamangle = sr.salat_read(file,beamout=True)

	Modification history:
	---------------------
	© Guevara Gómez J.C. (RoCS/SolarALMA), July 2021
	"""

	print("")
	print("---------------------------------------------------")
	print("--------------- SALAT READ part of ----------------")
	print("-- Solar Alma Library of Auxiliary Tools (SALAT) --")
	print("")
	print("Reading ALMA cube")
	print("")

	############### READ CUBE FITS################

	cubedata = fits.open(file) #Cube data dimensions [t,S,f,x,y] main
	sqcube = np.squeeze(cubedata[0].data) #Cube images squeezed to [t,x,y]
	times = []
	aii_all = []
	afi_all = []
	for item in tqdm.tqdm(sqcube):
		af = item
		afw = af.shape[0]
		afri = int(afw/2)
		aii = int(np.argwhere(~np.isnan(af[afri]))[0]) #Identify left non-Nan
		afi = int(np.argwhere(~np.isnan(af[afri]))[-1])#identify right non-Nan
		aii_all.append(aii)
		afi_all.append(afi)
		del aii,afi,afw,afri
	afi = int(stats.mode(afi_all).mode) #Stats mode of indexes left and right for non-Nans
	aii = int(stats.mode(aii_all).mode) #Stats mode of indexes left and right for non-Nans
	sqcubecrop = sqcube[:,aii:afi,aii:afi].copy() #Cube is cropped to removed Nans  around
	#Filling Nans if option True
	if fillNan:
		useroption = input("Do you want to fill NaN with data median? (y/n): ")
		if useroption == 'y' or useroption == 'Y' or useroption == 'yes' or useroption == 'Yes':
			NaNValue = np.nanmedian(sqcubecrop) #to be used to fill Nans
			sqcubecrop[np.isnan(sqcubecrop)] = NaNValue
		else:
			NaNValue = eval(input("Enter value to fill NaN with: "))
			sqcubecrop[np.isnan(sqcubecrop)] = NaNValue

	############### Read header ################

	hdr0 = srhdr.salat_read_header(file,ALL=True,ORIGINAL=True,SILENT=True)

	############### Reading Times ################

	if timeout:
		print("Reading Times")
		print("")
		dateobs = hdr0["DATE-OBS"][:10]
		timesec = cubedata[1].data[3]-np.nanmin(cubedata[1].data[3]) #Time array in Seconds
		timeutc = np.array([datetime.strptime(hdr0["DATE-OBS"][:10],"%Y-%m-%d")+
			timedelta(seconds=int(item),microseconds=int(1e6*(item%1))) for item in cubedata[1].data[3]])
	else:
		timesec = None
		timeutc = None

	############### Reading Beam axes and angle ################

	if beamout:
		print("Reading Beam properties")
		print("")
		beammajor = np.array([item*u.deg.to(u.arcsec) 
			for item in cubedata[1].data[0]]) #unsure about index for BMAJ and BMIN
		beamminor = np.array([item*u.deg.to(u.arcsec)
			for item in cubedata[1].data[1]])
		beamangle = np.array([item
			for item in cubedata[1].data[2]])
	else:
		beammajor = None
		beamminor = None
		beamangle = None

	############### Print out in terminal ################

	if SILENT == False:
		print("")
		print("----------------------------------------------")
		print("|  About this dataset: ")
		print("----------------------------------------------")
		print("|  ALMA BAND: ",hdr0['INSTRUME'])
		print("|  Obs. Date: ",hdr0["DATE-OBS"][:10])
		print("|  Pix. Unit: ",hdr0["BUNIT"])
		print("|  Pix. Size: ",hdr0["CDELT1A"]," arcsec.")
		print("|  Nr. frames: ",sqcubecrop.shape[0])
		print("|  Width frame: ",sqcubecrop.shape[2]," pix.")
		print("|  Height frame: ",sqcubecrop.shape[1]," pix.")
		print("----------------------------------------------")
		print("")

	############### Return variables ################
	
	# If options are False, variables are None
	print("Done!")
	if HEADER == False:
		hdr0 = None
		return sqcubecrop,hdr0,timesec,timeutc,beammajor,beamminor,beamangle
	else:
		return sqcubecrop,hdr0,timesec,timeutc,beammajor,beamminor,beamangle