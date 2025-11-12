# Swiss Weather Data Processing Script — Overview

This repo contains material to aggregate/manipulate data from a NetCDF file (e.g. sunshine duration or hail) into spatial regions, e.g. municipalities in Switzerland by means of averaging the cells as in the shown case of the mean average sunshine duration from March to September from 1991 to 1990 relative to the maximum possible (in %). This R script processes Swiss meteorological data (NetCDF files) for sunshine and hail and aggregates it by municipality and postal code areas (PLZ4). It generates spatial visualizations and exports processed data for further analysis.

## Description

### 1. Required Packages

The script uses the following R packages:
- raster, stars, ncdf4 — for handling raster and NetCDF data.
- sf — for vector spatial data (municipalities, country boundaries).
- tidyverse — for data manipulation and aggregation.
- chron — for handling date-time data from NetCDF files.
- lattice, RColorBrewer — for plotting grids and colors.
- readxl — for reading Excel mapping files.

### 2. Spatial Data Loading

Municipality boundaries are loaded from a shapefile (muniShape) and Z/M dimensions are dropped to keep 2D geometries. Country boundaries (country_data) are loaded to provide a background map.

### 3. Sunshine Data Processing

Opens a NetCDF file containing monthly sunshine data (SnormM6190) for Switzerland. Extracts: Coordinates (lon, lat), Time variable, Sunshine variable (tmp_array), Metadata (units, attributes, fill values)

Converts fill values to NA to handle missing data. Extracts a single month slice (e.g., August) and visualizes it using image() and levelplot. Converts the raster array into a long-format data frame for all months.

Computes: Annual mean sunshine (mat), Maximum (mtwa) and minimum (mtco) sunshine between March–September. Converts the annual mean raster to a RasterLayer (dfr2) for spatial analysis. Calculates the mean sunshine per municipality using raster::extract(). Adds the calculated mean to the municipality shapefile. Plots a choropleth map of mean sunshine per municipality over Switzerland and saves it as destination_sun.png.

Aggregates municipality data to PLZ4 level using a mapping Excel file and saves as plz_data_sunshine.RData.

#### 3.1 Visualisation
In visual terms, the material here converts detailed data from cells that include measurements in 2 km grids as shown below...

![origin](/output/origin_sun.png)

... to averages per region, here Swiss municipalities as shown below

![destination](/output/destination_sun.png)

#### 3.2 Data

The data comes from here [https://data.geo.admin.ch/ch.meteoschweiz.klimanormwerte-sonnenscheindauer_1961_1990/data.zip](https://data.geo.admin.ch/ch.meteoschweiz.klimanormwerte-sonnenscheindauer_1961_1990/data.zip) and here [https://data.geo.admin.ch/browser/index.html#/collections/ch.meteoschweiz.klimanormwerte-sonnenscheindauer_1961_1990?.language=en](https://data.geo.admin.ch/browser/index.html#/collections/ch.meteoschweiz.klimanormwerte-sonnenscheindauer_1961_1990?.language=en).

### 4. Hail Data Processing
The data contain the yearly number of hail days per year of the summer half-year (April to September), per km2. Hail cannot be measured on the ground over a wide area. The size is derived from radar measurements. A hail day is defined as a day on which a high probability of hail on the ground was concluded from the radar measurements (based on radar parameter POH). The 24 hours between 06 UTC and 06 UTC of the following day are considered. DOI: [https://doi.org/10.18751/Climate/Griddata/CHHC/1.0](https://doi.org/10.18751/Climate/Griddata/CHHC/1.0). Data processing is similar as described in 3. above. 

Data is again converted from ...

![origin](/output/origin_hail.png)

to ...

![destination](/output/destination_hail.png)

Note: The original graph shows hail days from the year 2009, while the aggregated graphs shows averages from 2002 until 2022. 

The data comes from here [https://data.geo.admin.ch/ch.meteoschweiz.klima/hageltage/Swiss-hail-climatology_haildays.zip](https://data.geo.admin.ch/ch.meteoschweiz.klima/hageltage/Swiss-hail-climatology_haildays.zip) or here [https://www.geocat.ch/geonetwork/srv/eng/catalog.search#/metadata/40cdcddd-8bf0-4cfd-ac1e-6e4683fb0176](https://www.geocat.ch/geonetwork/srv/eng/catalog.search#/metadata/40cdcddd-8bf0-4cfd-ac1e-6e4683fb0176).

## Other datasets
Rich additional spatial datasets can be found here: [https://data.geo.admin.ch/](https://data.geo.admin.ch/).
