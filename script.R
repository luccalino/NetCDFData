library(raster)
library(rgdal)
library(sf)
library(tidyverse)
library(ncdf4) # package for netcdf manipulation
library(stars)
library(chron)
library(lattice)
library(RColorBrewer)

# Municipality data
muniShape <- readOGR("data/swissBOUNDARIES3D_1_3_TLM_HOHEITSGEBIET.shp")

#ggplot() + 
#  geom_polygon(data = muniShape, aes(x = long, y = lat, group = group), 
#               colour = "black", fill = NA)
          
# NetCDF data
## Open connection
nc <- nc_open("data/SnormM9120_ch01r.swiss.lv95_000001010000_000012010000.nc")

## Print content
print(nc)

## Extract coordinates
lon <- ncvar_get(nc, "E")
lat <- ncvar_get(nc, "N")

## Get time
time <- ncvar_get(nc,"time")
time

tunits <- ncatt_get(nc,"time","units")
nt <- dim(time)
nt
tunits

## Get variable of interest
dname = "SnormM9120"
tmp_array <- ncvar_get(nc,dname)
dlname <- ncatt_get(nc,dname,"long_name")
dunits <- ncatt_get(nc,dname,"units")
fillvalue <- ncatt_get(nc,dname,"_FillValue")
dim(tmp_array)

## Get global attributes
title <- ncatt_get(nc,0,"title")
institution <- ncatt_get(nc,0,"institution")
references <- ncatt_get(nc,0,"References")
Conventions <- ncatt_get(nc,0,"Conventions")

## Close connection
nc_close(nc)

## TBD
tustr <- strsplit(tunits$value, " ")
tdstr <- strsplit(unlist(tustr)[3], "-")
tmonth <- as.integer(unlist(tdstr)[2])
tday <- as.integer(unlist(tdstr)[3])
tyear <- as.integer(unlist(tdstr)[1])
chron(time,origin=c(tmonth, tday, tyear))

tmp_array[tmp_array==fillvalue$value] <- NA

length(na.omit(as.vector(tmp_array[,,1])))

# get a single slice or layer (August)
m <- 8
tmp_slice <- tmp_array[,,m]

image(lon,lat,tmp_slice, col=rev(brewer.pal(10,"RdBu")))

# levelplot of the slice
grid <- expand.grid(lon=lon, lat=lat)

lonlat <- as.matrix(expand.grid(lon,lat))
dim(lonlat)

tmp_vec <- as.vector(tmp_slice)
length(tmp_vec)

tmp_df01 <- data.frame(cbind(lonlat,tmp_vec))
names(tmp_df01) <- c("lon","lat",paste(dname,as.character(m), sep="_"))
head(na.omit(tmp_df01), 10)

dfr1 <- rasterFromXYZ(tmp_df01)  

## Convert the whole array to a data frame, and calculate MTWA, MTCO and the annual mean
### Reshape the array into vector
tmp_vec_long <- as.vector(tmp_array)
length(tmp_vec_long)

### Reshape the vector into a matrix
nlat <- dim(lat)
nlon <- dim(lon)
tmp_mat <- matrix(tmp_vec_long, nrow=nlon*nlat, ncol=nt)
dim(tmp_mat)
head(na.omit(tmp_mat))

### Create a dataframe
lonlat <- as.matrix(expand.grid(lon,lat))
tmp_df02 <- data.frame(cbind(lonlat,tmp_mat))
names(tmp_df02) <- c("lon","lat","tmpJan","tmpFeb","tmpMar","tmpApr","tmpMay","tmpJun",
                     "tmpJul","tmpAug","tmpSep","tmpOct","tmpNov","tmpDec")
### options(width=96)
head(na.omit(tmp_df02, 20))

### Get the annual mean and MTWA and MTCO
tmp_df02$mtwa <- apply(tmp_df02[5:11],1,max) # mtwa
tmp_df02$mtco <- apply(tmp_df02[5:11],1,min) # mtco
tmp_df02$mat <- apply(tmp_df02[5:11],1,mean) # annual (i.e. row) means
head(na.omit(tmp_df02))

tmp_df02 <- tmp_df02 %>%
  select(lon, lat, mat)

### Make data frame
dfr2 <- rasterFromXYZ(tmp_df02)  

# Calculate mean per municipality
meanSun <- raster::extract(dfr2, muniShape, weights = FALSE, df = TRUE, fun = mean)
meanSun$BFS_NUMMER <- as.numeric(muniShape$BFS_NUMMER)

muniShape$meanSun <- meanSun$mat[match(muniShape$BFS_NUMMER, meanSun$BFS_NUMMER)]

# Test plot
shp_df <- broom::tidy(muniShape, region = "meanSun")
shp_df$id <- as.numeric(shp_df$id)

destination <- ggplot() + 
  geom_polygon(data = shp_df, 
               aes(x = long, y = lat, group = group, fill = id), 
               colour = NA, size = 0.25) + 
  scale_fill_gradient2(name = "Mean sunshine duration from March to September from 1991-2020 relative to max possible", low = "blue", mid = "white", high = "red", midpoint = mean(shp_df$id)) +
  theme_void() +
  theme(legend.position = "bottom") +
  coord_equal() 

ggsave(destination, file = "output/destination.png", width = 25, height = 20, bg = "white", units = "cm")  

# https://pjbartlein.github.io/REarthSysSci/netCDF.html

# BFS to PLZ4
muniShape_df <- data.frame(muniShape)
muniShape_df$BFS_NUMMER <- as.numeric(muniShape_df$BFS_NUMMER)
muniShape_df <- muniShape_df %>%
  filter(GEM_TEIL < 2) %>%
  select(BFS_NUMMER, NAME, meanSun)

plz_to_bfs <- read_excel("data/plz_to_bfs.xlsx", sheet = "PLZ4")

merged_df <- merge(plz_to_bfs, muniShape_df, by.x = "GDENR", by.y = "BFS_NUMMER")

merged_df <- merged_df %>%
  group_by(PLZ4) %>%
  summarise(meanSun = mean(meanSun))

save(merged_df, file = "plz_data.RData")
