from astropy.io import fits

def salat_load_header(file,showheader = False):
	"""
	Name: salat_load_header
		part of -- Solar Alma Library of Auxiliary Tools (SALAT) --

	Purpose: This function load the header of a ALMA cube according
		to the description in the handbook.

	Parameters
	----------
	file: string
		path to ALMA cube

	Returns
	-------
	hdr0: astropy.io.fits.header.Header
		Main Header in astropy format 
	hdr1: astropy.io.fits.header.Header
		Extension header in astropy format
	hdr2: astropy.io.fits.header.Header
		Extension table

	Examples
	-------
		$> import sala_load_header as slhdr
		$> path_alma = "./solaralma.b6.fba.20170328-150920_161212.2016.1.00788.S.level4.k.fits"
		$> hdr0,hdr1,hdr2 = slhdr.salat_load_header(path_alma)

	Modification history:
	---------------------
	© Guevara Gómez J.C. (RoCS/SolarALMA), July 2021
	"""

	hdr0 = fits.open(file)[0].header
	hdr1 = fits.open(file)[1].header
	hdr2 = fits.open(file)[2].header

	if showheader:
		print(hdr) ##Include extension and table

	return hdr0,hdr1,hdr2