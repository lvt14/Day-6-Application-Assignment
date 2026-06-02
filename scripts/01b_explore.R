# =============================================================================
# 01b_explore.R
# Spatial Overlays Workshop -- EIL Summer Internship 2026
#
# Before joining anything, LOOK at the three layers. Half of all spatial bugs
# are caught here -- wrong CRS, missing column, points in the ocean, a raster
# of all-NA. Run 01_setup.R first (this script sources it for you), then step
# through the blocks below and actually read the output.
# =============================================================================

# Set your working directory in 01_setup.R, then run this script.
source("scripts/01_setup.R")

# ---- counties: a polygon layer ----------------------------------------------
# Each row is one county; the geometry column holds the polygon.

print(counties) 
# prints the class, CRS, bbox, first rows
cat("\nColumns:\n")
print(names(counties))
cat("\nNumber of counties:", nrow(counties), "\n")
cat("CRS (EPSG):", st_crs(counties)$epsg, "\n")

# A quick look at the attribute table without the geometry getting in the way:
counties |>
    st_drop_geometry() |>
    head()

# ---- pps: a point layer ------------------------------------------------------
# Each row is one facility.

print(pps)
cat("\nNumber of power plants:", nrow(pps), "\n")

# ---- pm25: a raster ----------------------------------------------------------
# A gridded surface; every cell carries a PM2.5 value (ug/m^3).

print(pm25) # dimensions, resolution, CRS, value range
cat("\nSummary of PM2.5 cell values:\n")
print(summary(values(pm25))) # watch for all-NA, or an implausible range

# ---- Data-quality checks -----------------------------------------------------
# "Looking" is not just plotting. Before you trust a join, check the things that
# silently corrupt it: duplicate keys, duplicate rows, missing values, dead
# columns, and broken geometries. Run these and read each number.

# 1. Is your join key unique? A non-unique key turns a left_join into a
#    many-to-many blow-up -- the classic way a merge silently inflates rows.
cat(
    "counties: GEOID unique?     ", !any(duplicated(counties$GEOID)),
    " (", length(unique(counties$GEOID)), "distinct of", nrow(counties), ")\n"
)
cat(
    "pps:      pps_id unique?     ", !any(duplicated(pps$pps_id)),
    " (", length(unique(pps$pps_id)), "distinct of", nrow(pps), ")\n"
)

# 2. Duplicate records vs. duplicate geometries. Two different facilities can
#    sit at the same coordinates (same address, shared site) -- that is NOT a
#    duplicate record. Check both, and don't confuse them.
cat("\npps: fully duplicated rows: ", sum(duplicated(st_drop_geometry(pps))), "\n")
cat(
    "pps: duplicated coordinates: ", sum(duplicated(st_coordinates(pps))),
    " (co-located facilities -- expected, not necessarily a problem)\n"
)

# 3. Missing values, by column. NAs in a key or a join variable propagate.
cat("\nNAs per column (pps):\n")
print(colSums(is.na(st_drop_geometry(pps))))

# 4. Dead columns. A column with one unique value carries no information --
#    know it's there before you try to condition or filter on it.
cat("\nDistinct values per pps column:\n")
print(sapply(st_drop_geometry(pps), function(x) length(unique(x))))

# 5. Geometry health. Empty or invalid geometries break spatial predicates.
#    (01_setup.R already ran st_make_valid() on counties -- confirm it took.)
cat(
    "\nempty geometries -- counties:", sum(st_is_empty(counties)),
    " pps:", sum(st_is_empty(pps)), "\n"
)
cat(
    "invalid geometries -- counties:", sum(!st_is_valid(counties)),
    " pps:", sum(!st_is_valid(pps)), "\n"
)

# 6. Attributes vs. geometry. pps carries a `fips` field claiming each
#    facility's county. Does it match the actual county codes? Mismatches here
#    foreshadow the points that won't land in a county during the spatial join.
n_match <- sum(as.character(pps$fips) %in% as.character(counties$GEOID))
cat(
    "\npps$fips that match a county GEOID:", n_match, "of", nrow(pps),
    "(", nrow(pps) - n_match, "do not -- worth a look)\n"
)
# NO matching, but turns out that's just because there's no fips code column for pps

# ---- See them together -------------------------------------------------------
# plot the layers on the same axes. If the points
# don't land on the counties, or the raster sits somewhere else entirely, your
# CRSs are out of sync -- fix that BEFORE any join.

plot(st_geometry(counties),
    border = "grey40",
    main = "Counties + PPS (do the points land on the map?)"
)
plot(st_geometry(pps), add = TRUE, pch = 20, cex = 0.5, col = "#E57200")
# all land in the US, so all good
ggsave("outputs/figures/powerplants_on_map.png")


# The PM2.5 surface on its own:
plot(pm25, main = "PM2.5 surface (ug/m^3)")
ggsave("outputs/figures/pm25_surface.png")

# Distribution of PM2.5 values -- is the range physically plausible?
hist(values(pm25),
    breaks = 40, col = "#00B3BE", border = "white",
    main = "Distribution of PM2.5 cell values", xlab = "PM2.5 (ug/m^3)"
)
ggsave("outputs/figures/pm25_distribution_histogram.png")

# =============================================================================
# ASK YOURSELF, before moving on to the overlays:
#   - Do all three layers report the SAME CRS (EPSG:5070)?
#   - Is your join key (GEOID, pps_id) actually unique?
#   - Any duplicate rows, missing values, or dead (single-value) columns?
#   - Do the geometries pass the empty/valid checks?
#   - Do the PPS points fall inside Virginia, on top of the counties?
#   - Is the PM2.5 range physically sensible (single digits to low tens)?
#   - Does pps$fips agree with the county codes? Where it doesn't, why?
# If anything looks off here, stop and sort it out -- it will not fix itself
# downstream.
# =============================================================================
