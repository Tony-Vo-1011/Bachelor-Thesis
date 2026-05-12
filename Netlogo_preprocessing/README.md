This folder contains pre processing scripts in R and Python to import the roads infrastructure and third places point layer from 
GIS shapefiles into Netlogo. The files listed are in chronological order of processing. 

Road_network_contruction.md -> Explains the entire process of turning GIS road network shapefile into a node-edge graph structure in
NetLogo

extract.R -> template code to extract roads nodes, roads edges, and third places points from a given neighbourhood boudary

filter_edges.R -> filter and keep only unique edges.

clean_files.ipynb -> check and delete duplicate roads nodes, roads edges, and third places points. Strips the csvs down to 
main necessary columns to import into Netlogo

preprocessing.ipynb -> Remove edges with self loops, NA values, references to nodes that don't exist. Scale coordinates to NetLogo world.
Keeps only the largest connected component in the network, removing all unreachable destinations
