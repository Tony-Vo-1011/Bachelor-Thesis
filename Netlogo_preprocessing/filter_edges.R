# Filter road network edges for the selected NetLogo sample area
# This script uses the neighbourhood nodes extracted in the previous step and keeps only
# the road edges whose start and end points are both located inside the sample area.
# The result is a smaller node-edge road network that can be imported into NetLogo.

# Get the node IDs from the selected neighbourhood sample
wanted_ids <- unique(nodes_within$node_id)

# Load the full scaled node layer and the cleaned main road-network edge layer
full_nodes <- read_csv("/Users/tonyvo/Desktop/Thesis/netlogo/data/roads/nodes_scaled_for_netlogo.csv")
edges <- read_csv("/Users/tonyvo/Desktop/Thesis/netlogo/data/roads/edges_main_component.csv")

# Keep only nodes that fall inside the selected sample area
filtered_nodes <- full_nodes %>%
  filter(node_id %in% wanted_ids)


# Keep only edges where both connected nodes are inside the selected sample area.
# This prevents roads from extending outside the NetLogo sample world.
filtered_edges <- edges %>%
  filter(from_id %in% wanted_ids & to_id %in% wanted_ids)

# save
write_csv(filtered_nodes, "sample_nodes.csv")
write_csv(filtered_edges, "sample_edges.csv")