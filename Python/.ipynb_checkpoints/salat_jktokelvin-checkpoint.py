import salat_alma_readfitsheader as shdr
import astropy.units as u

from scipy.constants.constants import nu2lambda

def jk_to_kelvin(file,):
    """
    Author: Guevara Gomez J.C.

    For a FITS files whose values are in Jansky it computes the conversion factor to go from Jk/beam to Kelvin

    Parameters
    ----------
    file: string
        FITS name path

    Returns
    -------
    Jansky_to_Kelvin: float
        Conversion factor

    Examples
    --------
    jk_to_k = jk_to_kelvin(file)

    """

    data_bmaj =  shdr.alma_readheader(file)['bmaj']*u.deg.to(u.arcsec)
    data_bmin =  shdr.alma_readheader(file)['bmin']*u.deg.to(u.arcsec)
    fwhm_to_sigma_data = 1./(8*np.log(2))**0.5
    beam_area_data = 2.*np.pi*(data_bmaj*u.arcsec.to(u.rad)*data_bmin*u.arcsec.to(u.rad)*fwhm_to_sigma_data**2)
    freq_data = freq_data*u.Hz
    wavl_data = (nu2lambda(freq_data).value)*u.m.to(u.mm)
    equiv_data = u.brightness_temperature(beam_area_data*u.steradian,freq_data)
    Jansky_to_Kelvin = (1 * u.Jy/u.beam).to(u.K, equivalencies=equiv_data).value
    
    return Jansky_to_Kelvin