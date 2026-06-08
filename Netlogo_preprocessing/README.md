# NetLogo Preprocessing

This folder contains the preprocessing steps used to convert GIS-derived spatial data into NetLogo-compatible input files for the agent-based simulation.

The thesis uses NetLogo to simulate third-place visits, stopping, lingering, and co-presence along simplified neighbourhood road networks. This folder documents the intermediate step between the GIS accessibility analysis and the NetLogo model environment.

## Purpose

The purpose of this folder is to prepare spatial inputs for the NetLogo simulation, including:

- road network nodes;
- road network links;
- third-place locations;
- coordinate transformations;
- model-ready spatial files.

These files allow the NetLogo model to represent agents moving through a simplified but geographically informed neighbourhood environment.

## Input Data

The preprocessing workflow uses spatial outputs from the GIS analysis, including:

- Amsterdam road network data derived from OpenStreetMap/Geofabrik;
- third-place point locations derived from OpenStreetMap/Overpass Turbo;
- selected neighbourhood or district boundaries used as model environments.

## Main Processing Steps

The preprocessing workflow generally involves:

1. selecting the neighbourhood or district environment to be modelled;
2. extracting road segments within the selected area;
3. converting road intersections or route points into nodes;
4. converting road segments into links between nodes;
5. transforming third-place locations into the same coordinate space as the road network;
6. exporting cleaned node, link, and third-place files for use in NetLogo.

## Outputs

The main outputs from this folder are NetLogo-compatible spatial files, such as:

- road node files;
- road edge/link files;
- third-place location files;
- cleaned coordinate files for selected model environments.

These outputs are imported into the NetLogo model to create the simulated neighbourhood environment.

## Methodological Notes

The NetLogo environment is a simplified representation of the real spatial environment. Road nodes and links represent the structure of the street network, but the model does not reproduce full real-world mobility patterns.

Agents are constrained to move along the imported road network. This allows the simulation to test whether third-place use emerges from routine movement through neighbourhood space, rather than from random movement across an abstract grid.

Third places are represented as fixed points within the same networked environment. These locations are derived from the same third-place dataset used in the GIS analysis.

## Relation to Thesis

This folder provides the technical bridge between the GIS analysis and the NetLogo simulation. The GIS analysis identifies spatial patterns of accessibility, while this preprocessing step converts selected spatial environments into model-ready networks.

The resulting files are used in the NetLogo models to simulate how agents encounter third places, decide whether to stop, linger, and become co-present with others.
