This file explains the full ArcGIS Pro procedure of turning a road network dataset into a node-edges graph in NetLogo.

**Step 1: Create Unique Edges**
Use the Split Line tool to split line segment at every intersection. This creates a new layer which we will call 'roads_clean'. 
In this new table, every line segment, whcih we call edge, has its own row. By editing the attribute table, we assign each edge a unique ID under the column 'edge_id'.

**Step 2: Create Start Points for Every Edge**
Using Feature Vertices to Points tool:
- Input features -> roads_clean
- Point type: Start
- Output features: 'edge_start_point'

The ArcGIS Feature Vertices To Points tool creates point features from vertices of input line or polygon features; using START gives  the first vertex of each line.
The output should contain 'edge_id' column. Make sure there is a column marking that these are 'start' nodes.

**Step 3: Create End Points for Every Edge**
Using Feature Vertices to Points tool:
- Input features -> roads_clean
- Point type: End
- Output features: 'edge_end_point'

Now we have one end point per edge.
The output should also contain 'edge_id' column. Also make sure there is a column marking that these are 'end' nodes.

**Step 4: Merge start and end points**
Use the Merge tool:
- Input features -> 'edge_start_point', 'edge_end_point'
- Output features -> 'all_edge_nodes_id'

**Step 5: Create unique network nodes from duplicate endpoint points**
Add a column in 'all_edge_nodes_id' for X/Y coordinate fields for the nodes using Calculate X/Y Fields tool. Then use the Dissolve tool to delete duplicate nodes:

- Input Features: 'all_edge_nodes_id'
- Dissolve by -> x-coord, y-coord
- Output features -> 'unique_road_nodes'

This creates one point per unique endpoint location.

**Step 6: Add unique node IDs**
In 'unique_road_nodes', add a field called 'node_id'. Caculate the 'node_id' field with a unique ID. Now each unique road junction / endpoint has a node ID.

**Step 7: Join node IDs to the start points**
Now that we have the 'unique_road_nodes' layer, we will use this layer to assign an ID to our original start points, using the Spatial Join tool:
- Target Features -> 'edge_start_points'
- Join Features -> 'unique_road_nodes'
- Match option -> Intersect
- Output features -> 'edge_start_points_with_node_id'

Rename the joined node_id field to -> 'from_node_id'. 

**Step 8: Join node IDs to the end points**
We do the same thing again for the end points.

- Target Features -> 'edge_end_points'
- Join Features -> 'unique_road_nodes'
- Match option -> Intersect
- Output features -> 'edge_end_points_with_node_id'

Rename the joined node_id field to -> 'to_node_id'. 

**Step 9: Join 'from_node_id' back to the road edges**
Now we open the original edges layer 'roads_clean' and join the nodes, using Join Field tool:
- Input table: 'roads_clean'
- Input Join Field: 'edge_id'
- Join Table: 'edge_start_points_with_node_id'
- Join Table Field: 'edge_id'
- Fields to Join: 'from_node_id'

**Step 10: Join 'to_node_id' back to the road edges**
Again:
- Input table: 'roads_clean'
- Input Join Field: 'edge_id'
- Join Table: 'edge_end_points_with_node_id'
- Join Table Field: 'edge_id'
- Fields to Join: 'to_node_id'

**Step 11: Final Exports**
From 'unique_road_nodes', export 'road_nodes.csv'. 
From 'roads_clean', export 'road_edges.csv'.



