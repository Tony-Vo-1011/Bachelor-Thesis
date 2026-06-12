# Extract sample neighbourhood data for NetLogo preprocessing
# This script selects road nodes and third-place points located within one Amsterdam wijk.
# The selected neighbourhood sample is used to create a smaller spatial subset for testing
# and visualising the NetLogo road network before running the full simulation.

library(sf)
library(readr)

# Load spatial and tabular datasets: road nodes, Amsterdam neighbourhood boundaries, and third places
nodes_csv <- read_csv("/Users/tonyvo/Desktop/Thesis/netlogo/data/roads/nodes_main_component.csv")
buurt <- st_read("/Users/tonyvo/Desktop/Thesis/netlogo/data/buurt/ams_buurt_wgs84.geojson")
places_csv <- read_csv("/Users/tonyvo/Desktop/Thesis/netlogo/data/places/places.csv")

# Convert node and third-place coordinates into spatial point layers.
# They are transformed to WGS84 so they match the neighbourhood boundary layer.
nodes <- st_as_sf(nodes_csv, coords = c("x", "y"), crs = 28992)
nodes <- st_transform(nodes, 4326)

places <- st_as_sf(places_csv, coords = c("x", "y"), crs = 28992)
places <- st_transform(places, 4326)

# Select the sample wijk used for the NetLogo test environment
sample <- buurt[buurt$wijkcode == "WK0363AJ", ]

# Keep only the road nodes and third places located inside the selected wijk
nodes_inside <- st_within(nodes, sample, sparse = FALSE)
nodes_within <- nodes[apply(nodes_inside, 1, any), ]

places_inside <- st_within(places, sample, sparse = FALSE)
places_within <- places[apply(places_inside, 1, any), ]

# Plot the sample area as a visual check before exporting or filtering further
plot(st_geometry(sample), col = NA, border = "red")
plot(st_geometry(places_within), add = TRUE, pch = 16, cex = 0.5)
plot(st_geometry(nodes_within), add = TRUE, pch = 16, cex = 0.5, col = "blue")

