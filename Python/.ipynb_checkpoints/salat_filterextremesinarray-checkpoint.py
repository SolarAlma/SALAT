import numpy as np


def filtrering(data0f, minval, maxval, stds):
	"""
    Author: Eklund, H

	#Filtering out spatial magnitudes deviating from defined values by spatial averaging the neighbouring cells. 
	#Inputs: (2D array, minimum allowed value, maximum allowed value, number of std deviations from mean accepted)
	#Outputs: filtered 2D array

	"""
    data0f[data0f>maxval]=np.nan
    data0f[data0f<minval]=np.nan
    data0f[data0f>np.nanmean(data0f)+stds*np.nanstd(data0f)]=np.nan
    # extract positions of all locations marked nan
    tarr1=np.argwhere(np.isnan(data0f))
    print('amount of filtered values:', len(tarr1), 'corresponding to a ratio of total values:', len(tarr1)/(data0f.shape[0]*data0f.shape[1]))
    counter1=0
    for k0 in range(tarr1.shape[0]):
    #     print(k0)
        counter+=1
        if counter==int(tarr1.shape[0]/10):
            print(',', end='')
            counter=0
        if tarr1[k0][0]<3 and tarr1[k0][1]>2: 
            data0f[tarr1[k0][0],tarr1[k0][1]]=np.nanmean(data0f[0:tarr1[k0][0]+2,tarr1[k0][1]-2:tarr1[k0][1]+2])
        elif tarr1[k0][0]>2 and tarr1[k0][1]<3:
            data0f[tarr1[k0][0],tarr1[k0][1]]=np.nanmean(data0f[tarr1[k0][0]-2:tarr1[k0][0]+2,0:tarr1[k0][1]+2])
        elif tarr1[k0][0]<3 and tarr1[k0][1]<3:
            data0f[tarr1[k0][0],tarr1[k0][1]]=np.nanmean(data0f[0:tarr1[k0][0]+2,0:tarr1[k0][1]+2])
        else:
            data0f[tarr1[k0][0],tarr1[k0][1]]=np.nanmean(data0f[tarr1[k0][0]-2:tarr1[k0][0]+2,tarr1[k0][1]-2:tarr1[k0][1]+2])
    return data0f