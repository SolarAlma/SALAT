import salat_alma_readfitsheader as srh
import numpy as np
import astropy.units as u
import glob
import tqdm

def get_ALMA_obs_beam(path_obs,SOAP=True):
    """
    Author: Guevara Gomez J.C.

    From the fits this script extract the bmajor, bminor and bangle in ARCSEC

    Parameters
    ----------
    path_obs: string
        path to observation

    SOAP: Boolean
        If True FITS are treated as SoAP type, if False read the beam from .SAV

    Returns
    -------
    bmaj_obs: numpy.array
        array with all the bmajor

    bmin_obs: numpy.array
        array with all the bminor

    bpan_obs: numpy.array
        array with all angles in beam

    Examples
    --------

    path_alma_fba = '/SALAT/test_data/b3.2017-04-22/'
    bmaj_obs,bmin_obs,bpan_obs = get_ALMA_obs_beam(path_alma_fba)
    """
    if SOAP:
        """
        From fits SOAP-type date it extract the median beam (min,maj,pan)
        """
        files_fits_obs = sorted(glob.glob(path_obs+'*.fits'))
        bmaj_obs = np.array([srh.alma_readheader(item)['bmaj']*u.deg.to(u.arcsec) for item in tqdm.tqdm(files_fits_obs)])
        bmin_obs = np.array([srh.alma_readheader(item)['bmin']*u.deg.to(u.arcsec) for item in tqdm.tqdm(files_fits_obs)])
        bpan_obs = np.array([srh.alma_readheader(item)['bpa'] for item in tqdm.tqdm(files_fits_obs)])
        bmaj_med = np.nanmedian(bmaj_obs)
        bmin_med = np.nanmedian(bmin_obs)
        bpan_med = np.nanmedian(bpan_obs)
        print("Median of Beam (maj,min,pan): ",(bmaj_med,bmin_med,bpan_med), "(arcsec,arcsec,deg)")
        return bmaj_obs,bmin_obs,bpan_obs
    else:
        """
        From .SAV SHAHIN
        """
        ## GET information on BEAM size and define kernelsize as 3x lado
        save_file_read = idlsave.read(path_obs);
        arcpix_alma = np.unique(save_file_read['pixsize'])[0]
        bmaj_med = np.nanmedian([item*u.deg.to(u.arcsec) for item in save_file_read['bmaj']])#/arcpix_alma
        bmin_med = np.nanmedian([item*u.deg.to(u.arcsec) for item in save_file_read['bmin']])#/arcpix_alma
        bpan_med = np.nanmedian([item for item in save_file_read['bpa']])
#         area_med = np.pi*bmaj_med*bmin_med
#         lado_med = np.sqrt(area_med)
        return bmaj_med,bmin_med,bpan_med