# Requirements

This project is designed for R 4.0 or newer.

Install the runtime packages before sourcing `scripts/webscrape_demo.R`:

```r
install.packages(c("rvest", "tidyverse", "plotly", "viridis"))
```

## Package Roles

| Package | Purpose |
| --- | --- |
| `rvest` | Scrapes book titles, prices, and ratings from Books to Scrape. |
| `tidyverse` | Cleans, transforms, groups, and summarizes scraped data. |
| `plotly` | Renders the interactive 3D terrain surface. |
| `viridis` | Provides accessible color palettes for the terrain plot. |

The script also uses `readr` and `stringr` through `tidyverse`.
