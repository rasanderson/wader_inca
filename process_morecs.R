# Initial pre-processing

# Check the MORECS data downloaded from
# https://doi.org/10.5285/e911196a-b371-47b1-968c-661eb600d83b
library(ncdf4)
library(raster)

# Check the files
# Catchment area Area draining each G2G grid box ####
catchment_cdf <- nc_open("morecs/MaRIUS_G2G_CatchmentAreaGrid.nc")

lon <- ncvar_get(catchment_cdf, "lon")
lat <- ncvar_get(catchment_cdf, "lat")
area <- ncvar_get(catchment_cdf, "area")
crs <- ncvar_get(catchment_cdf, "crs")

area_sp <- raster(t(area), crs=crs("+init=epsg:27700"),
                  xmn = 0,
                  xmx = 700000,
                  ymn = 0,
                  ymx = 100000,
                  resolution = 10000)

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
stations_sp <- raster("morecs/MaRIUS_G2G_NRFAStationIDGrid.nc", ncdf=TRUE,
                      varname = "ID")
crs(stations_sp) <-crs("+init=epsg:27700")
# Convert to vector
library(sf)
stations_df <- cbind(coordinates(stations_sp), as.vector(stations_sp))
colnames(stations_df)[3] <- "ID"
stations_df <- data.frame(stations_df)
stations_sf <- st_as_sf(stations_df, coords=c("x","y"), crs = crs("+init=epsg:27700"))
crs(stations_sf) <- crs("+init=epsg:27700")

# MORECS flow 1960 to 2015 ####
flow_cdf <- nc_open("morecs/G2G_MORECS_flow_1960_2015.nc")
library(stars)
library(tidyverse)
flow_stars <- read_ncdf("morecs/G2G_MORECS_flow_1960_2015.nc", var = "flow")
st_crs(flow_stars) <- 27700
# Interactive plot of a few dates
tmp <- flow_stars[,,101:103]
flow_stars %>% slice(time, 250:253) -> tmp
library(tmap)
tmap_leaflet(
  tm_shape(tmp) + 
    tm_raster() + 
    tm_facets(as.layers = TRUE)
)


# MORECS soil 1960 to 2015 ####
# Units are mm water per metre soil
soil_cdf <- nc_open("morecs/G2G_MORECS_soil_1960_2015.nc")
soil_stars <- read_ncdf("morecs/G2G_MORECS_soil_1960_2015.nc", var = "soil")
st_crs(soil_stars) <- 27700
# Interactive plot of a few dates
tmp <- soil_stars[,,101:103]
soil_stars %>% slice(time, 250:253) -> tmp
tmap_leaflet(
  tm_shape(tmp) + 
    tm_raster() + 
    tm_facets(as.layers = TRUE)
)


