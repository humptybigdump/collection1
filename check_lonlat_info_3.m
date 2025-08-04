function iflag = check_lonlat_info
global MIN_LAT MAX_LAT ZERO_LAT MIN_LON MAX_LON ZERO_LON
if isempty(MIN_LAT)==1 | isempty(MAX_LAT)==1
   iflag = 0; 
elseif isempty(MIN_LON)==1 | isempty(MAX_LON)==1
   iflag = 0; 
elseif isempty(ZERO_LAT)==1 | isempty(ZERO_LON)==1
   iflag = 0; 
else
   iflag = 1;
end