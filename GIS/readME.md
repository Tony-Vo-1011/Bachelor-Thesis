This folder contains the GIS-based accessibility analysis used in the thesis *Where Has All the Time Gone: The Role of Transport Connectivity and Third Places*. The GIS analysis provides the spatial foundation for the research by measuring and mapping differences in third-place accessibility and general transport accessibility across Amsterdam neighbourhoods.

## Purpose

The purpose of this folder is to document the spatial analysis used to classify Amsterdam neighbourhoods according to:

1. third-place accessibility;
2. general transport accessibility;
3. combined third-place and transport accessibility typologies.

These outputs are used to identify contrasting neighbourhood conditions and to provide spatial inputs for the later agent-based simulation.

## Data Sources

The GIS analysis uses three main data sources:

- **CBS Wijk- en Buurtkaart**  
  Used for Amsterdam neighbourhood boundaries.

- **OpenStreetMap / Overpass Turbo**  
  Used to collect potential third-place locations, including cafés, bars, restaurants, parks, libraries, community centres, gyms, places of worship, and other informal or semi-public spaces.

- **Geofabrik OpenStreetMap road network extract**  
  Used to construct the routable road network for walking, cycling, and driving accessibility analysis.

## Main Subfolders

### `third_places/`

Contains scripts and outputs related to third-place accessibility. Third-place accessibility is measured as the number of potential third places reachable from each neighbourhood centroid within selected travel-time thresholds.

Main analysis steps include:

- importing third-place points from OpenStreetMap/Overpass Turbo;
- running OD cost matrix analyses from neighbourhood centroids to third-place locations;
- calculating reachable third-place counts for walking, cycling, and driving;
- standardising accessibility values using z-scores;
- producing a composite third-place accessibility index.

Relevant notebooks include:

- `nearest_5.ipynb`
- `z_score.ipynb`

### `transport/`

Contains scripts and outputs related to general transport accessibility. Transport accessibility is measured using average travel time from each neighbourhood centroid to all other neighbourhood centroids.

Main analysis steps include:

- running OD cost matrix analyses between Amsterdam neighbourhood centroids;
- calculating average travel time to all other neighbourhoods;
- reversing travel-time z-scores so that higher values represent better accessibility;
- producing a composite transport accessibility index across walking, cycling, and driving.

Relevant notebooks may include:

- `all_destinations.ipynb`
- `z_score.ipynb`

## Methodological Notes

Third-place accessibility and transport accessibility are measured differently.

Third-place accessibility uses travel-time cutoffs because the thesis is interested in local, routine access to places where spontaneous stopping and repeated co-presence may occur.

Transport accessibility does not use a cutoff. Instead, it measures average travel time to all other neighbourhoods in Amsterdam, because the aim is to capture broader citywide network connectivity.

Both accessibility indices are standardised using z-scores so that walking, cycling, and driving outputs can be combined into composite indices.


## Relation to Thesis

The outputs from this folder are used in the thesis to:

- map the spatial distribution of potential third-place accessibility;
- map general transport accessibility across Amsterdam;
- classify neighbourhoods into high/low third-place and high/low transport accessibility categories;
- select representative neighbourhood environments for the NetLogo simulation.
Survey_analysis README.md
