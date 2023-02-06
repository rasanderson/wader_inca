# Initial pre-processing

# Check the MORECS data downloaded from
# https://doi.org/10.5285/e911196a-b371-47b1-968c-661eb600d83b
library(ncdf4)
library(raster)

rm(list = ls())

# Note: the .nc files are so big that stars automatically reads them as
# stars_proxy objects https://r-spatial.github.io/stars/articles/stars2.html

# Check the files
# Catchment area Area draining each G2G grid box ####
# catchment_cdf <- nc_open("morecs/MaRIUS_G2G_CatchmentAreaGrid.nc")
# 
# lon <- ncvar_get(catchment_cdf, "lon")
# lat <- ncvar_get(catchment_cdf, "lat")
# area <- ncvar_get(catchment_cdf, "area")
# crs <- ncvar_get(catchment_cdf, "crs")

# area_sp <- raster(t(area), crs=crs("+init=epsg:27700"),
#                   xmn = 0,
#                   xmx = 700000,
#                   ymn = 0,
#                   ymx = 100000,
#                   resolution = 10000)

area_cdf <- nc_open("morecs/MaRIUS_G2G_CatchmentAreaGrid.nc")
area_cdf # Print out information about nc file
nc_close(area_cdf)
area_sp <- raster("morecs/MaRIUS_G2G_CatchmentAreaGrid.nc", ncdf=TRUE,
                  varname = "area")
crs(area_sp) <-crs("+init=epsg:27700")

library(leaflet)
area_sp_ll <- projectRaster(area_sp, crs=crs("+init=epsg:4235"))
qpal <- colorQuantile("Blues", area_sp_ll$Catchment_area, n = 7, na.color = NA)
leaflet() %>% 
  addTiles() %>% 
  addRasterImage(area_sp_ll, colors = qpal)

# NRFA stations ####
stations_cdf <- nc_open("morecs/MaRIUS_G2G_NRFAStationIDGrid.nc")
stations_cdf # print out information
nc_close(stations_cdf)
stations_sp <- raster("morecs/MaRIUS_G2G_NRFAStationIDGrid.nc", ncdf=TRUE,
                      varname = "ID")
crs(stations_sp) <-crs("+init=epsg:27700")
# Convert to vector
library(sf)
stations_df <- cbind(coordinates(stations_sp), as.vector(stations_sp))
colnames(stations_df)[3] <- "ID"
stations_df <- data.frame(stations_df)
stations_sf <- st_as_sf(stations_df, coords=c("x","y"), crs = crs("+init=epsg:27700"))
stations_sf <- stations_sf[!is.na(stations_sf$ID), ]
stations_sf <- stations_sf[stations_sf$ID != 0,]
plot(stations_sf)

# MORECS flow 1960 to 2015 ####
flow_cdf <- nc_open("morecs/G2G_MORECS_flow_1960_2015.nc")
flow_cdf
nc_close(flow_cdf)
library(stars)
library(tidyverse)
# If you just read in e.g. 35 months it doesn't need to be a stars_proxy
# flow_stars <- read_ncdf("morecs/G2G_MORECS_flow_1960_2015.nc",
#                         var = "flow",
#                         ncsub = cbind(start=c(1,1,1), count = c(700,1000,35)),
#                         proxy = FALSE)
# Full dataset from Jan 1960 to Dec 2015 (672 months) is a stars_proxy
flow_stars <- read_ncdf("morecs/G2G_MORECS_flow_1960_2015.nc", var="flow")
st_crs(flow_stars) <- 27700

# Interactive plot of a few dates
flow_stars_JanFeb2015 <- flow_stars[,,,661:662]

library(tmap)
tmap_leaflet(
  tm_shape(flow_stars_JanFeb2015) + 
    tm_raster() + 
    tm_facets(as.layers = TRUE)
)


# MORECS soil 1960 to 2015 ####
# Units are mm water per metre soil
soil_cdf <- nc_open("morecs/G2G_MORECS_soil_1960_2015.nc")
soil_cdf
nc_close(soil_cdf)
soil_stars <- read_ncdf("morecs/G2G_MORECS_soil_1960_2015.nc", var = "soil")
st_crs(soil_stars) <- 27700
# Interactive plot of a few dates
soil_stars_JanFeb2015 <- soil_stars[,,,661:662]
plot(soil_stars_JanFeb2015)


tmap_leaflet(
  tm_shape(soil_stars_JanFeb2015) + 
    tm_raster() + 
    tm_facets(as.layers = TRUE)
)

