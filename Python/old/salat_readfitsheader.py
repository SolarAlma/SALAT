from astropy.io import fits

def alma_readheader(file,showheader = False):
	"""
	Author: Guevara Gomez J.C.

	Get the header from a single FITS file

	Parameters
	----------
	file: string
		Fits path
	showheader: Boolean
		True to print header

	Returns
	-------
	header: astropy header
		header of the file fits

	Example
	-------
	file = '~/SALAT/test_data/b3.2017-04-22/solaralma.b3.2017-04-22-17:54:44.s17.sw0123.sip.fba.level3.v011.image.pbcor.in_K.nof.fits'
	header = alma_readheader(file,showheader = True)
	"""

	hdr = fits.open(file)[0].header

	if showheader:
		print(hdr)

	return hdr