import numpy as np

import matplotlib
import matplotlib.pyplot as plt

import rolling_window as rw

import astropy.units as u
from astropy.io import fits
from astropy.coordinates import EarthLocation,SkyCoord
from astropy.wcs import WCS


from skyfield.api import load

from skimage import data, color
from skimage.transform import rescale, resize, downscale_local_mean
from skimage.measure import compare_ssim as ssim

from scipy import signal
from scipy import misc
# 
from datetime import datetime,timedelta

import scipy.ndimage as scnd
from scipy import stats

import glob
import idlsave

import tqdm

import warnings
warnings.filterwarnings('ignore')

import seaborn as sns
sns.set_style('darkgrid')

import os 

###SUNPY
import sunpy
import sunpy.io
import sunpy.map
from sunpy.coordinates import frames, get_sun_P,get_sunearth_distance
from sunpy.coordinates.ephemeris import get_earth
from sunpy.physics.differential_rotation import diff_rot, solar_rotate_coordinate
from sunpy.instr.aia import aiaprep
from sunpy.net import Fido, attrs as SAF


##Leer datos de ALMA

###Define ALMA reader

def create_circular_mask(h, w, center=None, radius=None):
    if center is None: # use the middle of the image
        center = [int(w/2), int(h/2)]
    if radius is None: # use the smallest distance between the center and image walls
        radius = min(center[0], center[1], w-center[0], h-center[1])
    Y, X = np.ogrid[:h, :w]
    dist_from_center = np.sqrt((X - center[0])**2 + (Y-center[1])**2)
    mask = dist_from_center <= radius
    return mask

def ALMA_cube_reader(path_alma):
    ###Finding inital and final indexes for cropping ALMA FOV images to only Non-Nan values
    f_nof = sorted(glob.glob(path_alma+'*.in_K.nof.fits'))

    dfba_nof = []
    tfba_nof = []
    afi_all = []
    aii_all = []
    print("Loading ALMA data")
    for item in tqdm.tqdm(f_nof):
        af = sunpy.map.Map(item).data
        afw = af.shape[0]
        afri = int(afw/2)
        aii = int(np.argwhere(~np.isnan(af[afri]))[0])
        afi = int(np.argwhere(~np.isnan(af[afri]))[-1])
        aii_all.append(aii)
        afi_all.append(afi)
        #jajaja
        ttmp = datetime.strptime(sunpy.map.Map(item).meta['date-obs'],'%Y-%m-%dT%H:%M:%S.%f')
        dfba_nof.append(af.copy())
        tfba_nof.append(ttmp)
        del ttmp,aii,afi,af,afw,afri
    
    afi = int(stats.mode(afi_all).mode)
    aii = int(stats.mode(aii_all).mode)
    mascara = create_circular_mask(afi-aii,afi-aii)
    dfba_nof = np.array(dfba_nof)[:,aii:afi,aii:afi]
    tfba_nof = np.array(tfba_nof)
    arcpix_alma = np.abs((sunpy.map.Map(f_nof[0]).meta['cdelt2']*u.deg).to(u.arcsec).value)
    #Temporal averaging
    tavg_alma = np.nanmean(dfba_nof,axis=0)
    tavg_alma[~mascara] = np.nan
    
    tavg_alma = tavg_alma + np.abs(np.nanmin(tavg_alma)-100)
    
    return tavg_alma,arcpix_alma,tfba_nof

def ALMA_cube_reader_Shahin(path):
    """
    This function take the FITS and SAVE files in the path for:
        1. Read ALMA Cube
        2. Crop alma cube to make it to remove big NAN surrondings of FOV
        3. Make time average ALMA data
        4. Extract ALMA pixel size from SAVE
        5. Extract ALMA observation times from SAVE
    """
    ###ALMA read data, cut cube and return time averaged
    pathfits = sorted(glob.glob(path+'*.fits'))
    dfba_nof = fits.open(pathfits[0])[0].data
    afi_all = []
    aii_all = []
    print("Loading ALMA data")
    for af in tqdm.tqdm(dfba_nof):
            afw = af.shape[0]
            afri = int(afw/2)
            aii = int(np.argwhere(~np.isnan(af[afri]))[0])
            afi = int(np.argwhere(~np.isnan(af[afri]))[-1])
            aii_all.append(aii)
            afi_all.append(afi)

    afi = int(stats.mode(afi_all).mode)
    aii = int(stats.mode(aii_all).mode)
    mascara = create_circular_mask(afi-aii,afi-aii)
    dfba_nof = np.array(dfba_nof)[:,aii:afi,aii:afi]

    tavg_alma = np.nanmean(dfba_nof,axis=0)
    tavg_alma[~mascara] = np.nan
    tavg_alma = tavg_alma + np.abs(np.nanmin(tavg_alma)-100)

    ###ALMA Pixel Size
    pathidls = sorted(glob.glob(path+'*.save'))
    save = idlsave.read(pathidls[0])
    arcpix_alma = np.nanmedian(save['pixsize'])

    ###ALMA observation times
    tfba_nof  = []
    for item in save['dateobs']:
        dstr = item.decode("utf-8") 
        ttmp = datetime.strptime(dstr,'%Y-%m-%dT%H:%M:%S.%f')
        tfba_nof.append(ttmp)

    tfba_nof = np.array(tfba_nof)
    
    return tavg_alma,arcpix_alma,tfba_nof,save

def get_avg_cubo(files):
    all_cubos = []
    for fi in files:
        cubo = fits.open(fi)
        cubo[0].verify('fix')
        data = cubo[0].data
        all_cubos.append(data)
        del data
    return all_cubos

def first_cropping(lista):
    cropl = np.nanmin([item.shape for item in lista])
    new_lista = []
    for item in lista: 
        y,x = item.shape
        startx = x//2 - cropl//2
        starty = y//2 - cropl//2
        new_lista.append(item[starty:starty+cropl,startx:startx+cropl].copy())
    new_lista = np.array(new_lista)
    return new_lista 

def SDO_reader(path,arcpix_alma):
    """SDO 1600,1700,magt are loaded, averaged and resized to the alma pixel size"""
    
    files_magt = sorted(glob.glob(path+'magt/*magnetogram_lev1_sub.fits'))
    files_1600 = sorted(glob.glob(path+'1600/*1600_image_lev1_sub.fits'))
    files_1700 = sorted(glob.glob(path+'1700/*1700_image_lev1_sub.fits'))
    files_0304 = sorted(glob.glob(path+'304/*0304_image_lev1_sub.fits'))
    
    tavg_0304 = np.nanmean(first_cropping(get_avg_cubo(files_0304)),axis=0)
    tavg_1600 = np.nanmean(first_cropping(get_avg_cubo(files_1600)),axis=0)
    tavg_1700 = np.nanmean(first_cropping(get_avg_cubo(files_1700)),axis=0)
    tavg_magt = np.nanmean(first_cropping(get_avg_cubo(files_magt)),axis=0)
    
    arcpix_0304 = fits.open(files_0304[10])[0].header['CDELT1']
    arcpix_1600 = fits.open(files_1600[10])[0].header['CDELT1']
    arcpix_1700 = fits.open(files_1700[10])[0].header['CDELT1']
    arcpix_magt = fits.open(files_magt[10])[0].header['CDELT1']
    
    im_0304 = rescale(tavg_0304, arcpix_0304/arcpix_alma , anti_aliasing=False)
    im_1600 = rescale(tavg_1600, arcpix_1600/arcpix_alma , anti_aliasing=False)
    im_1700 = rescale(tavg_1700, arcpix_1700/arcpix_alma , anti_aliasing=False)
    im_magt = rescale(tavg_magt, arcpix_magt/arcpix_alma , anti_aliasing=False)
    
    rota_magt = fits.open(files_magt[10])[0].header['CROTA2']
    im_magt = scnd.interpolation.rotate(im_magt,angle=rota_magt,reshape=False)
    
    return im_0304,im_1600,im_1700,im_magt,arcpix_0304,arcpix_1600,arcpix_1700,arcpix_alma#,im_0304,arcpix_0304


def SDO_cropping(im_0304,im_1600,im_1700,im_magt):
    cropl = np.min([im_0304.shape,im_1600.shape,im_1700.shape,im_magt.shape])

    y,x = im_0304.shape
    startx = x//2 - cropl//2
    starty = y//2 - cropl//2
    im_0304 = im_0304[starty:starty+cropl,startx:startx+cropl].copy()
    del x,y,startx,starty
    y,x = im_1600.shape
    startx = x//2 - cropl//2
    starty = y//2 - cropl//2
    im_1600 = im_1600[starty:starty+cropl,startx:startx+cropl].copy()
    del x,y,startx,starty
    y,x = im_1700.shape
    startx = x//2 - cropl//2
    starty = y//2 - cropl//2
    im_1700 = im_1700[starty:starty+cropl,startx:startx+cropl].copy()
    del x,y,startx,starty
    y,x = im_magt.shape
    startx = x//2 - cropl//2
    starty = y//2 - cropl//2
    im_magt = im_magt[starty:starty+cropl,startx:startx+cropl].copy()
    del x,y,startx,starty
    
    return im_0304,im_1600,im_1700,im_magt

def decdeg2dms(dd):
    mnt,sec = divmod(dd*3600,60)
    deg,mnt = divmod(mnt,60)
    return deg,mnt,sec

def distance_sun_earth(time0,):
    planets = load('de421.bsp')
    earth = planets['earth']
    sun = planets['sun']
    ts = load.timescale()
    time_ts = ts.utc(time0.year,time0.month,time0.day,time0.hour,time0.minute,time0.second)
    tsun = earth.at(time_ts).observe(sun)
    ra, dec, distance = tsun.radec()
    del ra,dec,time0,time_ts,ts
    return distance

def compute_ctrhelio_sunp(path_alma,frame):
    finit = sorted(glob.glob(path_alma+'*.in_K.nof.fits'))[0]
    hdr = sunpy.map.Map(finit).meta
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

def compute_ctrhelio_sunp_Shahin(path,save,frame='gcrs'):
    """
    This function does for the Reference Time and according to the RA and DEC reported:
        1. Calculate the SkyCoord structure for the positin in GCRS
        2. Transfrm previous structure to Helioprojective
        3. Calculate the SunP angle
    """
    ###Here we use other dataset to extract the obsgeo X,Y,Z of the telescope
    f_nof = sorted(glob.glob('/Users/juancg/Documents/ALMA/data/White/'+'*.image.pbcor.in_K.nof.fits'))
    hdr = sunpy.map.Map(f_nof[0]).meta
    geox0 = float(hdr['obsgeo-x'])
    geoy0 = float(hdr['obsgeo-y'])
    geoz0 = float(hdr['obsgeo-z'])

    ###The input Reference time is taken from https://docs.google.com/spreadsheets/d/1hLPTbQxKZivw8G4ghrftnvhfD66xp4M8sk6_6y-SDB8/edit#gid=1248953869
    trefstr = input('Input reference time in format %Y-%m-%dT%H:%M:%S.%f : ')
    tref = datetime.strptime(trefstr,'%Y-%m-%dT%H:%M:%S.%f')

    ###Coordinates in RA and DEC are taken from the SAVE file
    pathidls = sorted(glob.glob(path+'*.save'))
#     save = idlsave.read(pathidls[0])
    ra0 = float(save['ra'][0])*u.deg
    dec0 = float(save['dec'][0])*u.deg

    ###Distance in the reference time
    distance = distance_sun_earth(tref,)

    ###Coordinates of ALMA site
    alma_site = EarthLocation.from_geocentric(geox0,geoy0,geoz0,unit=u.m)

    ###SkyCoord of sun observed from ALMA site
    frame_ctro = SkyCoord(ra=ra0,dec=dec0,frame=frame,distance=distance.km*u.km,obstime=tref,location=alma_site,observer='earth')
    frame_ctrh = frame_ctro.helioprojective

    ###Sun P-angle
    sunpangle = get_sun_P(tref).value
    
    return frame_ctro,frame_ctrh,sunpangle,tref

def download_sdo_aia_hmi(tsdo_init_dwl,tsdo_fina_dwl,Tx,Ty,aiasq):
    os.system('mkdir SDO')
    os.system('mkdir SDO/304')
    os.system('mkdir SDO/1600')
    os.system('mkdir SDO/1700')
    os.system('mkdir SDO/magt')
    
    ##Downloading AIA
    wl = [304,1600,1700]
    print('Donwloading SDO/AIA data')
    for item in tqdm.tqdm(wl):
        print('Downloading %i A'%item)
        result = Fido.search(SAF.Time(tsdo_init_dwl, tsdo_fina_dwl), 
                             SAF.Instrument("aia"), SAF.Wavelength(item*u.angstrom), 
                             SAF.vso.Sample(12*u.second))
        path_download = 'SDO/'+str(item)
        file_download = Fido.fetch(result, path=path_download,site='ROB')
        #SAving AIA time sequence
        file_download = sorted(file_download)
        # Load all files into a Map sequence
        tmp = sunpy.map.Map(file_download)
        #Cropping defined area
        # In this case, we do not run aiaprep because we're only using one channel
        aia_seq = []
        for img in tmp:
            top_right = SkyCoord((Tx+aiasq)*u.arcsec, (Ty+aiasq)*u.arcsec, frame=img.coordinate_frame)
            bottom_left = SkyCoord((Tx-aiasq)*u.arcsec, (Ty-aiasq)*u.arcsec, frame=img.coordinate_frame)
            aia_seq.append(img.submap(top_right, bottom_left))
        new_files = [a.split('lev1')[0] + 'lev1_sub.fits' for a in file_download]
        for img, file_name in zip(aia_seq, new_files):
            img.save(file_name)
    del wl,result,path_download,file_download,tmp,aia_seq,new_files,img
    
    ###Downloading Magnetograms
    wl = ['LOS_magnetic_field']
    print('Donwloading SDO/HMI data')
    for item in tqdm.tqdm(wl):
        print('Downloading %s'%item)
        result = Fido.search(SAF.Time(tsdo_init_dwl, tsdo_fina_dwl), 
                             SAF.Instrument("hmi"), SAF.vso.Physobs(item), 
                             SAF.vso.Sample(12*u.second))
        path_download = 'SDO/magt/'
        file_download = Fido.fetch(result, path=path_download,site='ROB')
        #SAving AIA time sequence
        file_download = sorted(file_download)
        ###Load all files in map sequence
        tmp = sunpy.map.Map(file_download)
        #Cropping defined area
        # In this case, we do not run aiaprep because we're only using one channel
        aia_seq = []  #It could be called hmi_seq but it is just a variable
        for img in tmp:
            top_right = SkyCoord((Tx+aiasq)*u.arcsec, (Ty+aiasq)*u.arcsec, frame=img.coordinate_frame)
            bottom_left = SkyCoord((Tx-aiasq)*u.arcsec, (Ty-aiasq)*u.arcsec, frame=img.coordinate_frame)
            aia_seq.append(img.submap(top_right, bottom_left))
        new_files = [a.split('.fits')[0] + '_lev1_sub.fits' for a in file_download]
        for img, file_name in zip(aia_seq, new_files):
            img.save(file_name)
            
    return print('The download process for SDO and HMIhasve finished.' +'\n The Co-alignment process continues...')

def download_hmi(tsdo_init_dwl,tsdo_fina_dwl,Tx,Ty,aiasq):
        ###Downloading Magnetograms
    wl = ['LOS_magnetic_field']
    print('Donwloading SDO/HMI data')
    for item in tqdm.tqdm(wl):
        print('Downloading %s'%item)
        result = Fido.search(SAF.Time(tsdo_init_dwl, tsdo_fina_dwl), 
                             SAF.Instrument("hmi"), SAF.vso.Physobs(item), 
                             SAF.vso.Sample(12*u.second))
        path_download = 'SDO/magt/'
        file_download = Fido.fetch(result, path=path_download,site='ROB')
        #SAving AIA time sequence
        file_download = sorted(file_download)
        ###Load all files in map sequence
        tmp = sunpy.map.Map(file_download)
        #Cropping defined area
        # In this case, we do not run aiaprep because we're only using one channel
        aia_seq = []  #It could be called hmi_seq but it is just a variable
        for img in tmp:
            top_right = SkyCoord((Tx+aiasq)*u.arcsec, (Ty+aiasq)*u.arcsec, frame=img.coordinate_frame)
            bottom_left = SkyCoord((Tx-aiasq)*u.arcsec, (Ty-aiasq)*u.arcsec, frame=img.coordinate_frame)
            aia_seq.append(img.submap(top_right, bottom_left))
        new_files = [a.split('.fits')[0] + '_lev1_sub.fits' for a in file_download]
        for img, file_name in zip(aia_seq, new_files):
            img.save(file_name)
    print('Done!')

def mse(x, y):
    return np.linalg.norm(x - y)


# for j,boxj in tqdm.tqdm(enumerate(windows_sdo_combined)):
def find_ssim(boxj,mascara,img_alma_comp,range_im_alma):
    for i,boxi in enumerate(boxj):
#         print(i)
        img = mascara*boxi
        img[img == 0] = 0
#         print(img.shape,img_alma_comp.shape)
        
        yield ssim(img, img_alma_comp,data_range=range_im_alma)#,mse(img, img_alma_comp)
        
def find_smse(boxj,mascara,img_alma_comp,range_im_alma):
    for i,boxi in enumerate(boxj):
#         print(i)
        img = mascara*boxi
        img[img == 0] = 0
#         print(img.shape,img_alma_comp.shape)
        
        yield mse(img, img_alma_comp)
        
if __name__=='__main__':
    ###Enter ALMA data path
    path_alma = input('Enter AlMA path: ')
    #Load ALMA data
    im_alma,arcpix_alma,talma,saveidl = ALMA_cube_reader_Shahin(path_alma)
    im_alma_min = np.nanmin(im_alma)
    im_alma_max = np.nanmax(im_alma)
    range_im_alma = im_alma_max - im_alma_min
    ###Find ALMA data solar center in Helioprojective
    frame_ctro,frame_ctrh,sunpangle,tref = compute_ctrhelio_sunp_Shahin(path_alma,saveidl,'gcrs')
    
    ###Define parameter for looking the SDO and HMI images
    tsdo_init_dwl = datetime.strftime(talma[0]-timedelta(seconds=5*60),'%Y-%m-%dT%H:%M:%S')
    tsdo_fina_dwl = datetime.strftime(talma[-1]+timedelta(seconds=5*60),'%Y-%m-%dT%H:%M:%S')
    Tx = frame_ctrh.Tx.value
    Ty = frame_ctrh.Ty.value
    print('Initial Center (x,y) in arcsec is: ', [Tx,Ty])
    rcomp = float(eval(input("Comparision FOV with SDO?: ")))
    xsize = int(im_alma.shape[1] * arcpix_alma)*rcomp
    ysize = int(im_alma.shape[0] * arcpix_alma)*rcomp
    aiasq = int(xsize)
    ###Download SDO HMI/AIA data
    confirmation = input('SDO data already exist? Y/N:')
    if confirmation=='n' or confirmation=='N':
        download_sdo_aia_hmi(tsdo_init_dwl,tsdo_fina_dwl,Tx,Ty,aiasq)
    else:
        print('proceding with the remaining proccess')
    ###Reading and resizing and cropping SDO data
    path_sdo = './SDO/'
    im_0304,im_1600,im_1700,im_magt,arcpix_0304,arcpix_1600,arcpix_1700,arcpix_alma = SDO_reader(path_sdo,arcpix_alma)
    im_0304,im_1600,im_1700,im_magt = SDO_cropping(im_0304,im_1600,im_1700,im_magt)
    ###SDO images combined for comparision with ALMA image
#     sdo_combined = (np.interp(im_0304, (np.nanmin(im_0304),np.nanmax(im_0304)), (0, +1)) + 
#                     np.interp(im_1600, (np.nanmin(im_1600),np.nanmax(im_1600)), (0, +1)) + 
#                     np.interp(im_1700, (np.nanmin(im_1700),np.nanmax(im_1700)), (0, +1)) +
#                     np.interp(im_magt, (np.nanmin(im_magt),np.nanmax(im_magt)), (0, +1))) /4
    sdo_combined = (np.interp(im_1600, (np.nanmin(im_1600),np.nanmax(im_1600)), (0, +1)) + 
                    np.interp(im_1700, (np.nanmin(im_1700),np.nanmax(im_1700)), (0, +1)) +
                    np.interp(im_magt, (np.nanmin(im_magt),np.nanmax(im_magt)), (0, +1))) /3
    sdo_combined = np.interp(sdo_combined,(np.nanmin(sdo_combined),np.nanmax(sdo_combined)), (0, +1)) ##image is re-escale for comparision with 0-1 ALMA image
    ###Rotated ALMA image according to Sun P for comparision
    im_alma_inter = np.interp(im_alma, (im_alma_min,im_alma_max), (0,+1))
    im_alma_rot = im_alma_inter.copy()
    im_alma_rot[np.isnan(im_alma_rot)] = -1
    im_alma_rot = scnd.interpolation.rotate(im_alma_rot,angle=sunpangle,reshape=False)
    hwalma= im_alma.shape[0]
    mascara = create_circular_mask(hwalma,hwalma,radius=(hwalma/2)-1)
    im_alma_rot[~mascara] = -0.1
    # ###Rotated ALMA image for comparision
    # im_alma_inter = np.interp(im_alma, (im_alma_min,im_alma_max), (0,+1))
    # im_alma_rot = im_alma_inter.copy()
    # im_alma_rot[np.isnan(im_alma_rot)] = -1
    # im_alma_rot = scnd.interpolation.rotate(im_alma_rot,angle=sunpangle,reshape=False)
    # hwalma= im_alma.shape[0]
    # mascara = create_circular_mask(hwalma,hwalma,radius=(hwalma/2)-1)
    # im_alma_rot[~mascara] = -0.1
    ###Preparing SDO_combined data windows for compare with ALMA image size
    windows_sdo_combined = rw.rolling_window(sdo_combined,(hwalma,hwalma))
    im_alma_ssim = np.empty(np.shape(sdo_combined))
    im_alma_ssim[:] = np.nan
    im_alma_smse = np.empty(np.shape(sdo_combined)) 
    im_alma_smse[:] = np.nan
    print('Starting co-alignment process')

    #Esta es la parte que toca mirar como paralelizar
    if (im_1600.shape[0]-windows_sdo_combined.shape[0])%2 != 0:
        list_izq = np.empty((1,int(hwalma/2)-1))
        list_izq[:] = np.nan
        list_izq = list_izq.tolist()[0]
        list_der = np.empty((1,int(hwalma/2)))
        list_der[:] = np.nan
        list_der = list_der.tolist()[0]
    else:
        list_izq = np.empty((1,int(hwalma/2)))
        list_izq[:] = np.nan
        list_izq = list_izq.tolist()[0]
        list_der = np.empty((1,int(hwalma/2)))
        list_der[:] = np.nan
        list_der = list_der.tolist()[0]
    for j,boxj in tqdm.tqdm(enumerate(windows_sdo_combined)):
        list_generador = list_izq+list(find_ssim(boxj,mascara,im_alma_rot,range_im_alma))+list_der
    #     im_alma_smse[j+102,item[2]+102] = item[0]
        im_alma_ssim[j+int(hwalma/2)] = list_generador
        del list_generador
        list_generador = list_izq+list(find_smse(boxj,mascara,im_alma_rot,range_im_alma))+list_der
    #     im_alma_smse[j+102,item[2]+102] = item[0]
        im_alma_smse[j+int(hwalma/2)] = list_generador
        del list_generador
    ###ALMA image masked to fOV
    mascara = create_circular_mask(hwalma,hwalma,radius=(hwalma/2)-1)
    im_alma_rot[~mascara] = np.nan
    ###alculating the centre coordinates
    ypos_ssim,xpos_ssim = int(np.where(im_alma_ssim==np.nanmax(im_alma_ssim))[0]),int(np.where(im_alma_ssim==np.nanmax(im_alma_ssim))[1])
    ypos_smse,xpos_smse = int(np.where(im_alma_smse==np.nanmin(im_alma_smse))[0]),int(np.where(im_alma_smse==np.nanmin(im_alma_smse))[1])
    xpos_avg = (xpos_ssim+xpos_smse)/2.
    ypos_avg = (ypos_ssim+ypos_smse)/2.
    xpos_sdo = sdo_combined.shape[1]//2
    ypos_sdo = sdo_combined.shape[0]//2
    Tx_new = Tx - ((xpos_sdo-xpos_avg)*arcpix_alma)
    Ty_new = Ty - ((ypos_sdo-ypos_avg)*arcpix_alma)
    xpos_err = np.abs(xpos_ssim-xpos_smse)/2
    ypos_err = np.abs(ypos_ssim-ypos_smse)/2
    Tx_err = xpos_err*arcpix_alma
    Ty_err = ypos_err*arcpix_alma
    rfov_alma = (len(im_alma_rot)/2)*arcpix_alma
    rfov_pixe = (len(im_alma_rot)/2)
    print('')
    print('ALMA FOV arcsec: ',rfov_alma)
    print('Initial Center in arcsec is: ', [Tx,Ty])
    print('Calculated Center in arcsec is: ', [Tx_new,Ty_new])
    print('Error in arcsec: ', [Tx_err,Ty_err])
    
    
    header = "Solar-X [arcsec],Solar-X [error], Solar-Y [arcsec],Solar-Y [error]"
    data_pos_err = np.column_stack((Tx_new,Tx_err,Ty_new,Ty_err))
    np.savetxt('./solarh_centre.dat',data_pos_err, header=header)
    
    confirmation2 = input('Do you want to plot AIA 1700 and SSIM SMSE? Y/N:')
    if confirmation2=='Y' or confirmation2=='y':
        print('Plotting ALMA FOV in context')
        fig,ax = plt.subplots(ncols=4,nrows=1)
        
        circulo = matplotlib.patches.Circle((xpos_avg,ypos_avg),rfov_pixe,fc='None',ec='white')
        ax[0].imshow(sdo_combined,origin='lower',cmap='sdoaia304') 
        ax[0].set_title(r'SDO/AIA Combined')
        ax[0].add_patch(circulo)
        
        ax[1].imshow(im_alma_rot,origin='lower',cmap='sdoaia304')
        ax[1].set_title('ALMA average')
        
        ax[2].imshow(im_alma_ssim,origin='lower',cmap='jet')
        ax[2].set_title(r'SSIM image')
        
        ax[3].imshow(im_alma_smse,origin='lower',cmap='jet')
        ax[3].set_title(r'SMSE image')
        
        plt.tight_layout()
        plt.show()
    else:
        print('The proccess has finished')   