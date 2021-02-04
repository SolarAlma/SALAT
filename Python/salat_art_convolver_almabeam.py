###Extra
import warnings
warnings.filterwarnings('ignore')

###NUMPY
import numpy as np

###Dask 
import dask
from dask.distributed import Client, LocalCluster
from dask import delayed

###Usual matplotlib tools
import matplotlib
import matplotlib.pyplot as plt

###SCIPY
import scipy
from scipy import ndimage

###AstroPy tools for FITS, units, etc
import astropy.units as u
from astropy.io import fits

###Importing Sunpy and its colormaps. This allow us to use same SDO colormaps
import sunpy
import sunpy.cm as cm
import sunpy.map

###IDL READER
# import idlsave

###BEAM CREATOR
import radio_beam as rb

#MISCELANEOUS
import tqdm
import time
import glob



def read_ART(path_fname):
	"""
	Read ART simulations and get data, pxsize and freq
	"""
	ART_data = h5py.File(path_fname, "r")
	ART_pxsz = ART_data.attrs['pixsize_in_arcsec']
	ART_freq = ART_data.attrs['freq_in_Ghz']
	return ART_data['intensity'],ART_pxsz,ART_freq

def get_ALMA_obs_beam(path_obs,SOAP=True):
    if SOAP:
        """
        From fits SOAP-type date it extract the median beam (min,maj,pan)
        """
        files_fits_obs = sorted(glob.glob(path_obs+'*.fits'))
        bmaj_obs = np.array([sunpy.map.Map(item).meta['bmaj']*u.deg.to(u.arcsec) for item in tqdm.tqdm(files_fits_obs)])
        bmin_obs = np.array([sunpy.map.Map(item).meta['bmin']*u.deg.to(u.arcsec) for item in tqdm.tqdm(files_fits_obs)])
        bpan_obs = np.array([sunpy.map.Map(item).meta['bpa'] for item in tqdm.tqdm(files_fits_obs)])
        bmaj_obs = np.nanmedian(bmaj_obs)
        bmin_obs = np.nanmedian(bmin_obs)
        bpan_obs = np.nanmedian(bpan_obs)
        print("Beam (maj,min,pan): ",(bmaj_obs,bmin_obs,bpan_obs))
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

def beam_kernel_calulator(bmaj_obs,bmin_obs,bpan_obs,ART_pxsz):
	"""
	Calculate the beam array using the observed beam to be used for convolving the ART data
	"""
	beam = rb.Beam(bmaj_obs*u.arcsec,bmin_obs*u.arcsec,bpan_obs*u.deg)
	beam_kernel = np.asarray(beam.as_kernel(pixscale=ART_pxsz*u.arcsec))
	qa = input("Do you want to plot beam? (y/n): ")

	if qa == 'y' or qa == 'Y':
		extent = [(0 - len(beam_kernel)/2)*ART_pxsz,(0 + len(beam_kernel)/2)*ART_pxsz,(0 - len(beam_kernel)/2)*ART_pxsz,(0 + len(beam_kernel)/2)*ART_pxsz]
		plt.figure(figsize = (6,5))
		plt.imshow(beam_kernel,origin='lower',extent=extent)
# 		plt.colorbar()
		plt.xlabel(r'X-pos [arcsec]')
		plt.ylabel(r'Y-pos [arcsec]')

	return beam_kernel

def ART_BEAM_convolver(ART_data,beam_kernel):
	"""
	Take ART data(any averaged or single frequency) and convolved with the beam
	"""
	print("Convolution process started")
	art_convolved = np.array([ndimage.convolve(item,beam_kernel) for item in tqdm.tqdm(ART_data)])
	return art_convolved


def art_convolver_parallel(item,beam_kernel):
    convolved = ndimage.convolve(item,beam_kernel)
    return convolved


if __name__ == '__main__':

	# cluster = LocalCluster()
	# client = Client(cluster)
	# set up cluster and workers
	client = Client(n_workers=6, 
	                threads_per_worker=4,
	                memory_limit='400GB')

	###Viene de la lecutra de todos los H5 de ART
	ART_pxsz = 0.066#565696965593813

	# avg_ART_data  = np.load("./avg_ART_data_HIGHRES.npy",allow_pickle=True)
	avg_ART_data  = np.load("./Bifrost_ART_b3.npy",allow_pickle=True)


	# path_alma_sav = '/Users/juancg/Documents/ALMA/almaobs_level4/b3__2018-04-12/solaralma.b3.2018-04-12.15:52:28-16:24:41__2017.1.00653.S_clean.save'

	#bmaj_obs,bmin_obs,bpan_obs = get_ALMA_obs_beam(path_alma_sav,SOAP=False)
	bmaj_obs,bmin_obs,bpan_obs = 2.5167254148982465, 1.786149200052023, 82.53234###Vienen del FITS de los datos pero ya los conozco aquí mirar laptop 

	beam_kernel = beam_kernel_calulator(bmaj_obs,bmin_obs,bpan_obs,ART_pxsz)

	print('Empezando proceso paralelo')

	start = time.time()

	delayed_results = []

	for item in tqdm.tqdm(avg_ART_data[:]):
	    conv_results = dask.delayed(art_convolver_parallel)(item,beam_kernel)
	    delayed_results.append(conv_results)
	    
	futures = dask.persist(*delayed_results)  # trigger computation in the background

	results = dask.compute(*futures)

	client.close()


	print('It took', time.time()-start, 'seconds.')

	np.save("./BIFROST_ART_b3_LOWRES.npy",np.array(results),allow_pickle=True)

