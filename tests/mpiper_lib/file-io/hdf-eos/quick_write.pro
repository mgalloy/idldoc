
openw, 1, 'sample_data.txt'
printf, 1, 'Sample data - 30 lon, lat and surface temperature values from an AIRS L2 StdRet Product'
printf, 1
for i=0,29 do printf, 1, lon[i], lat[i], tsurf[i]
close, 1
end
