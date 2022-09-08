---
title: Combien rapporterait la taxe sur la richesse de QS ?
author: Simon
date: '2022-09-08'
slug: combien-taxe-richesse
categories:
  - rstats
  - pumf
  - ESF
  - qs2022
tags:
  - tag1
  - tag2
keywords:
  - tech
---

Ça parle beaucoup d’impôt sur le patimoine (ou avoir net) ces temps-ci au Québec!

Dans un post précédent, j’ai validé la proportion des gens qui seraient touchés par la taxe sur la richesse proposée.

[Rappelons les paramètres](https://www.lesoleil.com/2022/09/06/les-grands-fortunes-dans-la-mire-fiscale-de-quebec-solidaire-4fe7386f5fb8cbea5defbaa3684795e8):

Impôt sur les grandes fortunes :

-   Le premier million d’actifs net est exempté d’impôt  
-   Entre 1 million et 9,9 millions: 0,1% de l’actif net
-   Entre 10 millions et 99 millions: 1% de l’actif net
-   Plus de 100 millions: 1,5% de l’actif net

La question que je me pose aujourd’hui:
- Combien est-ce qu’on peut aller chercher avec cette taxe là?  
- Combien est-ce qu’on perdrait en fichant la paix aux gens en bas de 2 millions? 3?

let’s gooo

# Les données

On a découvert hier une super source de données: le PUMF de l’Enquête sur la Sécurité Financière du Statistiques Canada.  
[On en a parlé hier](https://www.simoncoulombe.com/2022/09/ultra-riches/) et [plus tôt aujourd’hui](https://www.simoncoulombe.com/2022/09/impot-foncier/), c’était super intéressant, allez voir

Il comporte 2003 les données de 2003 ménages au Québec, chacun ayant un poids échantillonal entre 150 et 8000.

Les variables que l’on va utiliser sont les suivantes:

PWNETWT : valeur nette de l’unité familliale (base de terminaison).  
PFMTYPG : le type de famille

Voici les types de familles possibles :

    ## # A tibble: 5 × 2
    ##   PFMTYPG type_menage                                      
    ##   <chr>   <chr>                                            
    ## 1 1       Personne seule                                   
    ## 2 2       Couple, sans enfant                              
    ## 3 3       Couple, avec des enfants et famille monoparentale
    ## 4 4       Autres types de famille                          
    ## 5 9       Non déclaré

Le problème c’est que la taxe de QS serait sur l’avoir net de l’individu et que nous disposons de l’avoir net du ménage.
On va faire l’hypothèse (assez forte), que les adultes dans le ménage vont se partager à part égales l’avoir net afin de minimiser leur charge fiscale.

Un problème important subsite: pour les types de familles \#3, \#4 et \#5 il pourrait y avoir 1 ou 2 adultes.

Nous allons donc faire deux scénarios: Le “impôt maximum”, où l’on suppose qu’il n’y a qu’un seul adulte et le scénario “impôt minimum” où l’o suppose qu’il y a deux adultes.

# Les manips

-   Le premier million d’actifs net est exempté d’impôt  
-   Entre 1 million et 9,9 millions: 0,1% de l’actif net
-   Entre 10 millions et 99 millions: 1% de l’actif net
-   Plus de 100 millions: 1,5% de l’actif net

Voici à quoi ressemblent les micro-données brutes préparées (et triées en ordre descendant d’avoir net)

    ## # A tibble: 2,003 × 16
    ##    PWNETWPT PWEIGHT PWAPRVAL PWASTRST PAGEMIEG PFMTYPG gr_age  type_menage
    ##       <dbl>   <dbl>    <dbl>    <dbl> <chr>    <chr>   <chr>   <chr>      
    ##  1 17741925   1187.   950000  1650000 08       9       45-54   Non déclaré
    ##  2 16090000    569.        0        0 12       9       65-plus Non déclaré
    ##  3 14336450   1775.   420000  2500000 10       9       55-64   Non déclaré
    ##  4 13824500   1105.  1000000   875000 08       9       45-54   Non déclaré
    ##  5 11528400   1581.   280000        0 10       9       55-64   Non déclaré
    ##  6 10427000    781.   775000    75000 08       9       45-54   Non déclaré
    ##  7 10425000    837.   525000   475000 10       9       55-64   Non déclaré
    ##  8  9625000    557.   925000        0 12       9       65-plus Non déclaré
    ##  9  9582500    661.  1400000  4900000 09       9       55-64   Non déclaré
    ## 10  8812500   2033.   725000        0 06       9       35-44   Non déclaré
    ## # … with 1,993 more rows, and 8 more variables:
    ## #   nombre_adulte_scenario_min <dbl>, nombre_adulte_scenario_max <dbl>,
    ## #   valeur_par_adulte_scenario_min <dbl>, valeur_par_adulte_scenario_max <dbl>,
    ## #   taxe_par_adulte_scenario_min <dbl>, taxe_par_adulte_scenario_max <dbl>,
    ## #   taxe_totale_scenario_min <dbl>, taxe_totale_scenario_max <dbl>

Vous pouvez voir que le ménage le plus cher de l’échantillon a une valeur nette de 17 741 925\$ (PWNETWPT) et qu’il représente 1186 ménages (PWEIGHT).
Apparemment on n’est pas tombés sur les Desmarais.

Première déception: leur type de ménage (PFMTYPG) est le “9”, soit “Non déclaré”.  
Deuxième déception: c’est le cas de 31 des 33 ménages les plus riches de l’échantillon. C’est probablement pour mieux préserver la confidentialité de nos riches.

Ça fait une sacré différence selon le scénario. Pour le ménage le plus riche, un seul individu valant 17M paierait 86 419\$, tandis que deux individus valant 8.8M paieraient seulement 7 870\$ pour un total de 15 741 \$.

On récupèrerait donc plus de 5x plus d’argent dans le premier scénario.

Voici quand même la valeur totale qu’on obtient au Québec dans les 2 scénarios, ainsi que dans un scénario où la moitié des familles dont on ne connait pas la taille sont composées d’une personne
seul et l’autre moitié d’un couple.

<div id="ccctafpyly" style="overflow-x:auto;overflow-y:auto;width:1080px;height:auto;">
<style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#ccctafpyly .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#ccctafpyly .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#ccctafpyly .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#ccctafpyly .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 0;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#ccctafpyly .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#ccctafpyly .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#ccctafpyly .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#ccctafpyly .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#ccctafpyly .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#ccctafpyly .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#ccctafpyly .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#ccctafpyly .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
}

#ccctafpyly .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#ccctafpyly .gt_from_md > :first-child {
  margin-top: 0;
}

#ccctafpyly .gt_from_md > :last-child {
  margin-bottom: 0;
}

#ccctafpyly .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#ccctafpyly .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}

#ccctafpyly .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}

#ccctafpyly .gt_row_group_first td {
  border-top-width: 2px;
}

#ccctafpyly .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#ccctafpyly .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#ccctafpyly .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#ccctafpyly .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#ccctafpyly .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#ccctafpyly .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#ccctafpyly .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#ccctafpyly .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#ccctafpyly .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#ccctafpyly .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-left: 4px;
  padding-right: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#ccctafpyly .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#ccctafpyly .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#ccctafpyly .gt_left {
  text-align: left;
}

#ccctafpyly .gt_center {
  text-align: center;
}

#ccctafpyly .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#ccctafpyly .gt_font_normal {
  font-weight: normal;
}

#ccctafpyly .gt_font_bold {
  font-weight: bold;
}

#ccctafpyly .gt_font_italic {
  font-style: italic;
}

#ccctafpyly .gt_super {
  font-size: 65%;
}

#ccctafpyly .gt_footnote_marks {
  font-style: italic;
  font-weight: normal;
  font-size: 75%;
  vertical-align: 0.4em;
}

#ccctafpyly .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#ccctafpyly .gt_indent_1 {
  text-indent: 5px;
}

#ccctafpyly .gt_indent_2 {
  text-indent: 10px;
}

#ccctafpyly .gt_indent_3 {
  text-indent: 15px;
}

#ccctafpyly .gt_indent_4 {
  text-indent: 20px;
}

#ccctafpyly .gt_indent_5 {
  text-indent: 25px;
}
</style>
<table class="gt_table">
  <caption>(#tab:scenario1)Données PUMF ESF Statcan pour le Québec 2019, calculs @coulsim</caption>
  <thead class="gt_header">
    <tr>
      <td colspan="9" class="gt_heading gt_title gt_font_normal gt_bottom_border" style>Taxe sur la richesse récoltée selon le type de ménage</td>
    </tr>
    
  </thead>
  <thead class="gt_col_headings">
    <tr>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col"></th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col">Nombre d'observations</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col">Nombre pondéré de ménages</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col">Nombre de ménages taxés dans le scénario minimal</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col">Nombre de ménages taxés dans le scénario maximal</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col">Taxe totale perçue dans le scénario minimal</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col">Taxe totale perçue dans le scénario maximal</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col">Nombre de ménages taxés dans le scénario 50-50</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col">Taxe totale perçue dans le scénario 50-50</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><th scope="row" class="gt_row gt_left gt_stub">Non déclaré</th>
<td class="gt_row gt_right">63</td>
<td class="gt_row gt_right">66,791</td>
<td class="gt_row gt_right">34,918</td>
<td class="gt_row gt_right">50,891</td>
<td class="gt_row gt_right">$218 486 324</td>
<td class="gt_row gt_right">$508 240 648</td>
<td class="gt_row gt_right">42,904</td>
<td class="gt_row gt_right">363,363,486</td></tr>
    <tr><th scope="row" class="gt_row gt_left gt_stub">Autres types de famille</th>
<td class="gt_row gt_right">233</td>
<td class="gt_row gt_right">486,400</td>
<td class="gt_row gt_right">33,906</td>
<td class="gt_row gt_right">130,884</td>
<td class="gt_row gt_right">$29 165 117</td>
<td class="gt_row gt_right">$94 274 574</td>
<td class="gt_row gt_right">82,395</td>
<td class="gt_row gt_right">61,719,846</td></tr>
    <tr><th scope="row" class="gt_row gt_left gt_stub">Couple, avec des enfants et famille monoparentale</th>
<td class="gt_row gt_right">442</td>
<td class="gt_row gt_right">759,009</td>
<td class="gt_row gt_right">21,727</td>
<td class="gt_row gt_right">92,254</td>
<td class="gt_row gt_right">$14 986 027</td>
<td class="gt_row gt_right">$61 369 005</td>
<td class="gt_row gt_right">56,990</td>
<td class="gt_row gt_right">38,177,516</td></tr>
    <tr><th scope="row" class="gt_row gt_left gt_stub">Couple, sans enfant</th>
<td class="gt_row gt_right">626</td>
<td class="gt_row gt_right">969,261</td>
<td class="gt_row gt_right">66,396</td>
<td class="gt_row gt_right">66,396</td>
<td class="gt_row gt_right">$61 172 283</td>
<td class="gt_row gt_right">$61 172 283</td>
<td class="gt_row gt_right">66,396</td>
<td class="gt_row gt_right">61,172,283</td></tr>
    <tr><th scope="row" class="gt_row gt_left gt_stub">Personne seule</th>
<td class="gt_row gt_right">639</td>
<td class="gt_row gt_right">1,567,880</td>
<td class="gt_row gt_right">82,177</td>
<td class="gt_row gt_right">82,177</td>
<td class="gt_row gt_right">$59 757 455</td>
<td class="gt_row gt_right">$59 757 455</td>
<td class="gt_row gt_right">82,177</td>
<td class="gt_row gt_right">59,757,455</td></tr>
    <tr><td class="gt_row gt_left gt_stub gt_grand_summary_row gt_first_grand_summary_row gt_last_summary_row">Total</td>
<td class="gt_row gt_right gt_grand_summary_row gt_first_grand_summary_row gt_last_summary_row">2,003</td>
<td class="gt_row gt_right gt_grand_summary_row gt_first_grand_summary_row gt_last_summary_row">3,849,341</td>
<td class="gt_row gt_right gt_grand_summary_row gt_first_grand_summary_row gt_last_summary_row">239,124</td>
<td class="gt_row gt_right gt_grand_summary_row gt_first_grand_summary_row gt_last_summary_row">422,603</td>
<td class="gt_row gt_right gt_grand_summary_row gt_first_grand_summary_row gt_last_summary_row">383,567,206</td>
<td class="gt_row gt_right gt_grand_summary_row gt_first_grand_summary_row gt_last_summary_row">784,813,965</td>
<td class="gt_row gt_right gt_grand_summary_row gt_first_grand_summary_row gt_last_summary_row">330,864</td>
<td class="gt_row gt_right gt_grand_summary_row gt_first_grand_summary_row gt_last_summary_row">584,190,586</td></tr>
  </tbody>
  
  
</table>
</div>

En 2019, la taxe de Québec solidaire aurait permis de récolter entre 383M et 784M dans les 2 scénarios extrêmes, avec un chiffre de scénario mitoyen semi-réaliste de 584M.

# Scénario 2

Ok, mettons qu’on ne fait pas chier les gens avant 2 millions, ça fait quoi?

``` r
taxes2 <- function(x){
  case_when(
    x < 2e6 ~ 0,
    x < 10e6 ~   (x-2e6) *0.001,  # tops out at 8000
    x < 100e6  ~ 8000 + (x -10e6) * 0.01,  # tops out at 908000
    TRUE ~ 908000 + (x- 100e6) *0.015
  )
}
```

<div id="bsmzvsmkrg" style="overflow-x:auto;overflow-y:auto;width:1080px;height:auto;">
<style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#bsmzvsmkrg .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#bsmzvsmkrg .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#bsmzvsmkrg .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#bsmzvsmkrg .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 0;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#bsmzvsmkrg .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#bsmzvsmkrg .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#bsmzvsmkrg .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#bsmzvsmkrg .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#bsmzvsmkrg .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#bsmzvsmkrg .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#bsmzvsmkrg .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#bsmzvsmkrg .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
}

#bsmzvsmkrg .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#bsmzvsmkrg .gt_from_md > :first-child {
  margin-top: 0;
}

#bsmzvsmkrg .gt_from_md > :last-child {
  margin-bottom: 0;
}

#bsmzvsmkrg .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#bsmzvsmkrg .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}

#bsmzvsmkrg .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}

#bsmzvsmkrg .gt_row_group_first td {
  border-top-width: 2px;
}

#bsmzvsmkrg .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#bsmzvsmkrg .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#bsmzvsmkrg .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#bsmzvsmkrg .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#bsmzvsmkrg .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#bsmzvsmkrg .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#bsmzvsmkrg .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#bsmzvsmkrg .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#bsmzvsmkrg .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#bsmzvsmkrg .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-left: 4px;
  padding-right: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#bsmzvsmkrg .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#bsmzvsmkrg .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#bsmzvsmkrg .gt_left {
  text-align: left;
}

#bsmzvsmkrg .gt_center {
  text-align: center;
}

#bsmzvsmkrg .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#bsmzvsmkrg .gt_font_normal {
  font-weight: normal;
}

#bsmzvsmkrg .gt_font_bold {
  font-weight: bold;
}

#bsmzvsmkrg .gt_font_italic {
  font-style: italic;
}

#bsmzvsmkrg .gt_super {
  font-size: 65%;
}

#bsmzvsmkrg .gt_footnote_marks {
  font-style: italic;
  font-weight: normal;
  font-size: 75%;
  vertical-align: 0.4em;
}

#bsmzvsmkrg .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#bsmzvsmkrg .gt_indent_1 {
  text-indent: 5px;
}

#bsmzvsmkrg .gt_indent_2 {
  text-indent: 10px;
}

#bsmzvsmkrg .gt_indent_3 {
  text-indent: 15px;
}

#bsmzvsmkrg .gt_indent_4 {
  text-indent: 20px;
}

#bsmzvsmkrg .gt_indent_5 {
  text-indent: 25px;
}
</style>
<table class="gt_table">
  <caption>(#tab:scenario2)Données PUMF ESF Statcan pour le Québec 2019, calculs @coulsim</caption>
  <thead class="gt_header">
    <tr>
      <td colspan="9" class="gt_heading gt_title gt_font_normal gt_bottom_border" style>Taxe sur la richesse récoltée selon le type de ménage (scénario cut-off 2M$)</td>
    </tr>
    
  </thead>
  <thead class="gt_col_headings">
    <tr>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col"></th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col">Nombre d'observations</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col">Nombre pondéré de ménages</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col">Nombre de ménages taxés dans le scénario minimal</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col">Nombre de ménages taxés dans le scénario maximal</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col">Taxe totale perçue dans le scénario minimal</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col">Taxe totale perçue dans le scénario maximal</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col">Nombre de ménages taxés dans le scénario 50-50 </th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col">Taxe totale perçue dans le scénario 50-50</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><th scope="row" class="gt_row gt_left gt_stub">Non déclaré</th>
<td class="gt_row gt_right">63</td>
<td class="gt_row gt_right">66,791</td>
<td class="gt_row gt_right">31,591</td>
<td class="gt_row gt_right">34,918</td>
<td class="gt_row gt_right">$151 559 758</td>
<td class="gt_row gt_right">$467 570 456</td>
<td class="gt_row gt_right">33,254</td>
<td class="gt_row gt_right">309,565,107</td></tr>
    <tr><th scope="row" class="gt_row gt_left gt_stub">Autres types de famille</th>
<td class="gt_row gt_right">233</td>
<td class="gt_row gt_right">486,400</td>
<td class="gt_row gt_right">3,563</td>
<td class="gt_row gt_right">33,906</td>
<td class="gt_row gt_right">$2 333 038</td>
<td class="gt_row gt_right">$29 165 117</td>
<td class="gt_row gt_right">18,734</td>
<td class="gt_row gt_right">15,749,078</td></tr>
    <tr><th scope="row" class="gt_row gt_left gt_stub">Couple, avec des enfants et famille monoparentale</th>
<td class="gt_row gt_right">442</td>
<td class="gt_row gt_right">759,009</td>
<td class="gt_row gt_right">1,211</td>
<td class="gt_row gt_right">21,727</td>
<td class="gt_row gt_right">$1 202 293</td>
<td class="gt_row gt_right">$14 986 027</td>
<td class="gt_row gt_right">11,469</td>
<td class="gt_row gt_right">8,094,160</td></tr>
    <tr><th scope="row" class="gt_row gt_left gt_stub">Personne seule</th>
<td class="gt_row gt_right">639</td>
<td class="gt_row gt_right">1,567,880</td>
<td class="gt_row gt_right">21,712</td>
<td class="gt_row gt_right">21,712</td>
<td class="gt_row gt_right">$14 238 078</td>
<td class="gt_row gt_right">$14 238 078</td>
<td class="gt_row gt_right">21,712</td>
<td class="gt_row gt_right">14,238,078</td></tr>
    <tr><th scope="row" class="gt_row gt_left gt_stub">Couple, sans enfant</th>
<td class="gt_row gt_right">626</td>
<td class="gt_row gt_right">969,261</td>
<td class="gt_row gt_right">8,184</td>
<td class="gt_row gt_right">8,184</td>
<td class="gt_row gt_right">$8 339 843</td>
<td class="gt_row gt_right">$8 339 843</td>
<td class="gt_row gt_right">8,184</td>
<td class="gt_row gt_right">8,339,843</td></tr>
    <tr><td class="gt_row gt_left gt_stub gt_grand_summary_row gt_first_grand_summary_row gt_last_summary_row">Total</td>
<td class="gt_row gt_right gt_grand_summary_row gt_first_grand_summary_row gt_last_summary_row">2,003</td>
<td class="gt_row gt_right gt_grand_summary_row gt_first_grand_summary_row gt_last_summary_row">3,849,341</td>
<td class="gt_row gt_right gt_grand_summary_row gt_first_grand_summary_row gt_last_summary_row">66,260</td>
<td class="gt_row gt_right gt_grand_summary_row gt_first_grand_summary_row gt_last_summary_row">120,446</td>
<td class="gt_row gt_right gt_grand_summary_row gt_first_grand_summary_row gt_last_summary_row">177,673,010</td>
<td class="gt_row gt_right gt_grand_summary_row gt_first_grand_summary_row gt_last_summary_row">534,299,522</td>
<td class="gt_row gt_right gt_grand_summary_row gt_first_grand_summary_row gt_last_summary_row">93,353</td>
<td class="gt_row gt_right gt_grand_summary_row gt_first_grand_summary_row gt_last_summary_row">355,986,266</td></tr>
  </tbody>
  
  
</table>
</div>

Dans le scénario 50-50 du plan “cut-off à à 2 millions”, on collecterait 355M. C’est quand même 229M de moins (39%) que dans le scénario initial ( 584M).

Par contre, on fait chier 93 353 ménages au lieu de 330 864, une baisse de 71.7%

# Scenario 3

Ok, est-ce qu’on peut retrouver un montant similaire au 584M initial en augmentant le taux d’imposition entre 2M et 10 M à 0.2% au lieu de 0.1% ?

``` r
taxes3 <- function(x){
  case_when(
    x < 2e6 ~ 0,
    x < 10e6 ~   (x-2e6) *0.002,  # tops out at 16000
    x < 100e6  ~ 16000 + (x -10e6) * 0.01,  # tops out at 916000
    TRUE ~ 916000 + (x- 100e6) *0.015
  )
}
```

<div id="wlahaauwud" style="overflow-x:auto;overflow-y:auto;width:1080px;height:auto;">
<style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#wlahaauwud .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#wlahaauwud .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#wlahaauwud .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#wlahaauwud .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 0;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#wlahaauwud .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#wlahaauwud .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#wlahaauwud .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#wlahaauwud .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#wlahaauwud .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#wlahaauwud .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#wlahaauwud .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#wlahaauwud .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
}

#wlahaauwud .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#wlahaauwud .gt_from_md > :first-child {
  margin-top: 0;
}

#wlahaauwud .gt_from_md > :last-child {
  margin-bottom: 0;
}

#wlahaauwud .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#wlahaauwud .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}

#wlahaauwud .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}

#wlahaauwud .gt_row_group_first td {
  border-top-width: 2px;
}

#wlahaauwud .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#wlahaauwud .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#wlahaauwud .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#wlahaauwud .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#wlahaauwud .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#wlahaauwud .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#wlahaauwud .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#wlahaauwud .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#wlahaauwud .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#wlahaauwud .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-left: 4px;
  padding-right: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#wlahaauwud .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#wlahaauwud .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#wlahaauwud .gt_left {
  text-align: left;
}

#wlahaauwud .gt_center {
  text-align: center;
}

#wlahaauwud .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#wlahaauwud .gt_font_normal {
  font-weight: normal;
}

#wlahaauwud .gt_font_bold {
  font-weight: bold;
}

#wlahaauwud .gt_font_italic {
  font-style: italic;
}

#wlahaauwud .gt_super {
  font-size: 65%;
}

#wlahaauwud .gt_footnote_marks {
  font-style: italic;
  font-weight: normal;
  font-size: 75%;
  vertical-align: 0.4em;
}

#wlahaauwud .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#wlahaauwud .gt_indent_1 {
  text-indent: 5px;
}

#wlahaauwud .gt_indent_2 {
  text-indent: 10px;
}

#wlahaauwud .gt_indent_3 {
  text-indent: 15px;
}

#wlahaauwud .gt_indent_4 {
  text-indent: 20px;
}

#wlahaauwud .gt_indent_5 {
  text-indent: 25px;
}
</style>
<table class="gt_table">
  <caption>(#tab:scenario3)Données PUMF ESF Statcan pour le Québec 2019, calculs @coulsim</caption>
  <thead class="gt_header">
    <tr>
      <td colspan="9" class="gt_heading gt_title gt_font_normal gt_bottom_border" style>Taxe sur la richesse récoltée selon le type de ménage (scénario 3: cut-off 2M$, taux de 0.2% entre 2M et 10M)</td>
    </tr>
    
  </thead>
  <thead class="gt_col_headings">
    <tr>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col"></th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col">Nombre d'observations</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col">Nombre pondéré de ménages</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col">Nombre de ménages taxés dans le scénario minimal</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col">Nombre de ménages taxés dans le scénario maximal</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col">Taxe totale perçue dans le scénario minimal</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col">Taxe totale perçue dans le scénario maximal</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col">Nombre de ménages taxés dans le scénario 50-50</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col">Taxe totale perçue dans le scénario 50-50</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><th scope="row" class="gt_row gt_left gt_stub">Non déclaré</th>
<td class="gt_row gt_right">63</td>
<td class="gt_row gt_right">66,791</td>
<td class="gt_row gt_right">31,591</td>
<td class="gt_row gt_right">34,918</td>
<td class="gt_row gt_right">$303 119 517</td>
<td class="gt_row gt_right">$658 380 765</td>
<td class="gt_row gt_right">33,254</td>
<td class="gt_row gt_right">480,750,141</td></tr>
    <tr><th scope="row" class="gt_row gt_left gt_stub">Autres types de famille</th>
<td class="gt_row gt_right">233</td>
<td class="gt_row gt_right">486,400</td>
<td class="gt_row gt_right">3,563</td>
<td class="gt_row gt_right">33,906</td>
<td class="gt_row gt_right">$4 666 076</td>
<td class="gt_row gt_right">$58 330 235</td>
<td class="gt_row gt_right">18,734</td>
<td class="gt_row gt_right">31,498,155</td></tr>
    <tr><th scope="row" class="gt_row gt_left gt_stub">Couple, avec des enfants et famille monoparentale</th>
<td class="gt_row gt_right">442</td>
<td class="gt_row gt_right">759,009</td>
<td class="gt_row gt_right">1,211</td>
<td class="gt_row gt_right">21,727</td>
<td class="gt_row gt_right">$2 404 586</td>
<td class="gt_row gt_right">$29 972 054</td>
<td class="gt_row gt_right">11,469</td>
<td class="gt_row gt_right">16,188,320</td></tr>
    <tr><th scope="row" class="gt_row gt_left gt_stub">Personne seule</th>
<td class="gt_row gt_right">639</td>
<td class="gt_row gt_right">1,567,880</td>
<td class="gt_row gt_right">21,712</td>
<td class="gt_row gt_right">21,712</td>
<td class="gt_row gt_right">$28 476 156</td>
<td class="gt_row gt_right">$28 476 156</td>
<td class="gt_row gt_right">21,712</td>
<td class="gt_row gt_right">28,476,156</td></tr>
    <tr><th scope="row" class="gt_row gt_left gt_stub">Couple, sans enfant</th>
<td class="gt_row gt_right">626</td>
<td class="gt_row gt_right">969,261</td>
<td class="gt_row gt_right">8,184</td>
<td class="gt_row gt_right">8,184</td>
<td class="gt_row gt_right">$16 679 686</td>
<td class="gt_row gt_right">$16 679 686</td>
<td class="gt_row gt_right">8,184</td>
<td class="gt_row gt_right">16,679,686</td></tr>
    <tr><td class="gt_row gt_left gt_stub gt_grand_summary_row gt_first_grand_summary_row gt_last_summary_row">Total</td>
<td class="gt_row gt_right gt_grand_summary_row gt_first_grand_summary_row gt_last_summary_row">2,003</td>
<td class="gt_row gt_right gt_grand_summary_row gt_first_grand_summary_row gt_last_summary_row">3,849,341</td>
<td class="gt_row gt_right gt_grand_summary_row gt_first_grand_summary_row gt_last_summary_row">66,260</td>
<td class="gt_row gt_right gt_grand_summary_row gt_first_grand_summary_row gt_last_summary_row">120,446</td>
<td class="gt_row gt_right gt_grand_summary_row gt_first_grand_summary_row gt_last_summary_row">355,346,020</td>
<td class="gt_row gt_right gt_grand_summary_row gt_first_grand_summary_row gt_last_summary_row">791,838,896</td>
<td class="gt_row gt_right gt_grand_summary_row gt_first_grand_summary_row gt_last_summary_row">93,353</td>
<td class="gt_row gt_right gt_grand_summary_row gt_first_grand_summary_row gt_last_summary_row">573,592,458</td></tr>
  </tbody>
  
  
</table>
</div>

573M !
C’est pas mal proche du 584M initial, et ça embête seulement les gens doublement millionnaire en leur demande de payer 2000\$ par millions à partir du 2e (et 10 000\$ par million à partir du 10e)

# Conclusion

Les données du PUMF de l’Enquête sur la Sécurité Financière de 2019 nous permettent de savoir que la taxe sur la richesse aurait rapporté entre 383M et 784M en utilisant les règles énoncées par QS. Il s’agit de deux scénarios extrêmes, où l’on suppose que toutes les familles dans les catégorie “Non déclaré”, “Autres types de famille” et “Couple, avec des enfants et famille monoparentale” sont composé soit de personnes seules (scénario impôt maximal) ou de couples (scénario impôt minimal)

Un scénario mitoyen semi-réaliste où la moitié de ces ménages seraient composé de personnes seules et l’autre moitié de couple permettrait de récolter **584M** auprès de **330,864** des 3,849,341 ménages du Québec (8.59%).

Ce pourcentage est beaucoup plus élevé que ceux que nous avions vu hier quand j’avais trouvé 5.2% pour les personnes seules et de 6.8% pour les couples sans enfants. C’est parce qu’hier je ne m’étais pas intéressés aux familles où le nombre d’adultes était inconu. Dans les familles “non déclarés”, ce sont **64%** de 66 000 ménages qui paient dans le scénario 50-50. Pour les “autres types de familles ce sont **16.9%** de 486 400 ménages. Enfin, pour les ménages composés de”couples avec enfants et famille monoparentale”, si on suppose que la moitié ne comporte qu’un adulte, on arrive à 7.5% des 759 009 ménages. Ce dernier chiffre est probablement surestimé, car j’ai supposé 50% de familles monoparentales alors que la [réalité est plus proche de 29.5%](https://msss.gouv.qc.ca/professionnels/statistiques-donnees-sante-bien-etre/statistiques-de-sante-et-de-bien-etre-selon-le-sexe-volet-national/familles-monoparentales/)

Nous avons ensuite créé un deuxième ensemble de règles, le scénario \#2, où ce sont les 2 premiers millions qui seraient exonérés plutôt que seulement le premier. Sous cet ensemble de règles, on ne collectait que **355 millions** dans le scénario 50-50, une baisse de 229M (39%) par rapport à l’ensemble de règles initial. Par contre, on embêtait seulement **93 353 ménages** au lieu de 330 864, une baisse de 71.7%. Embêter 2.4% des ménages au lieu de 8.59% des ménages me parait plus raisonnable, mais il faudrait quand même retrouver ces 229 millions.

Nous avons donc créé un troisième ensemble de règles, le scénario \#3, où les 2 premiers millions sont exonérés mais où le taux de taxation sur l’avoir net est de 2000\$ par millions plutôt que de 1000\$ par million entre 2M et 10M. Sous cet ensemble de règles, on collecte alors **573 millions** auprès des mêmes **93 353 ménages** que dans scénario \#2.

Conclusion: le troisième ensemble de règle permettrait de récolter presque autant d’argent que celui proposé par QS (573M vs 584M) et on pourrait dire “We are the 97.5%ish” au lieu de “We are the 91.4%”
