# =============================================================================
# 01_setup.R
# Day 6 Application Assignment -- UVA 2026 Bootcamp
#
# Loads the three input layers, reprojects them to a common projected CRS,
# and exposes them as `counties`, `pps`, `pm25` for the overlay scripts.
# Source this once at the start of the session.
# =============================================================================

# ---- Set your working directory ---------------------------------------------
# >>> EDIT THIS LINE <<<  Point it at the folder that contains the `data/` and `scripts/` subfolders. Then source this script.
setwd("/Users/lucietalikoff/Documents/UVA 2026 Bootcamp/Day-6-Application-Assignment")

# ---- Packages ---------------------------------------------------------------

if (!requireNamespace("pacman", quietly = TRUE)) {
  install.packages("pacman")
}

pacman::p_load(
  sf, # vector data
  terra, # raster data
  exactextractr, # area-weighted raster->polygon
  dplyr, # data manipulation
  tidyr, # replace_na
  ggplot2, # plotting
  units # working with km^2 etc.
)
# ---- File paths -------------------------------------------------------------

raw_path <- "data/raw/"
processed_path <- "data/processed/"

counties_file <- paste0(raw_path, "us_counties.shp")
pps_file <- paste0(raw_path, "us_powerplants.shp") 
pm25_file <- paste0(raw_path, "us_pm25.tif")

# ---- Common CRS -------------------------------------------------------------
# EPSG:5070 = NAD83 / Conus Albers. Equal-area, units = meters.
# Sensible default for any analysis covering the continental US.

target_crs <- 5070

# ---- Load and reproject -----------------------------------------------------

counties <- st_read(counties_file, quiet = TRUE) |>
    st_transform(target_crs) |> 
    st_make_valid()
# first line opens the shapefile and stores it in a variable called counties. 
# second line makes it use the 5070 crs (a meters one)
# third line fixes any small county border errors 
pps <- st_read(pps_file, quiet = TRUE) |>
    st_transform(target_crs)
# same first and second line interpretations as for counties above
pm25 <- rast(pm25_file)
if (is.na(crs(pm25)) || crs(pm25) == "") {
    crs(pm25) <- "EPSG:4326" # PM2.5 surfaces are typically distributed in WGS84
}
pm25 <- terra::project(pm25, paste0("EPSG:", target_crs))
# first line opens the raster file and stores it in a variable called pm25
# second step (next 3 lines) checks if raster knows what coordinate system it's in, and assumes it's in WGS84 if it doesn't know
# third step (last line) makes it use the 5070 crs (a meters one) 

# ---- Sanity checks ----------------------------------------------------------

stopifnot(st_crs(counties) == st_crs(pps))
# throws an error if layers aren't in the same coordinate system 
stopifnot(st_crs(counties)$epsg == target_crs)
# makes sure the specific crs is 5070

cat("Setup complete.\n")
# prints "setup complete" 
cat(" counties: ", nrow(counties), "polygons,  CRS =", st_crs(counties)$epsg, "\n")
# prints how many county polygons there are and what CRS they're in
cat(" pps:      ", nrow(pps), "points,    CRS =", st_crs(pps)$epsg, "\n")
# prings how many power plant points there are and what CRS they're in
cat(
  " pm25:     ", ncol(pm25), "x", nrow(pm25), "raster, CRS =",
  crs(pm25, describe = TRUE)$code, "\n"
)
# prints the dimensions (number of rows and columns) of the raster
