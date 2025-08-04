from .util import Position
from .synth_loader import Data_Loader
import numpy as np
import os


cwd = os.getcwd()+'/Wave_ani/'


# create Data_container directory
Data_container = {}

# define path parameters
Data_container['path'] = {}
Data_container['path']['Stat_file_local'] = cwd+'TextFiles/STATIONS_local'
Data_container['path']['Stat_file_circ'] = cwd+'TextFiles/STATIONS_circ'
Data_container['path']['synthetic_data_path'] = cwd+'Data/Synthetics/Fund_Events_50_10lay/'

# define network sub directory
Data_container['network'] = {}
Data_container['network']['dist_range'] = 500
Data_container['network']['Comp_Notation'] = 'BX'
Data_container['network']['Network_Name'] = 'XX'
    
# define source information sub directory
Data_container['source'] = {} 
Data_container['source']['location'] = {'circ':{},'local':{},'global':{}}
Data_container['source']['location']['circ'] = np.array([50,50*10**3,50*10**3])
Data_container['source']['location']['local'] = np.array([50,200*10**3,200*10**3])
Data_container['source']['location']['global'] = None
    
# get position information from the station files
# the Station_dict containes information about the circular (fundamental) and local (observation) system
# type in print(Station_dict.keys()) to get more information
Data_container['network']['Station_files'] = {}
Station_dict = Position(Data_container=Data_container).get_position()
Data_container['network']['Station_files'] = Station_dict

# define processing sub directory
Data_container['processing'] = {}
Data_container['processing']['Filter'] = {'ftype':'bandpass','freqmin':0.04,'freqmax':0.1,'corners':4} 
    
# get fundamental waveforms
Data_container['waveform'] = {}
Data_container['waveform']['fundamental'] = Data_Loader(Data_container=Data_container).load_synt()
