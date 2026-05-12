library(sf)
library(readr)

nodes_csv <- read_csv("/Users/tonyvo/Desktop/Thesis/netlogo/data/roads/nodes_main_component.csv")
buurt <- st_read("/Users/tonyvo/Desktop/Thesis/netlogo/data/buurt/ams_buurt_wgs84.geojson")
places_csv <- read_csv("/Users/tonyvo/Desktop/Thesis/netlogo/data/places/places.csv")

nodes <- st_as_sf(nodes_csv, coords = c("x", "y"), crs = 28992)
nodes <- st_transform(nodes, 4326)

places <- st_as_sf(places_csv, coords = c("x", "y"), crs = 28992)
places <- st_transform(places, 4326)

sample <- buurt[buurt$wijkcode == "WK0363AJ", ]

nodes_inside <- st_within(nodes, sample, sparse = FALSE)
nodes_within <- nodes[apply(nodes_inside, 1, any), ]

places_inside <- st_within(places, sample, sparse = FALSE)
places_within <- places[apply(places_inside, 1, any), ]

# 6. Plot to check
plot(st_geometry(sample), col = NA, border = "red")
plot(st_geometry(places_within), add = TRUE, pch = 16, cex = 0.5)
plot(st_geometry(nodes_within), add = TRUE, pch = 16, cex = 0.5, col = "blue")

