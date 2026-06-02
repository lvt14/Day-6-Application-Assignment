# Day 6 Application Assignment — Spatial Overlays

**EIL Summer Bootcamp 2026 | Lucie Talikoff**

This project applies three spatial overlay techniques to US county boundaries, power plant locations (EIA-860), and a PM2.5 raster surface to examine the relationship between electricity-generating facilities and local air quality.

## Questions Answered

1. How many power plants are in each county? *(point-in-polygon)*
2. How many plants are within 5 km of each county? *(buffer join)*
3. What is each county's mean PM2.5? *(raster extraction)*

And: does mean PM2.5 differ between counties with vs. without power plants — and does the picture change when using the "nearby" measure instead?

## Project Structure

```
Day-6-Application-Assignment/
├── data/
│   ├── raw/          ← us_counties.shp, us_powerplants.shp, us_pm25.tif
│   └── processed/
├── scripts/
│   ├── 01_setup.R        ← loads and reprojects all three layers
│   ├── 01b_explore.R     ← data quality checks and exploration
│   ├── 02_overlay_points.R   ← point-in-polygon join
│   ├── 03_overlay_buffer.R   ← buffer + intersection
│   └── 04_overlay_raster.R   ← raster extraction + PM2.5 comparison
├── outputs/
│   ├── figures/      ← maps and charts
│   └── tables/       ← CSV summaries
└── brief.pdf         ← write-up and comparison
```

## How to Run

1. Place data files in `data/raw/`
2. Edit the `setwd()` line in `scripts/01_setup.R` to point to this folder
3. Run scripts in order: `01_setup.R` → `01b_explore.R` → `02` → `03` → `04`

## Key Outputs

- [Brief (PDF)](brief.pdf)
- [Mean PM2.5 by county](outputs/tables/mean_pm25_per_county.csv)
- [PM2.5 by power plant presence](outputs/tables/mean_pm25_by_powerplant_presence.csv)
- [PM2.5 by nearby power plant (5km)](outputs/tables/mean_pm25_by_nearby_powerplant_5km.csv)
- [Facilities within 5km buffer](outputs/tables/facilities_within_5km_buffer.csv)
