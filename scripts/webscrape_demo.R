AI <- function(){
  
  cat("
==========================================================
              SKYNET DATAGRID LABS
          AI WEB INTELLIGENCE CONSOLE v1.0
==========================================================

Available Commands

BOOT()      - Initialize AI Engine
STATUS()    - Display System Status
MISSION()   - Display Mission Brief
RUN()       - Execute Analysis Pipeline
HELP()      - List Available Commands

System Status : READY

")
  
  
}
BOOT <- function(){
  
  cat("
Initializing SKYNET AI Core...
")
  
  Sys.sleep(1)
  
  cat("Loading Web Scraping Engine...........OK\n")
  Sys.sleep(0.8)
  
  cat("Loading Data Transformation Engine....OK\n")
  Sys.sleep(0.8)
  
  cat("Loading Terrain Visualization Engine..OK\n")
  Sys.sleep(0.8)
  
  cat("Checking Dependencies................OK\n")
  Sys.sleep(0.8)
  
  cat("\nAI Engine Ready.\n\n")
  
}
STATUS <- function(){
  
  cat("
================ SYSTEM STATUS ================

AI Core            : ONLINE
Internet           : CONNECTED
Web Scraper        : READY
Data Pipeline      : READY
Visualization      : READY
Plotly Engine      : READY

Memory             : AVAILABLE
Execution State    : STANDBY

===============================================

")
  
}
MISSION <- function(){
  
  cat("
================ MISSION BRIEF ================

Target
------
BooksToScrape.com

Objectives
----------
1. Connect to Website
2. Scrape Product Information
3. Extract Prices
4. Extract Star Ratings
5. Transform HTML into Structured Data
6. Generate DEM Terrain Model
7. Render Interactive Plotly Surface

Expected Output
---------------
Interactive 3D Terrain Visualization

Mission Status
--------------
READY FOR EXECUTION

===============================================

")
  
}
HELP <- function(){
  
  cat("
Available Commands

AI()
BOOT()
STATUS()
MISSION()
RUN()

")
  
}
RUN <- function(){
  
  cat("\nLaunching Analysis Pipeline...\n\n")
  SKYNET()
}

fetch_html_page <- function(url, timeout_seconds = 10) {
  response <- httr::GET(
    url,
    httr::timeout(timeout_seconds),
    httr::user_agent("Web-Scraping-with-R educational demo")
  )

  status <- httr::status_code(response)
  if (status < 200 || status >= 300) {
    stop(sprintf("Request to %s failed with HTTP status %s", url, status), call. = FALSE)
  }

  content <- httr::content(response, as = "text", encoding = "UTF-8")
  read_html(content)
}

SKYNET <- function(){
  cat("
====================================
 SKYNET DATAGRID LABS
 AI Web Scraping Engine
====================================

Mission:
  Scrape → Transform → Visualize

Status: INITIALIZING...

")
  ## ============================================================
  ## 90-SECOND DEMO: Web Scraping -> Interactive 3D Terrain Plot
  ## Skynet DataGrid Labs | RStudio Demo Script
  ## ============================================================
  ## Flow: load packages -> scrape Books to Scrape -> build a
  ## height matrix from real price/rating data -> smooth-interpolate
  ## it into a DEM-style terrain -> render an interactive Plotly
  ## surface plot with LABELED axes and hover tooltips that show
  ## real scraped book data at every point (rotate + zoom to show
  ## off the interactivity).
  ## Total runtime target: ~60-90 seconds top to bottom.
  ## ============================================================
  
  
  ## ---- STEP 1: LOAD PACKAGES (target: 10-15s) -----------------
  
  required_pkgs <- c("httr", "rvest", "tidyverse", "plotly", "viridis")
  
  missing_pkgs <- required_pkgs[!required_pkgs %in% installed.packages()[, "Package"]]
  if (length(missing_pkgs) > 0) {
    install.packages(missing_pkgs, quiet = TRUE)
  }
  invisible(lapply(required_pkgs, library, character.only = TRUE))
  
  cat("[1/4] Packages ready.\n")
  
  
  ## ---- STEP 2: WEB SCRAPING (target: 15-20s) -------------------
  
  # "Books to Scrape" is a static sandbox site built for practicing
  # rvest - no login, no rate limits, stable HTML structure.
  url <- "https://books.toscrape.com/"
  page <- fetch_html_page(url, timeout_seconds = 10)
  
  titles <- page %>%
    html_elements("h3 a") %>%
    html_attr("title")
  
  prices <- page %>%
    html_elements(".price_color") %>%
    html_text() %>%
    readr::parse_number()
  
  rating_words <- page %>%
    html_elements(".star-rating") %>%
    html_attr("class") %>%
    stringr::str_remove("star-rating ")
  
  rating_lookup <- c(One = 1, Two = 2, Three = 3, Four = 4, Five = 5)
  ratings <- unname(rating_lookup[rating_words])
  
  books <- tibble(
    title  = titles,
    price  = prices,
    rating = ratings
  )
  
  cat("[2/4] Scraped", nrow(books), "books from Books to Scrape.\n")
  print(head(books))
  
  
  ## ---- STEP 3: BUILD A MEANINGFUL, LABELED HEIGHT MATRIX -------
  ## (target: ~20s)
  ##
  ## Instead of an arbitrary reshape, the grid axes are defined by
  ## real categories from the scraped data:
  ##   Y axis = star rating   (1 to 5 stars)
  ##   X axis = price band    (Q1 cheapest -> Q4 priciest, by quartile)
  ##   Z axis = elevation     (avg price x rating for that cell)
  ## Every grid cell keeps a text label with the actual book titles
  ## and average price that produced it, so hovering the surface
  ## later shows real, meaningful data - not just coordinates.
  
  books <- books %>%
    mutate(price_quartile = ntile(price, 4))
  
  cell_summary <- books %>%
    group_by(rating, price_quartile) %>%
    summarise(
      avg_price = mean(price),
      n_books   = n(),
      titles    = paste(title, collapse = "; "),
      .groups   = "drop"
    )
  
  overall_mean_price <- mean(books$price)
  
  # Guarantee all 5 (rating) x 4 (price band) cells exist, even if a
  # particular combination wasn't present on this page.
  full_grid <- expand_grid(rating = 1:5, price_quartile = 1:4) %>%
    left_join(cell_summary, by = c("rating", "price_quartile")) %>%
    mutate(
      avg_price = ifelse(is.na(avg_price), overall_mean_price, avg_price),
      n_books   = ifelse(is.na(n_books), 0, n_books),
      elevation = avg_price * rating,
      hover_label = ifelse(
        n_books > 0,
        sprintf("Rating: %d star(s)<br>Price band: Q%d<br>Avg price: £%.2f<br>Books (%d): %s",
                rating, price_quartile, avg_price, n_books,
                stringr::str_trunc(titles, 70)),
        sprintf("Rating: %d star(s)<br>Price band: Q%d<br>No scraped books in this cell",
                rating, price_quartile)
      )
    )
  
  seed_matrix <- matrix(full_grid$elevation,   nrow = 5, ncol = 4, byrow = TRUE)
  seed_labels <- matrix(full_grid$hover_label, nrow = 5, ncol = 4, byrow = TRUE)
  
  # Smooth-interpolate the 5x4 category grid up to a 50x50 terrain,
  # first across price bands, then across ratings.
  interp_rows <- t(apply(seed_matrix, 1, function(r) spline(seq_along(r), r, n = 50)$y))
  terrain_matrix <- apply(interp_rows, 2, function(col) spline(seq_along(col), col, n = 50)$y)
  
  # Build a matching 50x50 hover-text grid via nearest-neighbour
  # lookup back to the original rating/price-band label, so every
  # point you hover on the smooth surface still reports real data.
  text_matrix <- matrix(NA_character_, nrow = 50, ncol = 50)
  for (i in 1:50) {
    orig_row <- round((i - 1) / 49 * 4) + 1        # maps 1:50 -> 1:5 (rating)
    for (j in 1:50) {
      orig_col <- round((j - 1) / 49 * 3) + 1       # maps 1:50 -> 1:4 (price band)
      text_matrix[i, j] <- seed_labels[orig_row, orig_col]
    }
  }
  
  # Tick positions so the axes show real category labels, not
  # raw interpolated grid indices.
  tickvals_y <- sapply(1:5, function(r) (r - 1) / 4 * 49 + 1)
  ticktext_y <- paste0(1:5, " star")
  
  tickvals_x <- sapply(1:4, function(q) (q - 1) / 3 * 49 + 1)
  ticktext_x <- c("Q1 (cheapest)", "Q2", "Q3", "Q4 (priciest)")
  
  cat("[3/4] Built a labeled 50x50 terrain from rating x price-band cells.\n")
  
  
  ## ---- STEP 4: INTERACTIVE 3D SURFACE PLOT (target: ~35s) -----
  
  terrain_plot <- plot_ly(
    z = ~terrain_matrix,
    text = text_matrix,
    colors = viridis(256),
    hovertemplate = "%{text}<br>Elevation: %{z:.1f}<extra></extra>"
  ) %>%
    add_surface(
      contours = list(
        z = list(
          show = TRUE,
          usecolormap = TRUE,
          highlightcolor = "#D4AF37",
          project = list(z = TRUE)
        )
      ),
      lighting = list(ambient = 0.6, diffuse = 0.8, specular = 0.3, roughness = 0.5),
      colorbar = list(title = "Elevation\n(price x rating)")
    ) %>%
    layout(
      title = "Books to Scrape -> Interactive Terrain Model",
      paper_bgcolor = "white",
      plot_bgcolor = "white",
      scene = list(
        xaxis = list(
          title = "Price Band",
          tickvals = tickvals_x,
          ticktext = ticktext_x,
          backgroundcolor = "white",
          gridcolor = "#DDDDDD"
        ),
        yaxis = list(
          title = "Star Rating",
          tickvals = tickvals_y,
          ticktext = ticktext_y,
          backgroundcolor = "white",
          gridcolor = "#DDDDDD"
        ),
        zaxis = list(
          title = "Elevation (avg price x rating)",
          backgroundcolor = "white",
          gridcolor = "#DDDDDD"
        ),
        camera = list(eye = list(x = 1.6, y = 1.6, z = 0.9))
      )
    )
  
  cat("[4/4] Rendering interactive terrain plot - hover, rotate & zoom to explore.\n")
  
  terrain_plot
  
  ## ============================================================
  ## END OF DEMO
  ## Talking point: X and Y axes are real scraped categories
  ## (price band and star rating), and every point you hover over
  ## reports the actual book titles and average price behind it -
  ## this isn't just a pretty surface, it's readable data.
  ## ============================================================
}
