library(RNeo4j)
library(rvest)

source("jbkunst_pokemon.R")

link <- "http://pokemondb.net/type"

link_html <- read_html(link)

types <- link_html %>%
         html_nodes("table") %>%
         .[[1]] %>%
         html_table()

names(types)[1] <- "Type"
types$Type <- tolower(types$Type)
names(types)[2:ncol(types)] <- types$Type
types[is.na(types)] <- 1
types[types == ""] <- 1
types[types == "½"] <- 0.5

url <- "http://localhost:7474/db/data/"
username = "neo4j"
password = Sys.getenv("POKENEO_PASSWORD") 

graph = startGraph(url = url,
                   username = username,
                   password = password)
#Delete all nodes
#clear(graph)

addConstraint(graph, "Pokemon", "id")


pokenodes <- function(x) {
  pokemon <- getOrCreateNode(graph, "Pokemon", id = x["id"], name = x["pokemon"],
                                               height = x["height"], weight = x["weight"],
                                               type_1 = x["type_1"], type_2 = x["type_2"],
                                               attack = x["attack"], defense = x["defense"],
                                               hp = x["hp"], special_attack = x["special_attack"],
                                               special_defense = x["special_defense"], speed = x["speed"],
                                               url_image = x["url_image"])
}

apply(df,1,pokenodes)

