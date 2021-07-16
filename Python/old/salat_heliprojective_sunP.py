import salat_alma_readfitsheader as shdr
import astropy.units as u

from datetime import datetime,timedelta
from astropy.coordinates import EarthLocation,SkyCoord
from sunpy.coordinates.sun import P as get_sun_P
from skyfield.api import load

def distance_sun_earth(time0,):
    """
    Author: Guevara Gomez J.C.
    
    Finds the distance Sun - Earth at exact time0

    Parameters
    ----------
    time0: datetime
        Reference time

    Returns
    -------
    distance: float

    Examples
    --------


    """
    planets = load('de421.bsp')
    earth = planets['earth']
    sun = planets['sun']
    ts = load.timescale()
    time_ts = ts.utc(time0.year,time0.month,time0.day,time0.hour,time0.minute,time0.second)
    tsun = earth.at(time_ts).observe(sun)
    ra, dec, distance = tsun.radec()
    del ra,dec,time0,time_ts,ts
    return distance


def compute_helioprojective_sunp(file,frame='gcrs'):
    """
     This function does for the Reference Time and according to the RA and DEC reported:
        1. Calculate the SkyCoord structure for the positin in GCRS
        2. Transform previous structure to Helioprojective
        3. Calculate the SunP angle

    Parameters
    ----------
    file: string
        Path to ALMA FITS file

    frame: srtring
        Starting Astropy coordinate frame

    tref: datetime
        The reference time should be provided in header with specific Key

    Returns
    -------
    frame_ctro: SkyCoord
        Coordinates in GCRS

    frame_ctrh: SkyCoord
        Coordinates in Helioprojective

    sunpangle: float
        From Sunpy Docs:
        Return the position (P) angle for the Sun at a specified time, which is the angle between geocentric north and solar north as seen from Earth, measured eastward from geocentric north. The range of P is +/-26.3 degrees.

    tref: datetime
        Reference time for which the transformation was computed


    Examples
    --------

    file = '../test_data/b3.2017-04-22/solaralma.b3.2017-04-22-17:20:13.s11.sw0123.sip.fba.level3.v011.image.pbcor.in_K.nof.fits'
    frame_ctro,frame_ctrh,sunpangle,tref = compute_helioprojective_sunp(file)
    #To print the Central Poisition (x,y) found
    print("(x,y) arcsec: ",frame_ctrh.Tx,frame_ctrh.Ty)

    """


    hdr = shdr.alma_readheader(file)
    ###Reference time, given by Mikolaj eventually
    tref = datetime.strptime(hdr['date-obs'],'%Y-%m-%dT%H:%M:%S.%f')
    ###Coordinates on Earth and ICRS
    ra0 = float(hdr['obsra'])*u.deg
    dec0 = float(hdr['obsdec'])*u.deg
    geox0 = float(hdr['obsgeo-x'])
    geoy0 = float(hdr['obsgeo-y'])
    geoz0 = float(hdr['obsgeo-z'])
    ###Distance in the reference time
    distance = distance_sun_earth(tref,)
    ###Coordinates of ALMA site
    alma_site = EarthLocation.from_geocentric(geox0,geoy0,geoz0,unit=u.m)
    ###SkyCoord of sun observed from ALMA site
    frame_ctro = SkyCoord(ra=ra0,dec=dec0,frame=frame,distance=distance.km*u.km,obstime=tref,location=alma_site,observer="earth")
    frame_ctrh = frame_ctro.helioprojective
    ###Sun P-angle
    sunpangle = get_sun_P(tref).value
    return frame_ctro,frame_ctrh,sunpangle,tref


