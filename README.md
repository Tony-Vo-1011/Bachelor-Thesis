# Bachelor Thesis Repository

This repository contains the data processing scripts, GIS analysis files, survey analysis notebooks, NetLogo preprocessing workflow, and agent-based simulation models used for the bachelor thesis:

**Where Has All the Time Gone: The Role of Transport Connectivity and Third Places**

The thesis investigates how transport connectivity, third-place accessibility, time pressure, and social familiarity interact to shape repeated co-presence in third places in Amsterdam.

## Repository Purpose

This repository provides the reproducibility materials for the thesis. It documents the workflow used to:

1. collect and process spatial data on Amsterdam neighbourhoods, road networks, and potential third places;
2. calculate third-place accessibility and transport accessibility across Amsterdam;
3. clean and analyse survey responses on mobility routines and third-place use;
4. convert GIS-derived spatial networks into NetLogo-compatible model inputs;
5. run exploratory agent-based simulations of third-place stopping, lingering, social feedback, and co-presence.

The repository is organised around the main methodological stages of the thesis: GIS analysis, survey analysis, NetLogo preprocessing, and NetLogo simulation.

## Folder Overview

### `GIS/`

This folder contains the spatial accessibility analysis used to classify Amsterdam neighbourhoods.

The GIS workflow uses:

* CBS Wijk- en Buurtkaart neighbourhood boundaries;
* OpenStreetMap / Overpass Turbo third-place locations;
* Geofabrik OpenStreetMap road network data;
* ArcGIS Pro Network Analyst outputs;
* Python notebooks for processing OD matrix results and calculating composite accessibility indices.

The GIS analysis produces two main outputs:

1. **Third-place accessibility index**
   Measures the number of potential third places reachable from each neighbourhood within selected travel-time thresholds.

2. **Transport accessibility index**
   Measures average travel time from each neighbourhood to all other neighbourhoods across walking, cycling, and driving.

These indices are then combined into a neighbourhood typology:

* high transport / high third-place accessibility;
* high transport / low third-place accessibility;
* low transport / high third-place accessibility;
* low transport / low third-place accessibility.

These typologies are used to select representative spatial environments for the simulation.

### `Survey_analysis/`

This folder contains the survey cleaning, descriptive statistics, and exploratory regression analysis.

The survey is used as an exploratory behavioural dataset rather than a representative citywide sample. Its purpose is to identify behavioural tendencies that inform the simulation, including:

* detour tolerance;
* schedule rigidity;
* time pressure;
* third-place visit frequency;
* returning to the same place;
* lingering behaviour;
* familiar faces;
* small social interactions;
* affordability and cost barriers;
* comfort and welcomingness.

The survey results are not used to make neighbourhood-level spatial claims. Instead, they provide behavioural assumptions for the NetLogo model parameters.

Key notebooks may include:

* `clean_data.ipynb`
* `survey_descriptives.ipynb`
* `survey_odds.ipynb`

### `Netlogo_preprocessing/`

This folder contains the workflow for converting GIS-derived spatial data into NetLogo-compatible model inputs.

The preprocessing stage converts selected neighbourhood or district environments into simplified network files that can be imported into NetLogo. This includes:

* road nodes;
* road links;
* third-place point locations;
* cleaned coordinate files;
* selected model environments.

This folder acts as the technical bridge between the GIS accessibility analysis and the agent-based simulation.

The resulting files allow agents in NetLogo to move along a simplified but geographically informed road network rather than across an abstract grid.

### `Netlogo/`

This folder contains the NetLogo model files and Python/PyNetLogo experiment notebooks used in the simulation analysis.

Main NetLogo model files include:

* `personal_mobility.nlogo`
  Model 1: Personal Mobility Routines.
  This model simulates agents moving between simplified home and activity nodes while deciding whether to stop at third places based on route exposure, schedule rigidity, dwell time, and social feedback.

* `third_place_attributes.nlogo`
  Model 2: Third Place Attributes.
  This model extends the baseline model by adding place-level attributes such as affordability, welcomingness, and safety. Agents can filter places based on these attributes, allowing the model to test whether attribute-based choice concentrates visits and increases co-presence.

Python/PyNetLogo notebooks may include:

* `sweeps.ipynb`
* `model_1.ipynb`
* `model_2.ipynb`

These notebooks are used to run parameter sweeps, repeat simulations, collect outputs, and process results for the thesis.

## Main Thesis Workflow

The repository follows the same sequence as the thesis methodology:

```text
GIS spatial analysis
        ↓
Neighbourhood accessibility typology
        ↓
Survey behavioural analysis
        ↓
GIS-to-NetLogo preprocessing
        ↓
Agent-based simulation
        ↓
Simulation output analysis
```

The GIS analysis provides the spatial structure of the research.
The survey analysis provides behavioural assumptions.
The NetLogo models test how spatial exposure and behavioural rules interact over time.

