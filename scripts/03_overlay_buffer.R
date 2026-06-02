# =============================================================================
# 03_overlay_buffer.R
# OVERLAY 2: Buffer + Join
#
# Question: Which counties have at least one powerplant within 5 km?
# =============================================================================

# Set your working directory in 01_setup.R, then run this script.
source("scripts/01_setup.R")

# ---- Confirm we are in a projected CRS (units = meters) ---------------------
# This matters! In a geographic CRS (degrees), st_buffer(dist = 5000) would
# buffer by 5,000 degrees, which is meaningless.

stopifnot(sf::st_is_longlat(pps) == FALSE)

# ---- Buffer the points ------------------------------------------------------

buffer_dist_m <- 5000 # 5 km

pps_buf <- st_buffer(pps, dist = buffer_dist_m)

# ---- Find counties intersecting any buffer ---------------------------------
# st_intersects(A, B) returns, for each row of A, the indices of rows in B
# that touch it. lengths() gives the count; > 0 flips it to a logical.

counties_near <- counties |>
  mutate(
    n_facilities_within_5km = lengths(st_intersects(geometry, pps_buf)),
    near_pps = n_facilities_within_5km > 0
  )

counties_near |>
  st_drop_geometry() |>
  select(NAME, n_facilities_within_5km, near_pps) |>
  arrange(desc(n_facilities_within_5km)) |>
  write.csv("outputs/tables/facilities_within_5km_buffer.csv", row.names = FALSE)

# ---- Sanity check -----------------------------------------------------------

cat(
  "Counties with >=1 powerplant within 5 km: ",
  sum(counties_near$near_pps), " of ", nrow(counties_near), "\n"
)

# ---- Plot -------------------------------------------------------------------
# Wrapped in print() so the map appears whether you run the script line-by-line
# OR click "Source" (Source turns off auto-printing of the plot object).

print(
  ggplot(counties_near) +
    geom_sf(aes(fill = near_pps), color = "white", linewidth = 0.1) +
    geom_sf(data = pps, color = "black", size = 0.4) +
    scale_fill_manual(
      name   = "Near Powerplant?",
      values = c(`TRUE` = "#E57200", `FALSE` = "#E5E5E5")
    ) +
    labs(title = "Counties within 5 km of any Powerplant") +
    theme_void()
)
ggsave("outputs/figures/counties_within_5km_of_powerplant.png")

print(
  ggplot(counties_near) +
    geom_sf(aes(fill = near_pps), color = "white", linewidth = 0.1) +
    geom_sf(data = pps, color = "black", size = 0.4) +
    scale_fill_manual(
      name   = "Near Powerplant?",
      values = c(`TRUE` = "#E57200", `FALSE` = "#E5E5E5")
    ) +
    labs(title = "Counties within 5 km of any Powerplant") +
    theme_void()
)
ggsave("outputs/figures/counties_within_5km_of_powerplant.png")

# =============================================================================
# MODIFY 1:  Change the buffer distance from 5 km to 1 km.
#            Re-source the script. How does the map shift?
#
# MODIFY 2:  Map the *count* of facilities within 5 km (already computed above
#            as `n_facilities_within_5km`) instead of the boolean. Switch the
#            ggplot aes to `fill = n_facilities_within_5km` and use
#            scale_fill_viridis_c().
# =============================================================================

# 1

buffer_dist_m <- 1000 # 1 km

pps_buf <- st_buffer(pps, dist = buffer_dist_m)

# ---- Find counties intersecting any buffer ---------------------------------
# st_intersects(A, B) returns, for each row of A, the indices of rows in B
# that touch it. lengths() gives the count; > 0 flips it to a logical.

counties_near <- counties |>
  mutate(
    n_facilities_within_1km = lengths(st_intersects(geometry, pps_buf)),
    near_pps = n_facilities_within_1km > 0
  )
counties_near |>
  st_drop_geometry() |>
  select(NAME, n_facilities_within_1km, near_pps) |>
  arrange(desc(n_facilities_within_1km)) |>
  write.csv("outputs/tables/facilities_within_1km_buffer.csv", row.names = FALSE)

# ---- Sanity check -----------------------------------------------------------
cat(
  "Counties with >=1 Powerplant within 1 km: ",
  sum(counties_near$near_pps), " of ", nrow(counties_near), "\n"
)

# ---- Plot -------------------------------------------------------------------
print(
  ggplot(counties_near) +
    geom_sf(aes(fill = near_pps), color = "white", linewidth = 0.1) +
    geom_sf(data = pps, color = "black", size = 0.4) +
    scale_fill_manual(
      name   = "Near Powerplant?",
      values = c(`TRUE` = "#E57200", `FALSE` = "#E5E5E5")
    ) +
    labs(title = "Counties within 1 km of any Powerplant") +
    theme_void()
)
ggsave("outputs/figures/counties_within_1km_of_powerplant.png")

# 2

print(
  ggplot(counties_near) +
    geom_sf(aes(fill = n_facilities_within_5km), color = "white", linewidth = 0.1) +
    scale_fill_viridis_c(name = "Facilities within 5km", option = "magma", trans = "sqrt") +
    labs(title = "Counties within 5 km of any Powerplant") +
    theme_void()
)
ggsave("outputs/figures/counties_by_number_of_powerplants_within_5km.png")

# =============================================================================
# MODIFY 1:  Change the buffer distance from 5 km to 1 km.
#            Re-source the script. How does the map shift?
#
# MODIFY 2:  Map the *count* of facilities within 5 km (already computed above
#            as `n_facilities_within_5km`) instead of the boolean. Switch the
#            ggplot aes to `fill = n_facilities_within_5km` and use
#            scale_fill_viridis_c().
# =============================================================================

# 1

buffer_dist_m <- 1000 # 1 km

pps_buf <- st_buffer(pps, dist = buffer_dist_m)

# ---- Find counties intersecting any buffer ---------------------------------
# st_intersects(A, B) returns, for each row of A, the indices of rows in B
# that touch it. lengths() gives the count; > 0 flips it to a logical.

counties_near <- counties |>
  mutate(
    n_facilities_within_1km = lengths(st_intersects(geometry, pps_buf)),
    near_pps = n_facilities_within_1km > 0
  )
counties_near |>
  st_drop_geometry() |>
  select(NAME, n_facilities_within_1km, near_pps) |>
  arrange(desc(n_facilities_within_1km)) |>
  write.csv("outputs/tables/facilities_within_1km_buffer.csv", row.names = FALSE)

# ---- Sanity check -----------------------------------------------------------
cat(
  "Counties with >=1 Powerplant within 1 km: ",
  sum(counties_near$near_pps), " of ", nrow(counties_near), "\n"
)

# ---- Plot -------------------------------------------------------------------
print(
  ggplot(counties_near) +
    geom_sf(aes(fill = near_pps), color = "white", linewidth = 0.1) +
    geom_sf(data = pps, color = "black", size = 0.4) +
    scale_fill_manual(
      name   = "Near Powerplant?",
      values = c(`TRUE` = "#E57200", `FALSE` = "#E5E5E5")
    ) +
    labs(title = "Counties within 1 km of any Powerplant") +
    theme_void()
)
ggsave("outputs/figures/counties_within_1km_of_powerplant.png")

# 2

print(
  ggplot(counties_near) +
    geom_sf(aes(fill = n_facilities_within_1km), color = "white", linewidth = 0.1) +
    scale_fill_viridis_c(name = "Facilities within 1km", option = "magma", trans = "sqrt") +
    labs(title = "Counties within 1 km of any Powerplant") +
    theme_void()
)
ggsave("outputs/figures/counties_by_number_of_powerplants_within_1km.png")