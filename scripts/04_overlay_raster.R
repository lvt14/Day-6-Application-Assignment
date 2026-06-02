# =============================================================================
# 04_overlay_raster.R
# OVERLAY 3: Raster -> Polygon
#
# Question: What is the mean PM2.5 in each Virginia county?
#
# We compare two approaches:
#   (a) terra::extract        -- centroid-based (legacy default)
#   (b) exactextractr::exact_extract -- area-weighted (correct default)
# =============================================================================

# Set your working directory in 01_setup.R, then run this script.
source("scripts/01_setup.R")

# ---- Chosen Approach: exact_extract (instead of terra::extract) --------------------------------
# Area-weights each cell by the share of its area inside the polygon.
# Works directly on sf objects.

counties_pm_exact <- counties |>
  mutate(
    mean_pm25_exact = exact_extract(pm25, geometry,
      fun = "mean",
      progress = FALSE
    )
  )

counties_pm_exact |>
  st_drop_geometry() |>
  select(NAME, mean_pm25_exact) |>
  arrange(desc(mean_pm25_exact)) |>
  write.csv("outputs/tables/mean_pm25_per_county.csv", row.names = FALSE)

p_exact <- ggplot(counties_pm_exact) +
  geom_sf(aes(fill = mean_pm25_exact), color = NA) +
  scale_fill_viridis_c(name = "PM2.5", option = "magma") +
  labs(title = "Mean PM2.5 per County (area-weighted)") +
  theme_void()

print(p_exact)
ggsave("outputs/figures/mean_pm25_per_county.png")

# ---- Mean PM2.5 in counties with powerplants versus in counties without powerplants ------------------------------------------------------

pm25_comparison <- counties_pm_exact |>
  st_drop_geometry() |>
  mutate(has_plant = GEOID %in% counties_pip$GEOID[counties_pip$n_facilities > 0]) |>
  group_by(has_plant) |>
  summarise(mean_pm25 = mean(mean_pm25_exact, na.rm = TRUE))

write.csv(pm25_comparison, "outputs/tables/mean_pm25_by_powerplant_presence.csv", row.names = FALSE)

pm25_within <- counties_pm_exact |>
  st_drop_geometry() |>
  mutate(has_plant = GEOID %in% counties_pip$GEOID[counties_pip$n_facilities > 0]) |>
  group_by(has_plant) |>
  summarise(mean_pm25 = mean(mean_pm25_exact, na.rm = TRUE))

ggplot(pm25_within, aes(x = has_plant, y = mean_pm25, fill = has_plant)) +
  geom_col() +
  labs(title = "Mean PM2.5: counties with vs without power plants (within-county)",
       x = "Has power plant?", y = "Mean PM2.5 (ug/m3)") +
  theme_minimal()
ggsave("outputs/figures/mean_pm25_by_powerplant_presence.png")

# ---- Mean PM2.5 in counties within 5km of a powerplant versus in counties not within 5km of a powerplant ------------------------------------------------------

pm25_nearby <- counties_pm_exact |>
  st_drop_geometry() |>
  mutate(near_plant = GEOID %in% counties_near$GEOID[counties_near$near_pps == TRUE]) |>
  group_by(near_plant) |>
  summarise(mean_pm25 = mean(mean_pm25_exact, na.rm = TRUE))

write.csv(pm25_nearby, "outputs/tables/mean_pm25_by_nearby_powerplant_5km.csv", row.names = FALSE)

ggplot(pm25_nearby, aes(x = near_plant, y = mean_pm25, fill = near_plant)) +
  geom_col() +
  labs(title = "Mean PM2.5: counties near vs far from power plants (5km buffer)",
       x = "Near power plant?", y = "Mean PM2.5 (ug/m3)") +
  theme_minimal()
ggsave("outputs/figures/mean_pm25_by_nearby_powerplant_5km.png")