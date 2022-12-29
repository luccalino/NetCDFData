# Sunshine data

## Description
This repo contains material to aggregate/manipulate data from a NetCDF file (e.g. sunshine duration or hail) into spatial regions, e.g. municipalities in Switzerland by means of averaging the cells as in the shown case of the mean average sunshine duration from March to September from 1991 to 2020 relative to the maximum possible (in %).

In visual terms, the material here converts detailed data from cells that include measurements in 2 km grids as shown below...

![origin](/output/origin.png)

... to averages per region, here Swiss municipalities as shown below

![destination](/output/destination.png)

The data comes from here: [https://data.geo.admin.ch/ch.meteoschweiz.klimanormwerte-sonnenscheindauer_1961_1990/data.zip](https://data.geo.admin.ch/ch.meteoschweiz.klimanormwerte-sonnenscheindauer_1961_1990/data.zip)

# Hail data

## Description
The data contain the yearly number of hail days per year of the summer half-year (April to September), per km2. Hail cannot be measured on the ground over a wide area. The size is derived from radar measurements. A hail day is defined as a day on which a high probability of hail on the ground was concluded from the radar measurements (based on radar parameter POH). The 24 hours between 06 UTC and 06 UTC of the following day are considered. DOI: [https://doi.org/10.18751/Climate/Griddata/CHHC/1.0](https://doi.org/10.18751/Climate/Griddata/CHHC/1.0) 

Data is again converted from ...

![origin](/output/origin_hail.png)

to ...

![destination](/output/destination_hail.png)

Note: The original graph shows hail days from the year 2009, while the aggregated graphs shows averages from 2002 until 2022. 

The data comes from here: [https://data.geo.admin.ch/ch.meteoschweiz.klima/hageltage/Swiss-hail-climatology_haildays.zip](https://data.geo.admin.ch/ch.meteoschweiz.klima/hageltage/Swiss-hail-climatology_haildays.zip)

