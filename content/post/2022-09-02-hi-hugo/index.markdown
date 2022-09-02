---
title: How to create a new post for the site
author: Locke Data
authors: ["Locke Data"]
categories: ["tutorials"]
topics: ["website"]
date: '2022-09-02'
showonlyimage: yes
licenses: CC-BY
always_allow_html: yes
output: 
  md_document:
    variant: markdown_github
    preserve_yaml: true
---

## General workflow for contributing

``` r
library(leaflet)
map <- leaflet::leaflet() %>%
  addTiles() %>%
  fitBounds(0, 40, 10, 50) %>%
  addPopups(-93.65, 42.0285, "Here is the <b>Department of Statistics</b>, ISU")

learn::save_and_use_widget(map, "map.html")
```

<iframe src="widgets/map.html" width="100%" height="500px"></iframe>
