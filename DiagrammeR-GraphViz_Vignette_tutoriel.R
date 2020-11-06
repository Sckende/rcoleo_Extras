library(DiagrammeR)
library(dplyr)

#### Exemple 1 ####
nodes <- create_node_df(
  n = 7,
  label = 1:7,
  shape = "rectangle",
  data = c("Existence cellules", "Vignette cellules", "Existence sites", "Vignettes sites", "Existence campagnes", "Vignettes campagnes", "Observations")
)
nodes_decision <- create_node_df(
  n = 6,
  label = 1:6,
  shape = "circle",
  data = c(rep("oui",3),rep("non", 3))
)

all_nodes <- combine_ndfs(nodes, nodes_decision)

edges <- create_edge_df(
  from = c(1,1,11,2,3,3,12,4,5,5,13,6),
  to = c(8, 11,2,3,9,12,4,5,10,13,6,7)
)

graph <-
  create_graph(
    nodes_df = all_nodes,
    edges_df = edges
    )

render_graph(graph)




#### Exemple 2 ####

grViz("
      digraph boxes_and_circles{

# add node statements
      node [shape = box]
      Existence_cellules;
      Vignette_cellules;
      Existence_sites;
      Vignette_sites;
      Existence_campagnes;
      Vignette_campagnes;
      Observations

      node[shape = circle]
      oui1;
      oui2;
      oui3;
      non1;
      non2;
      non3;

# add edge statements
subgraph cluster_0 {
      Existence_cellules -> oui1;
      oui1 -> Existence_sites;
      Existence_sites -> oui2;
      oui2 -> Existence_campagnes;
      Existence_campagnes -> oui3;
      oui3 -> Observations;
}

      Existence_cellules -> non1
      #Existence_cellules -> non1 ;
      #non1 -> Vignette_cellules;
      # {Vignette_cellules oui1} -> Existence_sites ;
      # Existence_sites -> {oui2 non2};
      # non2 -> Vignette_sites ;
      # {Vignette_sites oui2} -> Existence_campagnes
      # Existence_campagnes -> {oui3 non3};
      # non3 -> Vignette_campagnes;
      # {Vignette_campagnes oui3} -> Observations;


# Vertical alignment of nodes
      Existence_cellules [group=g1]
      {rank = same; oui1 [group=g2]; non1 [group=g3]; Vignette_cellules [group=g4]}
      Existence_sites [group=g1]
      {rank = same; oui2 [group=g2]; non2 [group=g3]; Vignette_sites [group=g4]}
      Existence_campagnes [group=g1]
      {rank = same; oui3 [group=g2]; non3 [group=g3]; Vignette_campagnes [group=g4]}
      Observations [group=g1]


# edge[style=invis];
# Existence_cellules -> Existence_sites


}
      ")



#### Exemple 3 ####

# Create an NDF
nodes <-
  create_node_df(
    n = 4,
    nodes = c("a", "b", "c", "d"),
    label = FALSE,
    type = "lower",
    style = "filled",
    color = "aqua",
    shape = c("circle", "circle",
              "rectangle", "rectangle"),
    data = c(3.5, 2.6, 9.4, 2.7))


# Create an EDF
edges <-
  create_edge_df(
    from = c(1, 2, 3),
    to = c(4, 3, 1),
    rel = "leading_to",
    color = "aqua")
# Create the graph and include the`nodes` NDF & `edges` EDF
graph <-
  create_graph(
    nodes_df = nodes,
    edges_df = edges)

render_graph(graph)

#### Exemple 4 ####
grViz("digraph{

      graph[rankdir = LR]

      node[shape = rectangle, style = filled]

      node[fillcolor = Coral, margin = 0.2]
      A[label = 'Figure 1: Map']
      B[label = 'Figure 2: Metrics']

      node[fillcolor = Cyan, margin = 0.2]
      C[label = 'Figures.Rmd']

      node[fillcolor = Violet, margin = 0.2]
      D[label = 'Analysis_1.R']
      E[label = 'Analysis_2.R']

      subgraph cluster_0 {
      graph[shape = rectangle]
      style = rounded
      bgcolor = Gold

      label = 'Data Source 1'
      node[shape = rectangle, fillcolor = LemonChiffon, margin = 0.25]
      F[label = 'my_dataframe_1.csv']
      G[label = 'my_dataframe_2.csv']
      }

      subgraph cluster_1 {
      graph[shape = rectangle]
      style = rounded
      bgcolor = Gold

      label = 'Data Source 2'
      node[shape = rectangle, fillcolor = LemonChiffon, margin = 0.25]
      H[label = 'my_dataframe_3.csv']
      I[label = 'my_dataframe_4.csv']
      }

      edge[color = black, arrowhead = vee, arrowsize = 1.25]
      C -> {A B}
      D -> C
      E -> C
      F -> D
      G -> D
      H -> E
      I -> E

      }")

#### Exemple 5 ####
grViz("digraph{

      subgraph cluster_0 {
      graph[shape = rectangle]
      style = rounded
      color = white

      node[shape = rectangle]
      A
      B
      C

      node[shape = circle]
      D
      E
      F
      }

      subgraph cluster_1 {
      graph[shape = rectangle, rankdir = LR]

      node[shape = rectangle]
      H

      node[shape = circle]
      J
      }

      subgraph cluster_2 {
      graph[shape = rectangle]

      node[shape = rectangle]
      I

      node[shape = circle]
      K
      }

      edge[color = black]
      A ->D
D->B
B->F
F->C
C->E

A -> J
J->H

B->K
K->I

H->B
I->C

      {rank=same;J; H}
      {rank=same;K; I}

      }")
