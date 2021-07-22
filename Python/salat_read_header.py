from astropy.io import fits
###Structure
from typing import NamedTuple

def salat_read_header(file,ALL=False,ORIGINAL=False,SILENT=False):
	"""
	Name: salat_read_header
		part of -- Solar Alma Library of Auxiliary Tools (SALAT) --

	Purpose: This function load the header of a ALMA cube according
		to the description in the handbook.

	Parameters
	----------
	file: string
		path to ALMA cube
	ALL: Boolean, False Default 
		If True, original header as as astropy.io.fits.header.Header is returned
		If False, header is returned as class structure depending of ORIGINAL para.
	ORIGINAL: Boolean, False Default
		If True, header structure preserves original keyword names
		If False, header structure get new meaninful keywords as in documentation

	SILENT: Boolean, False Default
		If True, it does not print out in terminal

	Returns
	-------
	header: Class or astropy.io.fits.header.Header 
		Header as Namedtuple CLass that can be access as header.__varname__ if ALL=FALSE
		Header as astropy.io.fits.header.Header if ALL=TRUE


	Examples
	-------
		>>> import sala_load_header as slhdr
		>>> path_alma = "./solaralma.b6.fba.20170328-150920_161212.2016.1.00788.S.level4.k.fits"
		>>> hdr0,hdr1,hdr2 = slhdr.salat_load_header(path_alma)

	Modification history:
	---------------------
	© Guevara Gómez J.C. (RoCS/SolarALMA), July 2021
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
			class define_header(NamedTuple):
				"""
				Define tags and types
				"""
				for i in range(len(important_tags_values)):
					exec("%s : %s" % (important_tags[i],important_tags_values_type[i].__name__))
		else:
			class define_header(NamedTuple):
				"""
				Define tags and types
				"""
				for i in range(len(important_tags_values)):
					exec("%s : %s" % (important_tags_meaningful[i],important_tags_values_type[i].__name__))

		header = define_header(*important_tags_values)

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