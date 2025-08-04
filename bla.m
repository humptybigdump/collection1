from typing import Dict, Any
import torch
from torch.util.data import Dataset

from metacatalog import api


class MetacatalogDataset(Dataset):
	def __init__(self, database_uri: str, , label_name: str, filter_params: Dict[str, Any] = {}):
		self.__db = api.connect_database(database_uri)
		self._label_ = label_name
		self._filter_ = filter_params
		
		self._filter_.update({'return_iterator': True})
		self.__preload()
		self._ids = [e.id for e in self.entries]
		
	def __preload(self):
		self.entries = api.find(self.__db, **self.filter_)
		
	def __len__(self):
		if not hasattr(self, '_len'):
			with self.__db.connect() as con:
				self._len = con.execute(f"SELECT count(*) FROM entries WHERE id in ({''.join(self._ids)})")
		return self._len
			
	def __getitem__(self, idx):
		entry = self.entries[idx]
		
		label = entry.to_dict(flat=True)[self._label_]
		data = entry.read_data()
		
		return data, label
