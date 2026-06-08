# Survey Analysis

This folder contains the survey cleaning, descriptive analysis, and exploratory regression analysis used in the thesis *Where Has All the Time Gone: The Role of Transport Connectivity and Third Places*.

The survey is used as an exploratory behavioural dataset. It does not aim to make representative neighbourhood-level claims about Amsterdam. Instead, it provides insight into how respondents experience time pressure, detour willingness, third-place use, lingering, familiarity, and barriers to regular third-place engagement.

## Purpose

The purpose of the survey analysis is to identify behavioural tendencies that help inform the agent-based simulation. The survey supports the thesis by showing that third-place use is shaped not only by spatial accessibility, but also by individual routines, time pressure, affordability, social familiarity, and willingness to stop or linger.

## Main Research Themes

The survey analysis focuses on:

- frequency of local third-place visits;
- willingness to detour for a casual stop;
- frequency of returning to the same place;
- tendency to stay longer than intended;
- perceived ease of reaching local third places;
- barriers to regular third-place use;
- familiar faces and small social interactions;
- time pressure and schedule rigidity;
- neighbourhood belonging and comfort.

## Main Files

Relevant notebooks may include:

- `clean_data.ipynb`  
  Cleans the raw survey responses, renames variables, standardises postcodes, and recodes ordinal survey items into numeric values.

- `survey_descriptives.ipynb`  
  Produces descriptive statistics for key behavioural variables used in the thesis and simulation.

- `survey_odds.ipynb`  
  Runs exploratory logistic regression models examining associations between behavioural/social factors and third-place stopping or lingering.

## Methodological Role

The survey is treated as exploratory rather than representative. The sample is small and unevenly distributed across Amsterdam, with a concentration of young respondents and students. For this reason, survey findings are not used to infer neighbourhood-level behavioural patterns.

Instead, the survey is used to identify behavioural tendencies that inform the simulation, including:

- baseline stopping tendency;
- detour tolerance;
- schedule flexibility;
- dwell time assumptions;
- social feedback effects;
- cost and comfort barriers;
- repeated use and familiarity mechanisms.

## Outputs Used in the Thesis

The survey analysis contributes to:

1. descriptive tables on third-place use, detour tolerance, lingering, and barriers;
2. exploratory logistic regression results;
3. behavioural assumptions for NetLogo model parameters;
4. interpretation of time pressure, affordability, and social familiarity as mechanisms shaping third-place use.


## Relation to Thesis

The survey analysis supports the thesis argument that accessibility alone does not guarantee third-place use. Even when places are physically reachable, respondents may still lack the time, money, comfort, or social motivation needed to stop, linger, and return regularly.

These behavioural insights are translated into the simulation through parameters such as baseline stopping probability, dwell time, schedule rigidity, detour tolerance, attribute-based choice, and social feedback.
Netlogo_preprocessing README.md
