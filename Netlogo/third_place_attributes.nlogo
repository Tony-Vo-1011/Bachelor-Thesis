extensions [csv nw]

breed [road-nodes road-node]
undirected-link-breed [road-edges road-edge]

breed [places place]
breed [people person]


;; VARIABLES

globals [
  node-table
  edge-table
  place-table
]

road-nodes-own [
  node-id
  visits
]

road-edges-own [
  edge-id
  length-m
]

places-own [
  place-id
  nearest-node-id
  visit-count ;; total visits to this place

  current-visitors ;; how many people are currently dwelling there
  cumulative-co-presence ;; total accumulated overlap over time
  max-simultaneous-visitors ;; highest number of people present at once

  place-affordability
  place-welcomingness
  place-attractiveness
]

people-own [
  place-id
  home-node-id
  activity-node-id

  current-node-id
  destination-node-id
  destination-type
  destination-place-id

  route-nodes
  route-index
  target-node

  person-status
  dwell-time-remaining
  current-place-id


  completed-trips
  third-place-visits

  schedule-type
  schedule-fixedness
  schedule-odds-ratio
  social-encounters
  social-odds-ratio
  stop-probability
  personal-dwell-time
  search-radius-multiplier

  price-sensitivity
  comfort-sensitivity
]



;; SETUP

to setup
  clear-all
  load-node-table
  setup-road-nodes
  load-edge-table
  setup-road-edges
  load-place-table
  setup-places
  setup-people
  reset-ticks
  show "Setup complete"
end

to load-node-table
  ; Path for GIS Desktop
  ; set node-table csv:from-file "C:/Users/15177459/Desktop/netlogo/data/sample/sample_nodes.csv"
  ; Path for Mac Laptop
  set node-table csv:from-file "/Users/tonyvo/Desktop/Thesis/netlogo/data/roads/sample_nodes.csv"
end

to load-edge-table
  ; Path for GIS Desktop
  ; set edge-table csv:from-file "C:/Users/15177459/Desktop/netlogo/data/sample/sample_edges.csv"
  ; Path for Mac Laptop
  set edge-table csv:from-file "/Users/tonyvo/Desktop/Thesis/netlogo/data/roads/sample_edges.csv"
end

to load-place-table
  ; Path for GIS Desktop
  ; set place-table csv:from-file "C:/Users/15177459/Desktop/netlogo/data/sample/sample_places.csv"
  ; Path for Mac Laptop
  set place-table csv:from-file "/Users/tonyvo/Desktop/Thesis/netlogo/data/places/sample_places.csv"
end

to setup-road-nodes
  let rows but-first node-table

  foreach rows [ row ->
    if length row >= 3 [
      let this-node-id item 0 row
      let xcor-val item 1 row
      let ycor-val item 2 row

      create-road-nodes 1 [
        setxy xcor-val ycor-val
        set node-id this-node-id
        hide-turtle
      ]
    ]
  ]
end

to setup-road-edges
  let rows but-first edge-table

  foreach rows [ row ->
    if length row >= 4 [
      let this-edge-id item 0 row
      let from-id item 1 row
      let to-id item 2 row
      let this-length item 3 row

      let from-node one-of road-nodes with [ node-id = from-id ]
      let to-node one-of road-nodes with [ node-id = to-id ]

      if from-node = nobody or to-node = nobody [
        show (word "Missing node for edge " this-edge-id
              " | from-id=" from-id
              " | to-id=" to-id)
      ]

      if from-id = to-id [
        show (word "Self-loop skipped for edge " this-edge-id
              " | node-id=" from-id)
      ]

      if from-node != nobody and to-node != nobody and from-id != to-id [
        ask from-node [
          if not road-edge-neighbor? to-node [
            create-road-edge-with to-node [
              set edge-id this-edge-id
              set length-m this-length
              set color green
              set thickness 0.05
            ]
          ]
        ]
      ]
    ]

    if length row < 4 [
      show (word "Bad edge row: " row)
    ]
  ]
end

to setup-places
  let rows but-first place-table

  foreach rows [ row ->
    if length row >= 2 [
      let this-place-id item 0 row
      let this-nearest-node-id item 1 row

      let nearest-node one-of road-nodes with [ node-id = this-nearest-node-id ]

      if nearest-node = nobody [
        show (word "Missing nearest node for place " this-place-id
              " | nearest-node-id=" this-nearest-node-id)
      ]

      if nearest-node != nobody [
        create-places 1 [
          set place-id this-place-id
          set nearest-node-id this-nearest-node-id
          set visit-count 0

          set current-visitors 0
          set cumulative-co-presence 0
          set max-simultaneous-visitors 0


          ;; third place attributes
          set place-affordability random-float 1
          set place-welcomingness random-float 1
          set place-attractiveness 0

          ; option 1: place exactly on the node
          move-to nearest-node

          ; make visible
          set color blue
          set size 0.1
          set shape "circle"
        ]
      ]
    ]

    if length row < 2 [
      show (word "Bad place row: " row)
    ]
  ]
end

to setup-people
  create-people number-of-people [
    let home-node one-of road-nodes with [ any? link-neighbors ]

    let activity-node one-of road-nodes with [
      any? link-neighbors and node-id != [node-id] of home-node
    ]

    move-to home-node

    set home-node-id [node-id] of home-node
    set activity-node-id [node-id] of activity-node
    set current-node-id home-node-id

    set destination-node-id activity-node-id
    set destination-type "activity"
    set destination-place-id -1

    set route-nodes []
    set route-index 0
    set target-node nobody

    set person-status "traveling"
    set dwell-time-remaining 0
    set current-place-id -1

    assign-schedule-profile
    assign-person-preferences

    set completed-trips 0
    set third-place-visits 0

    set color cyan
    set size 0.2
    set shape "person"
  ]

  show (word "Created " count people " people")
end

to assign-person-preferences  ;; person procedure

  ;; 0 = not sensitive, 1 = highly sensitive.
  ;; These are stylised individual differences, not direct survey measurements.
  set price-sensitivity random-float 1
  set comfort-sensitivity random-float 1

end

to-report probability-after-odds-ratio [base-probability odds-ratio]
  let base-odds base-probability / (100 - base-probability)
  let adjusted-odds base-odds * odds-ratio
  report 100 * adjusted-odds / (1 + adjusted-odds)
end

to-report effective-stop-probability  ;; person reporter
  let base-odds baseline-stop-probability / (100 - baseline-stop-probability)

  let adjusted-odds base-odds * schedule-odds-ratio * social-odds-ratio

  report 100 * adjusted-odds / (1 + adjusted-odds)
end

to assign-schedule-profile  ;; person procedure

  ;; 0 = very flexible, 1 = very fixed/rushed
  set schedule-fixedness random-float 1

  ;; Too-rushed odds ratio from survey = 0.4.
  ;; A fully fixed schedule gets OR 0.4.
  ;; A fully flexible schedule gets OR 1.0.
  set schedule-odds-ratio 1 - (0.6 * schedule-fixedness)

  ;; Everyone starts with no accumulated social familiarity.
  set social-encounters 0
  set social-odds-ratio 1

  ;; Keep schedule-type only as a descriptive category for outputs.
  if schedule-fixedness >= 0.66 [
    set schedule-type "rigid"
    set personal-dwell-time rigid-dwell-time
    set search-radius-multiplier 0.7
  ]

  if schedule-fixedness < 0.66 and schedule-fixedness >= 0.33 [
    set schedule-type "medium"
    set personal-dwell-time medium-dwell-time
    set search-radius-multiplier 1.0
  ]

  if schedule-fixedness < 0.33 [
    set schedule-type "flexible"
    set personal-dwell-time flexible-dwell-time
    set search-radius-multiplier 1.3
  ]

  set stop-probability effective-stop-probability
end


;; MECHANISMS

to choose-next-routine-destination  ;; person procedure

  ; If currently at home, go to activity
  if current-node-id = home-node-id [
    set destination-node-id activity-node-id
    set destination-type "activity"
    set destination-place-id -1
    stop
  ]

  ; If currently at activity, maybe go to a third place before home
  if current-node-id = activity-node-id [

    ;; Recalculate stop probability every time the person has a chance to stop.
    ;; This allows previous encounters to affect future behaviour.
    set stop-probability effective-stop-probability

    ifelse random-float 100 < stop-probability and any? places [
      choose-third-place-destination
    ] [
      set destination-node-id home-node-id
      set destination-type "home"
      set destination-place-id -1
    ]
    stop
  ]

  ; If currently at a third place or anywhere else, go home
  set destination-node-id home-node-id
  set destination-type "home"
  set destination-place-id -1
end

to choose-third-place-destination  ;; person procedure
  let home-route route-home-nodes

  if empty? home-route [
    set destination-node-id home-node-id
    set destination-type "home"
    set destination-place-id -1
    stop
  ]

  let route-sample sampled-route-nodes home-route
  let personal-search-radius third-place-search-radius * search-radius-multiplier

  let route-places places with [
    nearest-node-id != [current-node-id] of myself and
    place-near-route? self route-sample personal-search-radius
  ]

  ifelse any? route-places [

    let destination nobody

    ifelse attribute-based-choice? [
      set destination choose-attractive-third-place route-places
    ] [
      set destination one-of route-places
    ]

    set destination-place-id [place-id] of destination
    set destination-node-id [nearest-node-id] of destination
    set destination-type "third-place"

  ] [
    set destination-node-id home-node-id
    set destination-type "home"
    set destination-place-id -1
  ]
end

to-report choose-attractive-third-place [candidate-places]  ;; person reporter

  ask candidate-places [
    set place-attractiveness
      ((place-affordability * [price-sensitivity] of myself) +
       (place-welcomingness * [comfort-sensitivity] of myself) +
       (current-visitors * 0.05)) ;; busier places get slight boost in attractiveness
  ]

  let candidate-count min list 5 count candidate-places
  let top-candidates max-n-of candidate-count candidate-places [place-attractiveness]

  report one-of top-candidates

end

to-report place-near-route? [candidate-place route-list allowed-radius]
  let candidate-node one-of road-nodes with [
    node-id = [nearest-node-id] of candidate-place
  ]

  if candidate-node = nobody [
    report false
  ]

  foreach route-list [ route-node ->
    if distance-between-nodes route-node candidate-node <= allowed-radius [
      report true
    ]
  ]

  report false
end

to-report distance-between-nodes [node-a node-b]
  report [distance node-b] of node-a
end

to-report route-home-nodes  ;; person reporter
  let start-node one-of road-nodes with [
    node-id = [current-node-id] of myself
  ]

  let home-node one-of road-nodes with [
    node-id = [home-node-id] of myself
  ]

  if start-node = nobody or home-node = nobody [
    report []
  ]

  let path [ nw:turtles-on-path-to home-node ] of start-node

  if path = false [
    report []
  ]

  report path
end

to-report sampled-route-nodes [route-list]
  if length route-list <= route-third-place-sample-size [
    report route-list
  ]

  report n-of route-third-place-sample-size route-list
end

to plan-route  ;; person procedure
  let start-node one-of road-nodes with [ node-id = [current-node-id] of myself ]
  let end-node one-of road-nodes with [ node-id = [destination-node-id] of myself ]

  if start-node != nobody and end-node != nobody [
    let path [ nw:turtles-on-path-to end-node ] of start-node

    if path != false and length path > 1 [
      set route-nodes path
      set route-index 1
      set target-node item route-index route-nodes
    ]

    if path = false [
      show (word "No path found from node " [node-id] of start-node
                 " to node " [node-id] of end-node)
      set route-nodes []
      set route-index 0
      set target-node nobody
    ]
  ]
end

to move-along-route  ;; person procedure
  if target-node != nobody [
    face target-node
    fd 0.05

    if distance target-node < 0.05 [
      move-to target-node
      set current-node-id [node-id] of target-node

      set route-index route-index + 1

      ifelse route-index < length route-nodes [
        ; still more nodes left in the route
        set target-node item route-index route-nodes
      ] [
        ; arrived at final destination
        set completed-trips completed-trips + 1

        set target-node nobody
        set route-nodes []
        set route-index 0

        if destination-type = "third-place" [
          enter-third-place
        ]
      ]
    ]
  ]
end

to enter-third-place  ;; person procedure
  let destination-place one-of places with [
    place-id = [destination-place-id] of myself
  ]

  if destination-place != nobody [

    ;; People already dwelling at this third place are treated as encountered.
    let encountered-people other people with [
      person-status = "dwelling" and
      current-place-id = [destination-place-id] of myself
    ]

    let number-encountered count encountered-people

    set third-place-visits third-place-visits + 1
    set current-place-id destination-place-id
    set person-status "dwelling"
    set dwell-time-remaining personal-dwell-time

    ;; The arriving person gains familiarity from everyone already there.
    if number-encountered > 0 [
      register-social-encounter number-encountered

      ;; People already there also experience the arrival as a new encounter.
      ask encountered-people [
        register-social-encounter 1
      ]
    ]

    ask destination-place [
      set visit-count visit-count + 1
      set current-visitors current-visitors + 1

      if current-visitors > max-simultaneous-visitors [
        set max-simultaneous-visitors current-visitors
      ]
    ]
  ]
end

to dwell-at-third-place  ;; person procedure
  set dwell-time-remaining dwell-time-remaining - 1

  if dwell-time-remaining <= 0 [
    let old-place one-of places with [
      place-id = [current-place-id] of myself
    ]

    if old-place != nobody [
      ask old-place [
        set current-visitors current-visitors - 1
      ]
    ]

    set current-place-id -1
    set person-status "traveling"

    set destination-node-id home-node-id
    set destination-type "home"
    set destination-place-id -1

    plan-route
  ]
end

to go
  ;  if ticks >= 1000 [
  ;    show (word "Visits/person: " visits-per-person)
  ;    show (word "Average stop probability: " average-stop-probability)
  ;    show (word "Average social encounters: " average-social-encounters)
  ;    show (word "Total co-presence: " total-co-presence)
  ;    stop
  ;  ]

  ask people [
    ifelse person-status = "dwelling" [
      dwell-at-third-place
    ] [
      if target-node = nobody and empty? route-nodes [
        choose-next-routine-destination
        plan-route
      ]

      move-along-route
    ]
  ]

  update-place-co-presence

  tick
end

to update-place-co-presence
  ask places [
    if current-visitors > 1 [
      set cumulative-co-presence cumulative-co-presence + current-visitors
    ]

    if current-visitors > max-simultaneous-visitors [
      set max-simultaneous-visitors current-visitors
    ]
  ]
end

to register-social-encounter [number-met]  ;; person procedure
  ;; person stops at a third place
  ;; ↓
  ;; they overlap with other people there
  ;; ↓
  ;; this is counted as a social encounter
  ;; ↓
  ;; social encounters increase their social odds ratio
  ;; ↓
  ;; higher social odds ratio increases their future stop probability

  ;; Always count encounters, even in the control experiment.
  set social-encounters social-encounters + (number-met * encounter-weight)

  ;; If feedback is switched off, encounters do not affect future stopping.
  if not social-feedback? [
    set social-odds-ratio 1
    set stop-probability effective-stop-probability
    stop
  ]

  ;; Familiar faces odds ratio from survey = 2.8.
  ;; Social odds ratio starts at 1 and rises toward 2.8.
  set social-odds-ratio min list 2.8 (1 + social-encounters * encounter-odds-increment)

  set stop-probability effective-stop-probability
end



;; REPORTERS

to-report total-completed-trips
  report sum [completed-trips] of people
end

to-report total-third-place-visits
  report sum [third-place-visits] of people
end

to-report average-third-place-visits
  if not any? people [ report 0 ]
  report mean [third-place-visits] of people
end

to-report visited-places-count
  report count places with [visit-count > 0]
end

to-report has-route-third-place-options?  ;; person reporter
  let home-route route-home-nodes

  if empty? home-route [
    report false
  ]

  let route-sample sampled-route-nodes home-route
  let personal-search-radius third-place-search-radius * search-radius-multiplier

  report any? places with [
    place-near-route? self route-sample personal-search-radius
  ]
end

to-report people-with-route-third-place-options
  report count people with [has-route-third-place-options?]
end

to-report route-third-place-options-count  ;; person reporter
  let home-route route-home-nodes

  if empty? home-route [
    report 0
  ]

  let route-sample sampled-route-nodes home-route
  let personal-search-radius third-place-search-radius * search-radius-multiplier

  report count places with [
    place-near-route? self route-sample personal-search-radius
  ]
end

to-report average-route-third-place-options
  if not any? people [
    report 0
  ]

  report mean [route-third-place-options-count] of people
end

to-report total-current-third-place-visitors
  report sum [current-visitors] of places
end

to-report total-co-presence
  report sum [cumulative-co-presence] of places
end

to-report active-third-places-now
  report count places with [current-visitors > 0]
end

to-report places-with-co-presence
  report count places with [cumulative-co-presence > 0]
end

to-report average-stop-probability
  if not any? people [ report 0 ]
  report mean [stop-probability] of people
end

to-report average-social-encounters
  if not any? people [ report 0 ]
  report mean [social-encounters] of people
end

to-report average-social-odds-ratio
  if not any? people [ report 0 ]
  report mean [social-odds-ratio] of people
end

to-report visits-per-person
  if not any? people [ report 0 ]
  report mean [third-place-visits] of people
end

to-report co-presence-per-visit
  if total-third-place-visits = 0 [ report 0 ]
  report total-co-presence / total-third-place-visits
end

to-report share-places-visited
  if not any? places [ report 0 ]
  report visited-places-count / count places
end

to-report average-place-affordability
  if not any? places [ report 0 ]
  report mean [place-affordability] of places
end

to-report average-place-welcomingness
  if not any? places [ report 0 ]
  report mean [place-welcomingness] of places
end

to-report average-visited-place-affordability
  let visited places with [visit-count > 0]
  if not any? visited [ report 0 ]
  report mean [place-affordability] of visited
end

to-report average-visited-place-welcomingness
  let visited places with [visit-count > 0]
  if not any? visited [ report 0 ]
  report mean [place-welcomingness] of visited
end

to-report visit-concentration
  if not any? places [ report 0 ]
  if sum [visit-count] of places = 0 [ report 0 ]
  report max [visit-count] of places / sum [visit-count] of places
end














































@#$#@#$#@
GRAPHICS-WINDOW
210
10
654
455
-1
-1
20.8
1
10
1
1
1
0
1
1
1
-10
10
-10
10
0
0
1
ticks
30.0

SLIDER
663
14
835
47
number-of-people
number-of-people
100
1000
200.0
1
1
NIL
HORIZONTAL

SLIDER
910
10
1122
43
baseline-stop-probability
baseline-stop-probability
0
50
30.0
1
1
NIL
HORIZONTAL

SLIDER
662
210
834
243
rigid-dwell-time
rigid-dwell-time
0
100
30.0
1
1
NIL
HORIZONTAL

SLIDER
840
210
1014
243
medium-dwell-time
medium-dwell-time
0
100
45.0
1
1
NIL
HORIZONTAL

SLIDER
1018
210
1190
243
flexible-dwell-time
flexible-dwell-time
0
100
60.0
1
1
NIL
HORIZONTAL

SLIDER
663
53
880
86
third-place-search-radius
third-place-search-radius
0
25
2.0
1
1
NIL
HORIZONTAL

SLIDER
910
49
1134
82
encounter-odds-increment
encounter-odds-increment
0
0.2
0.1
0.01
1
NIL
HORIZONTAL

SLIDER
663
92
887
125
route-third-place-sample-size
route-third-place-sample-size
0
100
50.0
1
1
NIL
HORIZONTAL

SWITCH
664
148
825
181
social-feedback?
social-feedback?
0
1
-1000

BUTTON
137
10
203
43
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
136
49
203
82
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
909
86
1082
119
encounter-weight
encounter-weight
0
10
5.0
1
1
NIL
HORIZONTAL

SWITCH
856
150
1065
184
attribute-based-choice?
attribute-based-choice?
0
1
-1000

@#$#@#$#@
## WHAT IS IT?

Two stylised third-place attributes were added to the model: affordability and welcomingness. Affordability reflects the high share of respondents who identified cost as a barrier to regular third-place use. Welcomingness captures softer forms of social accessibility, including language or cultural barriers, feeling out of place, and safety concerns. These attributes are not direct empirical measurements of actual third places in Amsterdam, but stylised calibration values that allow the model to examine how reachable places may still differ in their attractiveness to different users.

## HOW IT WORKS

Should I stop?
↓
Find third places near route
↓
Score each third place based on affordability, safety, sociality, and current visitors
↓
Choose a place probabilistically based on attractiveness

## HOW TO USE IT

DEFAULT PARAMETERS
number-of-people = 200
baseline-stop-probability = 30
third-place-search-radius = 2
route-third-place-sample-size = 50 
encounter-odds-increment = 0.10
encounter-weight = 5
medium-dwell-time = 45
rigid-dwell-time = 30
flexible-dwell-time = 60
social-feedback? = on
attribute-based-choice? = on


## DEFAULT SETTINGS

number-of-people = 200
baseline-stop-probability = 30
encounter-odds-increment = 0.10
encounter-weight = 5
medium-dwell-time = 45
rigid-dwell-time = 30
flexible-dwell-time = 60
social-feedback? = on

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
