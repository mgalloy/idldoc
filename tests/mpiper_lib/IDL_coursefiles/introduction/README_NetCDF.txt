These directories contain the data archive files from the NCAR Mesa Lab
and Foothills Lab weather station.  We will make an attempt to put the
data for the previous month online after the month is over, this is
currently done manually.

We have received many requests for the data and are releasing
it to the public on an as-is basis.

The data is not considered research grade and NCAR assumes
no responsibility or liability for its accuracy.
The stations are not calibrated regularly.

Beware that due to microclimate effects, there is no single
value that describes the "temperature in Boulder" at a given
time, all of the weather data varies considerably across town
and from one side of a building to another.  Also, the Foothills
Lab station is not in an optimal location for wind speed measurements
and tends to give low readings during very windy times.
An intercomparison of temperature sensors involving the foothills
lab station and a locally developed sensor indicated a potential
problem with the foothills station, when the wind was below a few
miles per hour, the foothills station read several degrees higher
than the reference thermometer.  This probably affects the Mesa Lab
station as well.

Data (.cdf) files should be copied via FTP in binary mode, they
are in NetCDF format and can be viewed and translated into ASCII
with NetCDF utilities such as ncdump.  See the web page:

http://www.unidata.ucar.edu/packages/netcdf/index.html

for information on NetCDF, there are free programs available
for viewing netcdf files on various operating system platforms
as well as access libraries for the C and Perl languages.
We cannot offer support for use of this code, you are on your own.

This data is plotted out daily on the web pages:
http://www.atd.ucar.edu/cgi-bin/mlabweather
http://www.atd.ucar.edu/cgi-bin/flabweather

There are links off of the main web pages that explain station details.
Please read all of the weather station pages before asking us for help,
especially the page titled "weather station pictures and specifications" at:
http://www.atd.ucar.edu/weather_fl/station.html
http://www.atd.ucar.edu/weather_ml/station.html

Here is a C language description of the data fields:
Note that the data for each day starts at
00:00 GMT (6:00 PM Mountain Standard Time)

int base_time ;			Unix time, seconds since 1970
int samp_secs ;			Sample interval in seconds
float lat ;			Station Latitude in degrees.fraction
float lon ;			Station Longitude in degrees.fraction
float alt ;			Station Elevation in meters
int station ;			Coastal Climate Weather Station ID
float time_offset(time) ;	Sample time after beginning of day
float tdry(time) ;		Temperature in degrees C
float rh(time) ;		Relative humidity in percent
float pres(time) ;		Absolute pressure in millibars
float cpres0(time) ;		Aeronautical correctted pressure in mb
float dp(time) ;		Dew point temperature in degrees C
float wdir(time) ;		Wind direction in degrees from North
float wspd(time) ;		Wind speed in meters/sec
float wmax(time) ;		Maximum wind speed in meters/sec
float wsdev(time) ;		Wind speed standard deviation
float wchill(time) ;		Wind chill temperature in degrees C
float raina(time) ;		Rain accumulation in millimeters, resets hourly
float raina24(time) ;		Rain accumulation in millimeters, resets daily
float bat(time) ;		Battery voltage in Volts

The foothills directory contains the archive for the NCAR foothills lab
weather station and the mesa directory contains the archive for the NCAR
mesa lab weather station.



May 6, 1999
We have created a bin directory with pre compiled versions of ncdump for
several operating systems, that program is all that you need to convert
the .cdf data files into ascii dumps.  Download the appropriate file for
your operating system, and type: [ncdump filename.cdf] to see listing of
the data.  Sorry, but we can only provide ncdump for platforms that we
actively use, if you have another OS, please see the unidata web page above
for source code. There is also an ncgrab utility which will run on solaris
and MS-DOS including windoze. Simply run ncgrab from a command line prompt
to get usage help.


