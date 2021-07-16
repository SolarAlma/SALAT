import salat_load_header as shdr
import astropy.units as u

from datetime import datetime,timedelta
from astropy.coordinates import EarthLocation,SkyCoord
from sunpy.coordinates.sun import P as get_sun_P
from skyfield.api import load

def distance_sun_earth(tref,):
    """
    Name: distance_sun_earth
        part of -- Solar Alma Library of Auxiliary Tools (SALAT) --

    Purpose: Internal funnction to compute distance Sun-Earth for a
        given observation time-ref

     Parameters
    ----------
    tref: datetime.datetime
        Reference time of ALMA observation

    Returns
    -------
    distance: skyfield.units.Distance
        Distance Sun-Earth in physical units
    Examples
    -------
        $> dis_sun_earth = distance_sun_earth(tref,) #for any tref in datetime format
        $> print(dis_sun_earth)

    Modification history:
    ---------------------
    © Guevara Gómez J.C. (RoCS/SolarALMA), July 2021
    """
    planets = load('de421.bsp')
    earth = planets['earth']
    sun = planets['sun']
    ts = load.timescale()
    time_ts = ts.utc(tref.year,tref.month,tref.day,tref.hour,tref.minute,tref.second)
    tsun = earth.at(time_ts).observe(sun)
    ra, dec, distance = tsun.radec()
    del ra,dec,tref,time_ts,ts
    return distance


def salat_coord_convert(file,frame='gcrs',printcoord=False,save_hcoord=False):
    """
    Name: salat_coord_convert
        part of -- Solar Alma Library of Auxiliary Tools (SALAT) --

    Purpose: This function does for the Reference Time and according to the RA and DEC in Header:
        1. Calculate the SkyCoord structure for the positin in GCRS
        2. Transform previous structure to Helioprojective
        3. Calculate the SunP angle

    Parameters
    ----------
    file: string
        Path to ALMA cube FITS file

    frame: srtring
        Starting Astropy coordinate frame (Look at https://docs.astropy.org/en/stable/api/astropy.coordinates.GCRS.html)

    printcoord: Boolean, default False
        If True it will print out in terminal the coordinates in GCRS, Helioprojective and the SunP angle for tref

    save_hcoord: Boolea, default False
        If True it saves a *.txt file with the information computed in the actual directory

    Returns
    -------
    frame_ctro: SkyCoord
        Coordinates in GCRS

    frame_ctrh: SkyCoord
        Coordinates in Helioprojective

    sunpangle: float
        From Sunpy Docs:
        Return the position (P) angle for the Sun at a specified time,
        which is the angle between geocentric north and solar north as seen from Earth,
        measured eastward from geocentric north. The range of P is +/-26.3 degrees.

    tref: datetime.datetime
        Reference time used for the calculation

    Examples
    --------

    file = '../test_data/b3.2017-04-22/solaralma.b3.2017-04-22-17:20:13.s11.sw0123.sip.fba.level3.v011.image.pbcor.in_K.nof.fits'
    frame_ctro,frame_ctrh,sunpangle,tref = compute_helioprojective_sunp(file)
    #To print the Central Poisition (x,y) found
    print("(x,y) arcsec: ",frame_ctrh.Tx,frame_ctrh.Ty)

    Examples
    -------
        $> import salat_coord_convert as slcoord
        $> path_alma = "./solaralma.b6.fba.20170328-150920_161212.2016.1.00788.S.level4.k.fits"
        $> frame_ctro,frame_ctrh,sunpangle,tref = slcoord.salat_coord_convert(path_alma,printcoord=True)

    Modification history:
    ---------------------
    © Guevara Gómez J.C. (RoCS/SolarALMA), July 2021

    """
    print("--------------------")
    print("The Computed coordinates might be not precise, co-aligment with other observations is still needed")
    print("--------------------")

    hdr,_,_ = shdr.salat_load_header(file)
    ###Reference time, given by Mikolaj eventually
    tref = datetime.strptime(hdr['REF_TIME'],'%Y-%m-%dT%H:%M:%S.%f')
    trefstr = datetime.strftime(tref,'%Y-%m-%dT%H:%M:%S.%f')
    ###Coordinates on Earth and ICRS
    ra0 = float(hdr['CRVAL1'])*u.deg
    dec0 = float(hdr['CRVAL2'])*u.deg
    geox0 = float(hdr['OBSGEO-X'])
    geoy0 = float(hdr['OBSGEO-X'])
    geoz0 = float(hdr['OBSGEO-Y'])
    ###Distance in the reference time
    distance = distance_sun_earth(tref,)
    ###Coordinates of ALMA site
    alma_site = EarthLocation.from_geocentric(geox0,geoy0,geoz0,unit=u.m)
    ###SkyCoord of sun observed from ALMA site
    frame_ctro = SkyCoord(ra=ra0,dec=dec0,frame=frame,distance=distance.km*u.km,obstime=tref,location=alma_site,observer="earth")
    frame_ctrh = frame_ctro.helioprojective
    ###Sun P-angle
    sunpangle = get_sun_P(tref).value

    if printcoord:
        print("")
        print("Using %s as reference time"%(trefstr))
        print("")
        print("GCRS coordinates for observation are: ", frame_ctro)
        print("")
        print("Helioprojective (x,y) computed coordinates are: ", (frame_ctrh.Tx,frame_ctrh.Ty))
        print("The SunP angle is: ",sunpangle)

    if save_hcoord:
        txtheader = "REF_TIME, X (arcsec), Y (arcsec), SunP (deg)"
        txtname = hdr["FILENAME"]+".helioprojective.txt"
        with open(txtname,'a') as f:
            f.write(txtheader+"\n")
            f.close

        with open(txtname,'a') as f:
            f.write("%s, %f, %f, %f"%(trefstr,frame_ctrh.Tx.value,frame_ctrh.Ty.value,sunpangle))
            f.close

    return frame_ctro,frame_ctrh,sunpangle,tref


