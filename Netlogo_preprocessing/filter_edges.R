wanted_ids <- unique(nodes_within$node_id)

full_nodes <- read_csv("/Users/tonyvo/Desktop/Thesis/netlogo/data/roads/nodes_scaled_for_netlogo.csv")
edges <- read_csv("/Users/tonyvo/Desktop/Thesis/netlogo/data/roads/edges_main_component.csv")

filtered_nodes <- full_nodes %>%
  filter(node_id %in% wanted_ids)

# 3. filter edges where BOTH endpoints are in the selected node set
filtered_edges <- edges %>%
  filter(from_id %in% wanted_ids & to_id %in% wanted_ids)

# save
write_csv(filtered_nodes, "sample_nodes.csv")
write_csv(filtered_edges, "sample_edges.csv")