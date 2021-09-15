import numpy as np
from astropy.io import fits
import astropy.units as u
from datetime import datetime,timedelta
import scipy
from scipy import ndimage
from scipy import stats as scpstats
import matplotlib
import matplotlib.pyplot as plt
from mpl_toolkits.axes_grid1 import make_axes_locatable
from typing import NamedTuple
import radio_beam as rb
import tqdm


############################ SALAT READ ############################

def read(file,fillNan=False,timeout=False,beamout=False,HEADER=True,SILENT=False):
	"""
	Name: read
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
		Optional, array with time in UTC 
	beammajor: np.array
		Optional, array with beam major axes in arcsec
	beamminor: np.array
		Optional, array with beam minor axes in arcsec
	beamangle: np.array
		Optional, array with beam angles in degrees

	Examples
	--------
		>>> import salat
		>>> file = "./solaralma.b3.fba.20161222_141931-150707.2016.1.00423.S.level4.k.fits"
		#To get only cube, note that _ are mandatory for non-asked variables
		>>> almacube,_,_,_,_,_,_ = salat.read(file,SILENT=True)
		#To get cube and times and print out information in Terminal
		>>> almacube,_,timesec,timeutc,_,_,_ = salat.read(file,timeout=True)
		#To get cube and beam info and print out information in Terminal
		>>> almacube,_,_,_,beammajor,beamminor,beamangle = salat.read(file,beamout=True)

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
	sqcube = np.squeeze(cubedata[0].data) #Cube images squeezed to [t,y,x]
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
	afi = int(scpstats.mode(afi_all).mode) #Stats mode of indexes left and right for non-Nans
	aii = int(scpstats.mode(aii_all).mode) #Stats mode of indexes left and right for non-Nans
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

	hdr0 = read_header(file,ALL=True,ORIGINAL=True,SILENT=True)

	############### Reading Times ################

	if timeout:
		# print("Reading Times")
		# print("")
		dateobs = hdr0["DATE-OBS"][:10]
		timesec = cubedata[1].data[3]-np.nanmin(cubedata[1].data[3]) #Time array in Seconds
		timeutc = np.array([datetime.strptime(hdr0["DATE-OBS"][:10],"%Y-%m-%d")+
			timedelta(seconds=int(item),microseconds=int(1e6*(item%1))) for item in cubedata[1].data[3]])
	else:
		timesec = None
		timeutc = None

	############### Reading Beam axes and angle ################

	if beamout:
		# print("Reading Beam properties")
		# print("")
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
		info(file)

	############### Return variables ################
	
	# If options are False, variables are None
	print("Done!")
	if HEADER == False:
		hdr0 = None
		return sqcubecrop,hdr0,timesec,timeutc,beammajor,beamminor,beamangle
	else:
		return sqcubecrop,hdr0,timesec,timeutc,beammajor,beamminor,beamangle

############################ SALAT READ HEADER ############################

def read_header(file,ALL=False,ORIGINAL=False,SILENT=False):
	"""
	Name: read_header
		part of -- Solar Alma Library of Auxiliary Tools (SALAT) --

	Purpose: This function load the header of a ALMA cube according
		to the description in the handbook.

	Parameters
	----------
	file: string
		path to ALMA cube
	ALL: Boolean, False Default 
		If True, original header as as astropy.io.fits.header.Header is returned
		If False, header is returned as class structure depending of ORIGINAL parameters
	ORIGINAL: Boolean, False Default
		If True, header structure preserves original keyword names
		If False, header structure get new meaninful keywords as in documentation

	SILENT: Boolean, False Default
		If True, it does not print out in terminal

	Returns
	-------
	header: Class or astropy.io.fits.header.Header 
		Header as Namedtuple CLass that can be accessed as header.__varname__ if ALL=FALSE
		Header as astropy.io.fits.header.Header if ALL=TRUE


	Examples
	-------
		>>> import salat
		>>> path_alma = "./solaralma.b6.fba.20170328-150920_161212.2016.1.00788.S.level4.k.fits"
		>>> header = salat.read_header(path_alma)

	Modification history:
	---------------------
	© Guevara Gómez J.C. (RoCS/SolarALMA), July, August 2021
	"""

	############### Loading Original Header ################

	hdr0 = fits.open(file)[0].header

	############### Header structure depending on input options ################

	if ALL == False: #If ALL FALSE then only important tags names are passed to structure
		#the important tag names are manually defined
		important_tags = ['BMAJ','BMIN','BPA','CRVAL1','CRVAL2','CRVAL3','CRVAL1A','CRVAL2A','RESTFRQ','DATE-OBS',
						'INSTRUME','DATAMIN','DATAMAX','PROPCODE','PWV','CDELT1A']

		important_tags_meaningful = ['major_beam_mean','minor_beam_mean','beam_angle_mean','RA','Dec','Frequency','solarx','solary','Rest_frequency','DATE_OBS',
						'ALMA_Band','min_of_datacube','max_of_datacube','ALMA_project_id','water_vapour','pixel_size']

		important_tags_values = [hdr0[item] for item in important_tags]
		important_tags_values_type = [type(item) for item in important_tags_values]

		if ORIGINAL == True:
			important_tags = [w.replace('-', '_') for w in important_tags] #Class dont handle - for varname
			class Header(NamedTuple):
				"""
				Define tags and types
				"""
				for i in range(len(important_tags_values)):
					exec("%s : %s" % (important_tags[i],important_tags_values_type[i].__name__))
		else:
			class Header(NamedTuple):
				"""
				Define tags and types
				"""
				for i in range(len(important_tags_values)):
					exec("%s : %s" % (important_tags_meaningful[i],important_tags_values_type[i].__name__))

		header = Header(*important_tags_values)

	else: #Otherwise, all are passed to structure
		header = hdr0.copy()

	############### Print out in terminal ################

	if SILENT == False:
		print("")
		print("---------------------------------------------------")
		print("------------ SALAT READ HEADER part of ------------")
		print("-- Solar Alma Library of Auxiliary Tools (SALAT) --")
		print("")
		print('  ')
		print(' --------------------------------------------------')
		print(' |  Selected parameters from the header:')
		print(' --------------------------------------------------')
		print(' |  Time of observations: ',hdr0['DATE-OBS'])
		print(' |  ALMA Band: ',hdr0['INSTRUME'])
		print(' |  ALMA Project ID: ',hdr0['PROPCODE'])
		print(' |  Solar x (arcsec) ~ ',hdr0['CRVAL1A'])
		print(' |  Solar y (arcsec) ~ ',hdr0['CRVAL2A'])
		print(' |  Pixel size (arcsec): ',hdr0['CDELT1A'])
		print(' |  Mean of major axis of beam (deg): ',hdr0['BMAJ'])
		print(' |  Mean of minor axis of beam (deg): ',hdr0['BMIN'])
		print(' |  Mean of beam angle (deg): ',hdr0['BMAJ'])
		print(' |  Frequency (Hz): ',hdr0['CRVAL3'])
		print(' |  Water Vapour: ',hdr0['PWV'])
		print(' ---------------------------------------------------')
		print('  ')


	return header

############################ SALAT STATS ############################

def stats(almadata,Histogram=False,SILENT=False):
	"""
	Name: stats
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
		>>> import salat
		#Datacube or frame existing with name almadata
		#Create Stats printing in terminal and plotting histo
		>>> datastats = salat.stats(almadata,Histogram=True,)


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
	skewdata = float(scpstats.skew(almadata,axis=None,nan_policy='omit').data) #Skewness data Fisher-Pearson coefficient of skewness
	kurtdata = scpstats.kurtosis(almadata,axis=None,nan_policy='omit') #Kurtosis data
	modedata = float(scpstats.mode(almadata,axis=None,nan_policy='omit')[0]) #Mode data
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

############################ SALAT TIMELINE ############################

def timeline(timesec,gap=30):
    """
    Name: timeline
        part of -- Solar Alma Library of Auxiliary Tools (SALAT) --

    Purpose: This function displays a timeline showing missing frames and gaps

    Parameters
    ----------
    timesec: np.array
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
        >>> import salat
        >>> scans_idxs,mfram_idxs = salat.timeline(timesec,gap=30)

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

    cadence = scpstats.mode(np.ediff1d(timesec))[0][0]
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

    return scans_idxs,mfram_idxs

############################ SALAT INFO ############################

def info(file):
	"""
	Name: info
		part of -- Solar Alma Library of Auxiliary Tools (SALAT) --

	Purpose: This function computes basic stats for beam

	Parameters
	----------
	file: str
		path to ALMA FITS data set

	Returns
	-------
	Display information in terminal


	Examples
	--------
	>>> import salat
	>>> salat.info(file)

	Modification history:
	---------------------
	© Guevara Gómez J.C. (RoCS/SolarALMA), July 2021
	"""
	print("---------------------------------------------------")
	print("--------------- SALAT INFO part of ----------------")
	print("-- Solar Alma Library of Auxiliary Tools (SALAT) --")
	print("")


	############### Reading Header ################

	hdr0 = read_header(file,ALL=True,SILENT=True)

	############### Printing in terminal ################

	print("")
	print("----------------------------------------------")
	print("| Data feat.: ")
	print("----------------------------------------------")
	print("|  ALMA BAND: ",int(hdr0["INSTRUME"][-1]))
	print("|  Obs. Date: ",hdr0["DATE-OBS"][:10])
	print("|  ALMA proj: ",hdr0["PROPCODE"])	
	print("|  Pix. Unit: ",hdr0["BUNIT"])
	print("|  Pix. Size: ",hdr0["CDELT1A"]," arcsec.")
	print("|  Beam mean: ",float(hdr0["SPATRES"])," arcsec")
	print("|  FOV. diam: ",hdr0["EFFDIAM"])
	print("----------------------------------------------")
	print("| Data range ")
	print("----------------------------------------------")
	print("|  Min = ", hdr0["DATAMIN"]," Kelvin")
	print("|  Max = ", hdr0["DATAMAX"]," Kelvin")
	print("----------------------------------------------")
	print("")

############################ SALAT PLOT MAP ############################

def plot_map(almadata,beam,pxsize,cmap='hot',average=False,timestp=0,savepng=False,savejpg=False,outputpath="./"):
	"""
	Name: plot_map
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
		>>> import salat
		#Plot map timestp=0
		>>> salat.plot_map(almadata,beam,pxsize,cmap='hot',average=False,timestp=0,savepng=False,savejpg=False,outputpath="./")


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

############################ SALAT BEAM STATS ############################

def beam_stats(beammajor,beamminor,beamangle,timesec,plot=False):
	"""
	Name: beam_stats
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
	timesec: np.array
		Array with time in seconds (from salat_read)
	plot: Boolean, False default
		If True, plot Beam change on time

	Returns
	-------
	Display information on beam in terminal


	Examples
	-------
		>>> import salat
		#Get stats and plot
		>>> salat.beam_stats(beammajor,beamminor,beamangle,timesec=timesec,plot=True)


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

############################ SALAT CONTRAST ############################

def contrast(almadata,timesec,side=5,show_best=False):
	"""
	Name: contrast
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
		>>> import salat
		>>> bfrs = salat.contrast(almacube,timesec,show_best=True)

	Modification history:
	---------------------
	© Guevara Gómez J.C. (RoCS/SolarALMA), July 2021
	"""
	print("")
	print("---------------------------------------------------")
	print("------------ SALAT CONTRAST part of -------------")
	print("-- Solar Alma Library of Auxiliary Tools (SALAT) --")
	print("")

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

############################ SALAT CONVOLVE BEAM ############################

def convolve_beam(data,beam,pxsize):
	"""
	Name: convolve_beam
		part of -- Solar Alma Library of Auxiliary Tools (SALAT) --

	Purpose: Convolve a specified synthetic beam (from an ALMA observation) to a user-provided map 
	(e.g. from a simulation or observations with other instruments)

	Parameters
	----------
	data: np.array
		Data array from user, only 2D, could be a Bifrost snapshot.
	beam: list of np.arrays, [bmaj,bmin,bang]
		List with np.arrays of beam info
	pxsize: float,
		Pixel size of data to convolve arcsec/px

	Returns
	-------
	data_convolved: np.array
		Data convolved with beam

	Examples
	--------
	>>> import salat
	>>>	filebifrost = path_folder + "bifrost_b3_frame400.fits"
	>>> bifrostdata = fits.open(filebifrost)[0].data
	>>> pxsizebifrost = 0.06 #This is assumed
	>>> bifrostconv = salat.convolve_beam(bifrostdata,[beammajor1,beamminor1,beamangle1],pxsize=pxsizebifrost)


	Modification history:
	---------------------
	© Guevara Gómez J.C. (RoCS/SolarALMA), July 2021
	"""
	print("")
	print("------------------------------------------------------")
	print("------------ SALAT CONVOLVE BEAM part of -------------")
	print("---- Solar Alma Library of Auxiliary Tools (SALAT)----")
	print("")
	print("For the input data, NANs are not properly handle")
	print("Please use fill_nans parameter when loading fits")
	print("")
	print("------------------------------------------------------")

	# beam_kernel_time = np.array([beam_kernel_calulator(beam[0][i],beam[1][i],beam[2][i],pxsize) for i in range(len(beam[0]))])
	beam_kernel = beam_kernel_calulator(np.nanmean(beam[0]),np.nanmean(beam[1]),np.nanmean(beam[2]),pxsize)
	data_convolved = ndimage.convolve(data,beam_kernel)

	return data_convolved

def beam_kernel_calulator(bmaj_obs,bmin_obs,bpan_obs,pxsz):
	"""
	Calculate the beam array using the observed beam to be used for convolving the ART data
	"""
	beam = rb.Beam(bmaj_obs*u.arcsec,bmin_obs*u.arcsec,bpan_obs*u.deg)
	beam_kernel = np.asarray(beam.as_kernel(pixscale=pxsz*u.arcsec))
	return beam_kernel

############################ SALAT PREP DATA ############################

def prep_data(file,savedir="./"):
	"""
	Name: prep_data
		part of -- Solar Alma Library of Auxiliary Tools (SALAT) --

	Purpose: This function make FITS cube ready to be used in FITS reader as CARTA

	Parameters
	----------
	file: str
		Original FITS file to be reduced
	savedir: str, "./" Default
		Output directory for new fits

	Returns
	-------
	savefile
		I

	Examples
	--------
		>>> import salat
		>>> salat.prep_data(file)

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