##########################################
#  Phylogenetic super tree construction  #
#   by Anonymized                        #
##########################################

# This script creates a phylogenetic supertree using the Fish Tree of Life (Rabosky et al. 2018)
# as a backbone, containing around 89% of species in community dataset. Missing
# species were added based on relationships from other, smaller, genus specific trees
# from various sources (see appendix 3). The final tree is formatted so tip label
# match up with species names in community and trait datasets.

# House Keeping
rm(list=ls())

# Load Packages
library(fishtree)
library(stringr)
library(dplyr)
library(ape)
library(picante)
library(RRphylo)


#Load Species names from community data
species_names <- read.csv("full_species_list.csv")[,1]
species_names <- species_names[order(species_names)]  # order by name

### Phylo Data ###----
tree_b <- fishtree::fishtree_phylogeny(type = "chronogram")  # load in phylo tree from fish tree of life (Rabosky et al. 2018)

# Format tip labels
tree_b$tip.label <- gsub("_"," ", tree_b$tip.label)  # format tip labels to match species list
tree_tips_b <- tree_b$tip.label  # create a vector of tip labels


### Fill in missing species ####
# Many species in the tree are seperated into suspecies and this is causing a mismatch
# Coarsen these to species level
subspecies <-  tree_b$tip.label[str_detect( tree_b$tip.label,"^[a-zA-Z]*\\s[a-zA-Z]*\\s[a-zA-Z]*$") == T]  # pull out subspecies names (3 word names)
subspecies_df <- data.frame(subspecies,
                            revised = word(subspecies,1,2)) # make data frame with species name for each subspecies
subspecies_df <- subspecies_df[!duplicated(subspecies_df$revised),]  # only keep one subspecies for each species

for (i in 1:nrow(subspecies_df)){  # for loop to replace subspecies name with species name
  tree_b$tip.label[tree_b$tip.label == subspecies_df[i,1]] <- subspecies_df[i,2]
}
tree_b <- drop.tip(tree_b,subspecies)  # remove duplicate subspecies names so only one remains

# Many records are due to a spelling differences between the two list. Update misspelled
# tip labels to match community dataset
tree_b$tip.label[tree_b$tip.label == "Cichlasoma urophthalmum"] <- "Cichlasoma urophthalmus"
tree_b$tip.label[tree_b$tip.label ==  "Etheostoma chlorosomum"] <- "Etheostoma chlorosoma"
tree_b$tip.label[tree_b$tip.label == "Etheostoma mediae"] <- "Etheostoma meadiae"
tree_b$tip.label[tree_b$tip.label == "Etheostoma microlepidus"] <- "Etheostoma microlepidum"
tree_b$tip.label[tree_b$tip.label ==  "Moxostoma duquesnii"] <- "Moxostoma duquesnei"
tree_tips_b <- tree_b$tip.label  #update tip label list

# Pull up species that are truly missing. not due to spelling or subspecies issues
miss_fish <- species_names[!species_names %in% tree_tips_b]

### Merge in available trees ####
# Merge specie specific trees to main tree. This is the ideal method for adding 
# truly missing species. IF trees cannot be find, see remaining species section
# at bottom of script

# Trim tree to keep processing time down
# species_names_construction <- species_names
species_names_construction <- c(species_names, "Campostoma pullum","Catostomus bernardini",
                               "Cottus paulus","Catostomus cahita" ,"Coregonus nigripinnis", 
                               "Ctenogobius sagittula","Elassoma boehlkei", "Etheostoma bison",
                               "Etheostoma chermocki", "Etheostoma saludae", "Evorthodus minutus", 
                               "Hypostomus boulengeri", "Hypostomus brevis", 
                               "Microgobius microlepis", "Moxostoma hubbsi","Neogobius fluviatilis", 
                               "Neogobius pallasi", "Poecilia wingei","Menidia peninsulae")  # add species not in dataset but needed to bind missing species to tree
tree_backbone_data <- keep.tip(tree_b, species_names_construction[species_names_construction %in% tree_b$tip.label])
tree_backbone_data$node.label <- 1:tree_backbone_data$Nnode
tree_backbone_data_og <-tree_backbone_data


### Catostomidae: Catostomus and Moxostoma (Bagleey et al. 2018) ####

tree_catostomidae <- ape::read.tree()  # load in tree from Bagleey et al. 2018

# Format to match dataset
tree_catostomidae$tip.label[tree_catostomidae$tip.label == "C_fumeventris1"] <- "Catostomus fumeiventris"  # !! Needs to be added to tree!!
tree_catostomidae$tip.label[tree_catostomidae$tip.label == "C_latipinnis_MSB49601"] <- "Catostomus latipinnis"
tree_catostomidae$tip.label[tree_catostomidae$tip.label == "M_spcf_poe_UAIC12746_13_1"] <- "Moxostoma sp. Apalachicola Redhorse"
tree_catostomidae$tip.label[tree_catostomidae$tip.label == "M_spcf_lachneri_UAIC12462_03"] <- "Moxostoma sp. Brassy Jumprock"
tree_catostomidae$tip.label[tree_catostomidae$tip.label == "M_spcf_macro_UAIC11643_01_1"] <- "Moxostoma sp. Sicklefin Redhorse"


# # Check to see if tree contains all species in dataset
# # names are no in easy format to  fix. Unsure if all species are in tree
# species_names[word(species_names,1) %in% c("Catostomus","Moxostoma")]
# # This is a complex tree that doesn't quiet match up, should try and replace whole
# # tree in the backbone
# cat_names <- tree_backbone_data$tip.label[word(tree_backbone_data$tip.label,1) %in% c("Catostomus","Moxostoma",
#                                                                                       "Carpiodes","Ictiobus",
#                                                                                       "Cycleptus","Misgurnus","Cyprinus",
#                                                                                       "Hypophthalmichthys")]
# tree_backbone_cat <- keep.tip(tree_backbone_data,cat_names)
# 
# 
# # label nodes to easier determine node ages
# tree_catostomidae$node.label <- 1:tree_catostomidae$Nnode
# tree_backbone_cat$node.label <- 1:tree_backbone_cat$Nnode
# 
# # Plot trees
# par(mfrow=c(1,2))
# plot.phylo(tree_catostomidae, show.node.label = T,use.edge.length = T, cex = .6)
# plot.phylo(tree_backbone_cat, show.node.label = T,use.edge.length = T)
# 
# # FInd tip and node ages
# tree.age(tree_catostomidae)
# tree.age(tree_backbone_cat)

# Merge trees
data <- data.frame(bind = c("Catostomus fumeiventris",  # DW - let tree.merge assign age
                            "Catostomus latipinnis",  #  W
                            "Moxostoma sp. Apalachicola Redhorse",  # DW - let tree.merger define age
                            "Moxostoma sp. Brassy Jumprock",  # DW - let tree.merger define age
                            "Moxostoma sp. Sicklefin Redhorse"),  # DW - let tree.merger define age
                   reference = c("Catostomus tahoensis-Catostomus columbianus",
                                 "Catostomus bernardini-Catostomus cahita",
                                 "Moxostoma congestum",
                                 "Moxostoma hubbsi",
                                 "Moxostoma pisolabrum-Moxostoma macrolepidotum"),  # potion of tips
                   poly = c(F,
                            F,
                            F,
                            F,
                            F))  # is polytomy?
# nod.age <- c("Catostomus fumeiventris-Catostomus tahoensis" = 8.314, #65-8.314 #14-4.416 #13-6.776
#              "Catostomus latipinnis-Catostomus bernardini" = 4.765,  #44-4.765 #8-0.585 #7-6.931
#              "Moxostoma sp. Apalachicola Redhorse-Moxostoma congestum" = 6.935,  #84-6.935 #29-3.699
#              "Moxostoma sp. Brassy Jumprock-Moxostoma hubbsi" = 5.765,  #92 - 5.765 #30 - 5.674 or #87 8.189 #35 0.188  #34 3.957
#              "Moxostoma sp. Sicklefin Redhorse-Moxostoma macrolepidotum" = 4.958)  # #90-4.958 #32-0.188 #31-3.957

nod.age <- c("Catostomus latipinnis-Catostomus bernardini" = 4.765)  


tree_backbone_data <- tree.merger(tree_backbone_data, data, tree_catostomidae, node.ages = nod.age)  # merge trees

### Chrosomus (TimeTree) ####

# Load in genera specific tree
tree_chrosomus <- ape::read.tree()  # load in Catostomidae tree from Timetree

# # Check to see if tree contains all species in dataset
# species_names[word(species_names,1) == "Chrosomus"]
# # all species in dataset are in new tree, so it might be
# # better to replace whole genus
# chroso_names <- tree_backbone_data$tip.label[word(tree_backbone_data$tip.label,1) %in% c("Chrosomus")]
# tree_backbone_chroso <- keep.tip(tree_backbone_data, chroso_names)
# # label nodes to easier determine node ages
# tree_chrosomus$node.label <- 1:tree_chrosomus$Nnode
# tree_backbone_chroso$node.label <- 1:tree_backbone_chroso$Nnode
# 
# # Plot trees
# par(mfrow=c(2,1))
# plot.phylo(tree_chrosomus, show.node.label = T,use.edge.length = F)
# plot.phylo(tree_backbone_chroso, show.node.label = T,use.edge.length = F)
# 
# # FInd tip and node ages
# tree.age(tree_chrosomus)
# tree.age(tree_backbone_chroso)

# Merge trees
data <- data.frame(bind = c("Chrosomus neogaeus"),  # name of tips being added
                   reference = c("Chrosomus eos-Chrosomus tennesseensis"),  # postion of tips
                   poly = c(F))  # is polytomy?
nod.age <- c("Chrosomus neogaeus-Chrosomus eos" = 17.944)  #1-17.944 #1-17.448. works!

tree_backbone_data <- tree.merger(tree_backbone_data, data, tree_chrosomus, node.ages = nod.age)  # merge trees

### Coregonus (TimeTree) ####

# Load in genera specfic tree
tree_coregonus <- ape::read.tree()  # load in Coregonus tree from TimeTree

# # Check to see if tree contains all species in dataset
# species_names[word(species_names,1) == "Coregonus"]
# # all species in dataset are in new tree, so it might be
# # better to replace whole genus
# core_names <- tree_backbone_data$tip.label[word(tree_backbone_data$tip.label,1) %in% c("Coregonus")]#, #"Prosopium","Lepomis")]
# tree_backbone_core <- keep.tip(tree_backbone_data, core_names)
# # label nodes to easier determine node ages
# tree_coregonus$node.label <- 1:tree_coregonus$Nnode
# tree_backbone_core$node.label <- 1:tree_backbone_core$Nnode
# 
# # Plot trees
# par(mfrow=c(1,2))
# plot.phylo(tree_coregonus, show.node.label = T,use.edge.length = F)
# plot.phylo(tree_backbone_core, show.node.label = T,use.edge.length = F)
# 
# # FInd tip and node ages
# tree.age(tree_coregonus)
# tree.age(tree_backbone_core)

# Merge trees
data <- data.frame(bind = c("Coregonus artedi"),  # name of tips being added
                   reference = c("Coregonus nigripinnis"),  # postion of tips
                   poly = c(F))  # is polytomy?
# Coregonus nigripinnis is not in dataset and will need to be included in the 
# backbone to merge
nod.age <- c("Coregonus artedi-Coregonus nigripinnis" = 0.272)  # #26-0.272 #23-0.093

tree_backbone_data <- tree.merger(tree_backbone_data, data, tree_coregonus, node.ages = nod.age)  # merge trees

### Elassoma (Sandel et al. 2014) ####
# Tree not time calibrated, treemerger chooses node ages

# Load in genera specific tree
tree_elasomma <- ape::read.tree()  # load in tree from Sandel et al. 2014
tree_elasomma$tip.label[tree_elasomma$tip.label == "'Elassoma_okatie_8AF'"] <- "Elassoma okatie"  # change labels to match dataset

# # Check to see if tree contains all species in dataset
# species_names[word(species_names,1) == "Elassoma"]

# e_names <- tree_backbone_data$tip.label[word(tree_backbone_data$tip.label,1) %in% c("Elassoma")]
# tree_backbone_e <- keep.tip(tree_backbone_data, e_names)
# 
# # label nodes to easier determine node ages
# tree_backbone_e$node.label <- 1:tree_backbone_e$Nnode
# tree_elasomma$node.label <- 1:tree_elasomma$Nnode
# 
# # Plot trees
# par(mfrow=c(2,1))
# plot.phylo(tree_backbone_e,show.node.label = T, use.edge.length = F)
# plot.phylo(tree_elasomma,show.node.label = T, use.edge.length = F)

# Merge trees
data <- data.frame(bind = c("Elassoma okatie"),  # name of tips being added
                   reference = c("Elassoma boehlkei"),  # postion of tips
                   poly = c(F))
tree_backbone_data <- tree.merger(tree_backbone_data, data, tree_elasomma)


### Erimyzon (Hunt et al. 2021) ####

# Load in genera specfic tree
tree_erimyzon <- ape::read.nexus()  # load in tree from Hunt et al., 2021
tree_erimyzon$tip.label[tree_erimyzon$tip.label == "E.claviformis2AL"] <- "Erimyzon claviformis"  # change tip labels to match dataset

# # Check to see if tree contains all species in dataset
# species_names[word(species_names,1) == "Erimyzon"]
# # all species in dataset are in new tree, so it might be
# # better to replace whole genus
# eri_names <- tree_backbone_data$tip.label[word(tree_backbone_data$tip.label,1) %in% c("Erimyzon")]
# tree_backbone_eri <- keep.tip(tree_backbone_data, eri_names)
# # label nodes to easier determine node ages
# tree_erimyzon$node.label <- 1:tree_erimyzon$Nnode
# tree_backbone_eri$node.label <- 1:tree_backbone_eri$Nnode
# 
# # Plot trees
# par(mfrow=c(1,2))
# plot.phylo(tree_erimyzon, show.node.label = T,use.edge.length = T)
# plot.phylo(tree_backbone_eri, show.node.label = T,use.edge.length = T)
# 
# # FInd tip and node ages
# tree.age(tree_erimyzon)
# tree.age(tree_backbone_eri)

# Merge trees
data <- data.frame(bind = c("Erimyzon claviformis"),  # name of tips being added
                   reference = c("Erimyzon sucetta"),  # postion of tips
                   poly = c(F))  # is polytomy?

nod.age <- c("Erimyzon claviformis-Erimyzon sucetta" = 4)  # age of nodes as derived from tree.age function. THese seem off. find out scale of ages. it seems multipling by 1000 fixes this. need to see if thisis ok. this publication has other trees available in more compatible time scales
tree_backbone_data <- tree.merger(tree_backbone_data, data, tree_erimyzon, node.ages = nod.age)  # merge trees

### Etheostoma (Near et al. 2011) ####
# Tree not time calibrated, treemerger chooses node ages

# Load in genera specfic tree
tree_etheostoma <- ape::read.nexus()  # load in tree from Near et al. 2011

# change tip labels to match dataset
tree_etheostoma$tip.label[tree_etheostoma$tip.label == "Etheostoma_atripinne_A"] <- "Etheostoma atripinne"
tree_etheostoma$tip.label[tree_etheostoma$tip.label == "Etheostoma_gutselli_A"] <- "Etheostoma gutselli"
tree_etheostoma$tip.label[tree_etheostoma$tip.label == "Etheostoma_cf_stigmaeum_bgdA"] <- "Etheostoma jimmycarter"
tree_etheostoma$tip.label[tree_etheostoma$tip.label == "Etheostoma_trisella_A"] <- "Etheostoma trisella"
tree_etheostoma$tip.label[tree_etheostoma$tip.label == "Etheostoma_cf_zonistium_C"] <- "Etheostoma sp. Blueface Darter"
tree_etheostoma$tip.label[tree_etheostoma$tip.label == "Etheostoma_cf_spectabile_mamA"] <- "Etheostoma sp. Mamequit Darter"
tree_etheostoma$tip.label[tree_etheostoma$tip.label == "Etheostoma_cf_bellator_A"] <- "Etheostoma sp. Sipsey Darter"  #not sure which one is the sipsey (a,b, or c). Doenst matter for this, refer to pub for placement
tree_etheostoma$tip.label[tree_etheostoma$tip.label == "Etheostoma_cf_stigmaeum_higlandA"] <- "Etheostoma teddyroosevelt"
tree_etheostoma$tip.label[tree_etheostoma$tip.label == "Etheostoma_cf_oophylax_AF"] <- "Etheostoma sp. Clarks Darter"

# # Check to see if tree contains all species in dataset
# etho_species <- species_names[word(species_names,1) == "Etheostoma"]  # extract speceis from dataset
# etho_tips <- ifelse(lengths(strsplit(tree_etheostoma$tip.label, '_')) ==4, # change format of species name to match dataset
#                     word(gsub("_"," " ,tree_etheostoma$tip.label),1,3),  # provisional species
#                     word(gsub("_"," " ,tree_etheostoma$tip.label),1,2))  # traditional species names
# etho_species[!etho_species %in% etho_tips]  # see which species are missing from tree
# # does not contain all species in dataset and backbone trees. Whole genus cannot
# # be easily swaped
# 
# etho_names <- tree_backbone_data$tip.label[word(tree_backbone_data$tip.label,1) %in% c("Etheostoma")]
# tree_backbone_etho <- keep.tip(tree_backbone_data, etho_names)
# 
# # label nodes to easier determine node ages
# tree_etheostoma$node.label <- 1:tree_etheostoma$Nnode
# tree_backbone_etho$node.label <- 1:tree_backbone_etho$Nnode
# 
# # Plot trees
# par(mfrow=c(2,1))
# plot.phylo(tree_etheostoma, show.node.label = T,use.edge.length = F, cex = .4)
# plot.phylo(tree_backbone_etho, show.node.label = T,use.edge.length = F, cex = .4)
# 
# # FInd tip and node ages
# tree.age(tree_etheostoma)
# tree.age(tree_backbone_etho)

# Merge trees
data <- data.frame(bind = c("Etheostoma atripinne", #
                            "Etheostoma gutselli", #
                            "Etheostoma jimmycarter",  #
                            "Etheostoma trisella",  #
                            "Etheostoma sp. Blueface Darter", #
                            "Etheostoma sp. Mamequit Darter", #
                            "Etheostoma sp. Sipsey Darter",
                            "Etheostoma teddyroosevelt",
                            "Etheostoma sp. Clarks Darter"),  #
                   reference = c("Etheostoma simoterum",
                                 "Etheostoma blennioides",
                                 "Etheostoma jessiae",
                                 "Etheostoma saludae-Etheostoma hopkinsi",
                                 "Etheostoma zonistium-Etheostoma cervus",
                                 "Etheostoma bison",
                                 "Etheostoma bellator-Etheostoma chermocki",
                                 "Etheostoma jimmycarter",
                                 "Etheostoma chienense"),
                   poly = c(F,
                            F,
                            F,
                            F,
                            F,
                            F,
                            F,
                            F,
                            F))  # is polytomy?


# nod.age <- c("Etheostoma atripinne" =,
#              "Etheostoma gutselli" =,
#              "Etheostoma jimmycarter" =,
#              "Etheostoma trisella" =,  
#              "Etheostoma sp. Blueface Darter" =,
#              "Etheostoma sp. Mamequit Darter" =,
#              "Etheostoma sp. Sipsey Darter" =)  # age of nodes as derived from tree.age function. 
# a <- tree.merger(tree_backbone_etho, data, tree_etheostoma, node.ages = nod.age)  # merge trees
tree_backbone_data <- tree.merger(tree_backbone_data, data, tree_etheostoma)

### Gobiiformes: Ctenogobius, Gobioides, Microgobius, and Neogobius (TimeTree) ####

# Load in genera specfic tree
tree_gobiiformes <- ape::read.tree()  # load inGobiformes tree from TimeTree

# Format to match dataset
tree_gobiiformes$tip.label <- gsub("_", " ", tree_gobiiformes$tip.label)
tree_gobiiformes$tip.label[tree_gobiiformes$tip.label == "Gobioides broussonnetii"] <- "Gobioides broussonetii"

# # Check to see if tree contains all species in dataset
# gobi_species <- species_names[word(species_names,1) %in% c("Ctenogobius", "Gobioides", "Microgobius", "Neogobius")]  # extract all species in dataset
# gobi_species[!gobi_species %in% tree_gobiiformes$tip.label]
# # all species in dataset are in new tree, so it might be
# # better to replace whole genus
# gobi_names <- tree_backbone_data$tip.label[word(tree_backbone_data$tip.label,1) %in% c("Ctenogobius", "Gobioides", "Microgobius", "Neogobius","Evorthodus")]
# tree_backbone_gobi <- keep.tip(tree_backbone_data, gobi_names)
# # label nodes to easier determine node ages
# tree_gobiiformes$node.label <- 1:tree_gobiiformes$Nnode
# tree_backbone_gobi$node.label <- 1:tree_backbone_gobi$Nnode
# 
# # Plot trees
# par(mfrow=c(1,2))
# plot.phylo(tree_gobiiformes, show.node.label = T,use.edge.length = F)
# plot.phylo(tree_backbone_gobi, show.node.label = T,use.edge.length = F)
# 
# # FInd tip and node ages
# tree.age(tree_gobiiformes)
# tree.age(tree_backbone_gobi)

# Merge trees
data <- data.frame(bind = c("Ctenogobius shufeldti",
                            "Gobioides broussonetii",
                            "Neogobius melanostomus",
                            "Microgobius gulosus"),  # name of tips being added
                   reference = c("Ctenogobius sagittula-Ctenogobius boleosoma",
                                 "Evorthodus minutus",
                                 "Neogobius fluviatilis-Neogobius pallasi",
                                 "Microgobius microlepis"),  # postion of tips
                   poly = c(T,
                            F,
                            F,
                            F))  # is polytomy?
nod.age <- c("Ctenogobius shufeldti-Ctenogobius sagittula" = 18.964, #18.96 #6-18.964  # use age of orginal tree to preserve structure of tree
             "Gobioides broussonetii-Evorthodus minutus" = 29.20, #29.20 #4-42.424
             "Neogobius melanostomus-Neogobius fluviatilis" = 12.34,  #12.34 # #2-55.819 #3-8.404
             "Microgobius gulosus-Microgobius microlepis" = 11.98)  #11.98 #2-55.819
tree_backbone_data <- tree.merger(tree_backbone_data, data, tree_gobiiformes, node.ages = nod.age)  # merge trees

### Hypostomus (TimeTree) ####

# Load in genera specfic tree
tree_hypostomus <- ape::read.tree()  # load in Hypostomus tree from TimeTree

# Format to match dataset
tree_hypostomus$tip.label <- gsub("_", " ", tree_hypostomus$tip.label)

# # Check to see if tree contains all species in dataset
# hypostomus_species <- species_names[word(species_names,1) == "Hypostomus"]  # extract all species in dataset
# hypostomus_species[!hypostomus_species %in% tree_hypostomus$tip.label]
# # only one species in genus, might not make sense to replace whole genus
# hypo_names <- tree_backbone_data$tip.label[word(tree_backbone_data$tip.label,1) %in% c("Hypostomus","Pterygoplichthys")]
# tree_backbone_hypo <- keep.tip(tree_backbone_data, hypo_names)
# # Trim tree
# tree_hypostomus <- keep.tip(tree_hypostomus, c(tree_backbone_hypo$tip.label[tree_backbone_hypo$tip.label %in% tree_hypostomus$tip.label],
#                                                "Hypostomus plecostomus"))
# 
# # label nodes to easier determine node ages
# tree_hypostomus$node.label <- 1:tree_hypostomus$Nnode
# tree_backbone_hypo$node.label <- 1:tree_backbone_hypo$Nnode
# 
# # Plot trees
# par(mfrow=c(1,2))
# plot.phylo(tree_hypostomus, show.node.label = T,use.edge.length = F)
# plot.phylo(tree_backbone_hypo, show.node.label = T,use.edge.length = F)
# 
# # FInd tip and node ages
# tree.age(tree_hypostomus)
# tree.age(tree_backbone_hypo)

# Merge trees
data <- data.frame(bind = c("Hypostomus plecostomus"),  # name of tips being added
                   reference = c("Hypostomus boulengeri-Hypostomus brevis"),  # postion of tips
                   poly = c(F))  # is polytomy?
nod.age <- c("Hypostomus plecostomus-Hypostomus brevis" = 4.269)  # #3-4.269 #1-10.955 #3-3.371
tree_backbone_data <- tree.merger(tree_backbone_data, data, tree_hypostomus, node.ages = nod.age)  # merge trees

### Labidesthes (Bloom et al. 2013) ####
# Load in genera specfic tree
tree_labi <- ape::read.nexus()  # load in tree from Bloom et al. 2013

# Format to match dataset
# load in naming key
tree_labi$tip.label[tree_labi$tip.label == "Lsvan3844"] <- "Labidesthes vanhyningi"  # replace abrv with full name

# # Check to see if tree contains all species in dataset
# lepomis_species <- species_names[word(species_names,1) == "Lepomis"]  # extract all species in dataset
# micropterus_species[!micropterus_species %in% tree_micropterus$tip.label]
# # need to check still
# 
# labi_names <- tree_backbone_data$tip.label[word(tree_backbone_data$tip.label, 1) %in% c("Labidesthes","Menidia")]
# tree_backbone_labi <- keep.tip(tree_backbone_data,labi_names)
# 
# # label nodes to easier determine node ages
# tree_labi$node.label <- 1:tree_labi$Nnode
# tree_backbone_labi$node.label <- 1:tree_backbone_labi$Nnode
# 
# # Plot trees
# par(mfrow=c(1,2))
# plot.phylo(tree_labi, show.node.label = T,use.edge.length = T)
# plot.phylo(tree_backbone_labi, show.node.label = T,use.edge.length = T)
# 
# # FInd tip and node ages
# tree.age(tree_labi)
# tree.age(tree_backbone_labi)

# Use  Tree from Bloom et al. 2009 to add missing tips
data <- data.frame(bind = c("Labidesthes vanhyningi"),  # name of tips being added
                   reference = c("Labidesthes sicculus"),  # postion of tips
                   poly = c(F))  # is polytomy?
node.age <- c("Labidesthes vanhyningi-Labidesthes sicculus" = 5.667)  # #29-5.667 #1-37.44
tree_backbone_data <- tree.merger(tree_backbone_data, data, tree_labi, node.ages = node.age)  # merge trees

### Lepidomeda (TimeTree) ####

# Load in genera specfic tree
tree_lepidomeda <- ape::read.tree()  # load in Lepidomeda tree from TimeTree

# Format to match dataset
tree_lepidomeda$tip.label <- gsub("_", " ", tree_lepidomeda$tip.label)

# # Check to see if tree contains all species in dataset
# lepidomeda_species <- species_names[word(species_names,1) == "Lepidomeda"]  # extract all species in dataset
# lepidomeda_species[!lepidomeda_species %in% tree_lepidomeda$tip.label]
# # only one species in genus, might not make sense to replace whole genus
# lepidomeda_names <- tree_backbone_data$tip.label[word(tree_backbone_data$tip.label,1) %in% c("Lepidomeda")]
# tree_backbone_lepidomeda <- keep.tip(tree_b, lepidomeda_names)
# 
# # label nodes to easier determine node ages
# tree_lepidomeda$node.label <- 1:tree_lepidomeda$Nnode
# tree_backbone_lepidomeda$node.label <- 1:tree_backbone_lepidomeda$Nnode
#
# # Plot trees
# par(mfrow=c(1,2))
# plot.phylo(tree_lepidomeda, show.node.label = T,use.edge.length = F)
# plot.phylo(tree_backbone_lepidomeda, show.node.label = T,use.edge.length = F)
# 
# # FInd tip and node ages
# tree.age(tree_lepidomeda)
# tree.age(tree_backbone_lepidomeda)

# Merge trees
data <- data.frame(bind = c("Lepidomeda copei"),  # name of tips being added
                   reference = c("Lepidomeda vittata"),  # postion of tips
                   poly = c(F))  # is polytomy?
nod.age <- c("Lepidomeda copei-Lepidomeda vittata" = 11.33)  # check to see if this changes things? It works!
tree_backbone_data <- tree.merger(tree_backbone_data, data, tree_lepidomeda, node.ages = nod.age)  # merge trees

### Leptolucania (TimeTree) ####

# Load in genera specfic tree
tree_leptolucania <- ape::read.tree()  # Load in Leptolucania tree from TimeTree

# Format to match dataset
tree_leptolucania$tip.label <- gsub("_", " ", tree_leptolucania$tip.label)

# # Check to see if tree contains all species in dataset
# fun_names <- species_names[word(species_names,1) %in% c("Lucania","Fundulus","Leptolucania")]  # extract all species in dataset
# tree_leptolucania$tip.label[!fun_names %in% tree_leptolucania$tip.label]
# # only one species in genus, might not make sense to replace whole genus
# lepto_names <- tree_backbone_data$tip.label[word(tree_backbone_data$tip.label, 1) %in% c("Lucania","Fundulus","Jordanella","Cyprinodon")]
# tree_backbone_lepto <- keep.tip(tree_backbone_data,lepto_names)
# # label nodes to easier determine node ages
# tree_leptolucania$node.label <- 1:tree_leptolucania$Nnode
# tree_backbone_lepto$node.label <- 1:tree_backbone_lepto$Nnode
# 
# # Plot trees
# par(mfrow=c(1,2))
# plot.phylo(tree_leptolucania, show.node.label = T,use.edge.length = F)
# plot.phylo(tree_backbone_lepto, show.node.label = T,use.edge.length = F)

# # FInd tip and node ages
# tree.age(tree_leptolucania)
# tree.age(tree_backbone_lepto)

# Merge trees
data <- data.frame(bind = c( "Leptolucania ommata"),  # name of tips being added
                   reference = c("Lucania parva-Fundulus heteroclitus"),  # postion of tips
                   poly = c(F))  # is polytomy?
# nod.age <- c("Leptolucania ommata-Fundulus lima" = 21.8)  # Node age doesnt mach up, let tree.merger give age
nod.age <- c("Leptolucania ommata-Lucania parva" = 30)  # Node age tree.merger gave was way to old. Use 30, this is the earliest age you can give it wiotuth messing up tree
tree_backbone_data <- tree.merger(tree_backbone_data, data, tree_leptolucania, node.ages = nod.age)  # merge trees

### Lepomis (Kim et al. 2022) ####
# Use Tree from Kim et al. 2022 to add missing tips
# Load in genera specfic tree
tree_lepomis <- ape::read.nexus()  # Load in tree from Kim et al. 2022

# Format to match dataset
 # load in naming key
tree_lepomis$tip.label[tree_lepomis$tip.label == "PEL"] <- "Lepomis peltastes"  # replace abrv with full name

# # Check to see if tree contains all species in dataset
# lepomis_species <- species_names[word(species_names,1) == "Lepomis"]  # extract all species in dataset
# micropterus_species[!micropterus_species %in% tree_micropterus$tip.label]
# Contains all species in dataset would befit from replacing the whole tree down the road
# 
# lepomis_names <- tree_backbone_data$tip.label[word(tree_backbone_data$tip.label, 1) == "Lepomis"]
# tree_backbone_lep <- keep.tip(tree_backbone_data,lepomis_names)
# 
# # label nodes to easier determine node ages
# tree_lepomis$node.label <- 1:tree_lepomis$Nnode
# tree_backbone_lep$node.label <- 1:tree_backbone_lep$Nnode
# 
# # Plot trees
# par(mfrow=c(1,2))
# plot.phylo(tree_lepomis, show.node.label = T,use.edge.length = T)
# plot.phylo(tree_backbone_lep, show.node.label = T,use.edge.length = T)
# 
# # FInd tip and node ages
# tree.age(tree_lepomis)
# tree.age(tree_backbone_lep)

data <- data.frame(bind = c("Lepomis peltastes"),  # name of tips being added
                   reference = c("Lepomis megalotis"),  # postion of tips
                   poly = c(F))  # is polytomy?
nod.age <- c("Lepomis peltastes-Lepomis megalotis" = 2.869)  # #5- 2.869  #8-4.123

tree_backbone_data <- tree.merger(tree_backbone_data, data, tree_lepomis, node.ages = nod.age)  # merge trees


### Macrhybopsis (Hoagstrom and echelle 2022) ####

# Load in genera specfic tree
tree_macrhy <- ape::read.nexus()  # load in tree from Hoagstrom and echelle 2022


# Format to match dataset
tree_macrhy$tip.label[tree_macrhy$tip.label == "G1_Mbosch"] <- "Macrhybopsis boschungi"  # replace abrv with full name
tree_macrhy$tip.label[tree_macrhy$tip.label == "H1_Metnier"] <- "Macrhybopsis etnieri"
tree_macrhy$tip.label[tree_macrhy$tip.label == "F1_Mpall"] <- "Macrhybopsis pallida"
tree_macrhy$tip.label[tree_macrhy$tip.label == "X_MhyoTet"] <- "Macrhybopsis tetranema"

# # Check to see if tree contains all species in dataset
# micropterus_species <- species_names[word(species_names,1) == "Micropterus"]  # extract all species in dataset
# micropterus_species[!micropterus_species %in% tree_micropterus$tip.label]
# # Contains all species in dataset would befit from replacing the whole tree down the road
# 
# macrhy_names <- tree_backbone_data$tip.label[word(tree_backbone_data$tip.label, 1) == "Macrhybopsis"]
# tree_backbone_macrhy <- keep.tip(tree_backbone_data,macrhy_names)
# 
# # label nodes to easier determine node ages
# tree_macrhy$node.label <- 1:tree_macrhy$Nnode
# tree_backbone_macrhy$node.label <- 1:tree_backbone_macrhy$Nnode
# 
# # Plot trees
# par(mfrow=c(1,2))
# plot.phylo(tree_macrhy, show.node.label = T,use.edge.length = T)
# plot.phylo(tree_backbone_macrhy, show.node.label = T,use.edge.length = T)
# 
# # FInd tip and node ages
# tree.age(tree_macrhy)
# tree.age(tree_backbone_macrhy)

# Use  Tree from Hoagstrom and Echelle (2022) to add missing tips
data <- data.frame(bind = c("Macrhybopsis etnieri-Macrhybopsis pallida",
                            "Macrhybopsis tetranema"),  
                   reference = c("Macrhybopsis gelida-Macrhybopsis aestivalis",
                                 "Macrhybopsis gelida"),  # postion of tips
                   poly = c(F,
                            F))  # is polytomy?
node.age <- c("Macrhybopsis pallida-Macrhybopsis gelida" = 10.148,  #  #9-10.148 #2-3.941 #1-24.505 
              "Macrhybopsis tetranema-Macrhybopsis gelida" = 3.112)  #13-3.112 #2-3.941

tree_backbone_data <- tree.merger(tree_backbone_data, data, tree_macrhy, node.ages = node.age)  # merge trees

### Micropterus (Kim et al. 2022) ####

# Load in genera specfic tree.  
tree_micropterus <- ape::read.nexus()  # load in tree from Kim et al., 2022


# Format to match dataset
micro_names <- read.csv(paste(tree_dir,"Micropterus_kim_et_al_2022_metadata/micropterus_kim_et_al_2022_names.csv", sep = ""))  # load in naming key
tree_micropterus$tip.label <- micro_names$Specimen[match(tree_micropterus$tip.label,micro_names$SVDQuartets.taxon)]  # replace abrv with full name

# # Check to see if tree contains all species in dataset
# micropterus_species <- species_names[word(species_names,1) == "Micropterus"]  # extract all species in dataset
# micropterus_species[!micropterus_species %in% tree_micropterus$tip.label]
# # Contains all species in dataset would befit from replacing the whole tree down the road
# 
# micropt_names <- tree_backbone_data$tip.label[word(tree_backbone_data$tip.label, 1) %in% c("Micropterus","Lepomis")]
# tree_backbone_micro <- keep.tip(tree_backbone_data,micropt_names)
# 
# # label nodes to easier determine node ages
# tree_micropterus$node.label <- 1:tree_micropterus$Nnode
# tree_backbone_micro$node.label <- 1:tree_backbone_micro$Nnode
# 
# # Plot trees
# par(mfrow=c(1,2))
# plot.phylo(tree_micropterus, show.node.label = T,use.edge.length = T)
# plot.phylo(tree_backbone_micro, show.node.label = T,use.edge.length = T)
# 
# # FInd tip and node ages
# tree.age(tree_micropterus)
# tree.age(tree_backbone_micro)

# Replacing entire genus seems to be the best way to preserve the overall tree timing
data <- data.frame(bind = c("Micropterus sp. Altamaha Bass-Micropterus nigricans"),  # name of tips being added
                   reference = c("Micropterus notius"),  # postion of tips
                   poly = c(F))  # is polytomy?
nod.age <- c("Micropterus sp. Altamaha Bass-Micropterus notius" = 7.386)  # #1-7.386 #1-31.781

tree_backbone_data <- tree.merger(tree_backbone_data, data, tree_micropterus,node.ages = nod.age)

# # Check tree
# tree.age(tree_backbone_data1)  # check tip and node ages
# plot.phylo(tree_backbone_data1)  # plit tree


### Poeciliinae (TimeTree) ####

# Load in genera specfic tree
tree_poecil <- ape::read.tree()  # load in Poeciliinae tree from TimeTree

# Format to match dataset
tree_poecil$tip.label <- gsub("_", " ", tree_poecil$tip.label)

# # Check to see if tree contains all species in dataset
# poecil_species <- species_names[word(species_names,1) %in% c("Heterandria","Poeciliopsis",
#                                            "Gambusia", "Poecilia")]  # extract all species in dataset
# poecil_species[!poecil_species %in% tree_poecil$tip.label]
# # all species are present
# # only one species in genus, might not make sense to replace whole genus
# poecil_names <- tree_backbone_data$tip.label[word(tree_backbone_data$tip.label, 1) == "Poecilia"]
# tree_backbone_poecil <- keep.tip(tree_backbone_data,poecil_names)
# # label nodes to easier determine node ages
# tree_poecil$node.label <- 1:tree_poecil$Nnode
# tree_backbone_poecil$node.label <- 1:tree_backbone_poecil$Nnode
# 
# # Plot trees
# par(mfrow=c(1,2))
# plot.phylo(tree_poecil, show.node.label = T,use.edge.length = F,cex = .6)
# plot.phylo(tree_backbone_poecil,show.node.label = T,use.edge.length = F)
# 
# # FInd tip and node ages
# tree.age(tree_poecil)
# tree.age(tree_backbone_poecil)

# Merge trees
data <- data.frame(bind = c("Poecilia formosa"),  # name of tips being added
                   reference = c("Poecilia reticulata-Poecilia wingei"),  # postion of tips
                   poly = c(F))  # is polytomy?
nod.age <- c("Poecilia formosa-Poecilia reticulata" = 9.34)  # #2-3.838 #1-26.084
tree_backbone_data <- tree.merger(tree_backbone_data, data, tree_poecil, node.ages = nod.age)  # merge trees


### Pogonichthyinae: Erimonax, Notropis, and Pteronotropis (TimeTree) ####

# Do not assign ages and let tree merger assign them a spot that preserves tree
# Load in genera specfic tree
tree_pogo <- ape::read.tree()  # load in Pogonichthyinae tree from TimeTree
tree_pogo$tip.label <- gsub("_", " ", tree_pogo$tip.label)

# # Check to see if tree contains all species in dataset
# pogo_species <-species_names[word(species_names,1) == "Erimonax" | word(species_names,1) == "Notropis" |
#                                word(species_names,1) == "Pteronotropis"]
# pogo_species[!pogo_species %in% tree_pogo$tip.label]
# # All Erimonax species are contained in the tree. Pteronotropis species in dataset
# # and backbone tree are in the tree. But one species is missing from both trees.
# # Notropis is missing some species from the new tree that are in backbone and dataset
# # Only pteronotropis and Erimonax genus can be fully replaced.
# pogo_genus <- unique(word(tree_pogo$tip.label,1)[word(tree_pogo$tip.label,1) %in% word(species_names,1)])
# pogo_names <- tree_backbone_data$tip.label[word(tree_backbone_data$tip.label,1) %in% pogo_genus]
# tree_backbone_pogo <- keep.tip(tree_backbone_data,pogo_names)
# 
# 
# 
# # label nodes to easier determine node ages
# tree_pogo$node.label <- 1:tree_pogo$Nnode
# tree_backbone_pogo$node.label <- 1:tree_backbone_pogo$Nnode
# 
# # Plot trees
# par(mfrow=c(1,2))
# plot.phylo(tree_pogo, show.node.label = T,use.edge.length = F, cex=.6)
# plot.phylo(tree_backbone_pogo, show.node.label = T,use.edge.length = F)
# 
# # FInd tip and node ages
# tree.age(tree_pogo)
# tree.age(tree_backbone_pogo)

# Merge trees
data <- data.frame(bind = c("Erimonax monachus",  # W
                            "Notropis alborus",  # W
                            "Notropis atrocaudalis", # DW. Pushes nodes below down. may be ok
                            "Notropis bairdi",  # W
                            "Notropis braytoni",  # W
                            "Notropis cummingsae",  # W
                            "Notropis greenei",  # DW  Pushes nodes below down. may be ok
                            "Notropis melanostomus",  # DW  Pushes nodes below down. may be ok
                            "Notropis scabriceps",  # W
                            "Pteronotropis merlini"),  # W For some reason this changes every node in the tree, no mater what age you give it when poly=T. But can set as false and use nod ages to create polytomy
                   reference = c("Pimephales promelas-Pimephales vigilax",  # trees differ slightly and this isnt exactly like timetree but maintains shape and ages best
                                 "Notropis procne",
                                 "Hybopsis hypsinotus-Luxilus zonistius",  
                                 "Notropis blennius-Notropis potteri",
                                 "Notropis bairdi-Notropis blennius",
                                 "Notropis altipinnis",
                                 "Lythrurus fasciolaris-Luxilus zonistius",  # 
                                 "Notropis nubilus-Notropis mekistocholas",
                                 "Notropis greenei",
                                 "Pteronotropis metallicus-Pteronotropis euryzonus"),
                   poly = c(F,
                            F,
                            F,# is polytomy?
                            F,
                            T,
                            F,
                            F,
                            F,
                            F,
                            F))  # is tech a polynomy, but this cause whole tree to hange. By putting this as false and setting the node correctly, this will be poltomy
nod.age <- c("Erimonax monachus-Pimephales promelas" = 20.85,  #  #-20.85  #37 - 22.176 #38-17.931  works
             "Notropis alborus-Notropis procne" = 8.77,  # #-8.77 #84-11.519 works!
             #"Notropis atrocaudalis-Hybopsis hypsinotus" = 19.01,  #  #-19.01  #117-24.514 #12-25.604  Deactivate this so tree merger places this node in a spot that doesnt change time
             "Notropis bairdi-Notropis potteri" = 10.63,  # #-10.63 #51-3.394  #50-12.084 works!
             "Notropis braytoni-Notropis bairdi" = 10.63,  # #51-3.394  #50-12.084 works!
             "Notropis cummingsae-Notropis altipinnis" = 9.94,  # #-9.94 #138-23.683 works!
             #"Notropis greenei-Luxilus zonistius" = 21.57,  #  #12-25.192 #11-26.071  #10-26.979 Deactivate this so tree merger places this node in a spot that doesnt change time 
             #"Notropis melanostomus-Notropis nubilus" = 9.51,  # #-9.51 #67-11.901 #64-15.809. Deactivate this so tree merger places this node in a spot that doesnt change time
             "Notropis scabriceps-Notropis greenei" = 19.07,  # #-19.07
             "Pteronotropis merlini-Pteronotropis metallicus" = 6.233)  #  #-6.23  #132-6.233 #131-22.727 D works. Using the same node age from backbone will make this a polytomy while preserving backbone ages

tree_backbone_data <- tree.merger(tree_backbone_data, data, tree_pogo, node.ages = nod.age)  # merge trees

### Cyprinids: Campostoma and Notropis (Hollingsworth et al 2013) (done) ####

# Load in genera specfic tree
tree_cyprinids <- ape::read.tree()  # load in tree from Hollingsworth et al 2013

# Format to match dataset
tree_cyprinids$tip.label <- gsub("_", " ", tree_cyprinids$tip.label)
tree_cyprinids$tip.label[word(tree_cyprinids$tip.label,1) == "Campostoma"];species_names[word(species_names,1) == "Campostoma"]
tree_cyprinids$tip.label[tree_cyprinids$tip.label == "Campostoma sapadiceum"] <- "Campostoma spadiceum"


# # Check to see if tree contains all species in dataset
# species_names[word(species_names,1) == "Leptolucania"]  # extract all species in dataset
# 
# # only one species in genus, might not make sense to replace whole genus
# cyp_genus <- unique(word(tree_cyprinids$tip.label,1)[word(tree_cyprinids$tip.label,1) %in% word(species_names,1)])
# cyp_names <- tree_backbone_data$tip.label[word(tree_backbone_data$tip.label,1) %in% cyp_genus]
# tree_backbone_cyp <- keep.tip(tree_backbone_data,cyp_names)
# # label nodes to easier determine node ages
# tree_cyprinids$node.label <- 1:tree_cyprinids$Nnode
# tree_backbone_cyp$node.label <- 1:tree_backbone_cyp$Nnode
# 
# # Tree is large so trim to find node ages
# tree_cyprinids_camp <- keep.tip(tree_cyprinids,tree_cyprinids$tip.label[word(tree_cyprinids$tip.label,1)=="Campostoma"])
# tree_cyprinids_notr <- keep.tip(tree_cyprinids,tree_cyprinids$tip.label[word(tree_cyprinids$tip.label,1)=="Notropis"])
# 
# 
# # Plot trees
# par(mfrow=c(1,2))
# plot.phylo(tree_cyprinids, show.node.label = T,use.edge.length = F,cex = .6)
# plot.phylo(tree_backbone_cyp, show.node.label = T,use.edge.length = F)
# 
# # FInd tip and node ages
# tree.age(tree_cyprinids)
# tree.age(tree_backbone_cyp)

# Merge trees
data <- data.frame(bind = c("Campostoma spadiceum-Campostoma pauciradii",
                            "Notropis amplamala"),  # name of tips being added
                   reference = c("Nocomis asper-Nocomis raneyi",
                                 "Notropis buccatus"),  # postion of tips
                   poly = c(F,
                            F))  # is polytomy?
nod.age <- c("Campostoma spadiceum-Nocomis raneyi" = 32.608, # 195-30.542 156-32.608. Add entire genus to tree. The way i did this it is correct to use the age of the node in backbone. as I'm replacing everthing below it
             "Notropis amplamala-Notropis buccatus" =11.616)  # #52-11.616 #106-20.465 works
tree_backbone_data <- tree.merger(tree_backbone_data, data, tree_cyprinids, node.ages = nod.age)  # merge trees

### Unavailable trees ####
# Species from trees that are not acquired can be added using tree.merger but
# will not have control of node ages. This can only be used to add ind tips not
# full genus.
# For these trees in manuscripts show relationships and these species will be added
### Cottus (Kiniger et al 2005) ####

# Use graphical Tree from Kiniger et al. 2005 to add missing tips
data <- data.frame(bind = c("Cottus kanawhae",
                            "Cottus sp. Bluestone Sculpin",
                            "Cottus sp. Checkered Sculpin",
                            "Cottus sp. Clinch Sculpin",
                            "Cottus sp. Holston Sculpin"),  # name of tips being added
                   reference = c("Cottus baileyi-Cottus carolinae",
                                 "Cottus kanawhae",
                                 "Cottus girardi",
                                 "Cottus baileyi-Cottus paulus",
                                 "Cottus carolinae"),  # postion of tips
                   poly = c(F,
                            F,
                            F,
                            T,
                            F))  # is polytomy?

tree_backbone_data <- tree.merger(tree_backbone_data, data, node.ages = nod.age)  # merge trees

### Etheostoma (Laymen and Mayden 2012)####

# Use graphical Tree from Laymen and Mayden 2012 to add missing tips
data <- data.frame(bind = c("Etheostoma gore"),  # name of tips being added
                   reference = c("Etheostoma jimmycarter-Etheostoma teddyroosevelt"),  # position of tips
                   poly = c(F))  # is polytomy?

tree_backbone_data <- tree.merger(tree_backbone_data, data)  # merge trees

### Notropis (Hollingsworth et al 2013) ####

# Use graphical Tree from Hollingsworth et al. (2013) to add missing tips.
data <- data.frame(bind = c("Notropis sp. Sawfin Shiner"),  # name of tips being added
                   reference = c("Notropis spectrunculus"),  # postion of tips
                   poly = c(F))  # is polytomy?

tree_backbone_data <- tree.merger(tree_backbone_data, data)  # merge trees

### Pteronotropis (Mayden and Allen 2015) ####

# Use graphical Tree from Mayden and Allen (2015) to add missing tips
data <- data.frame(bind = c("Pteronotropis stonei"),  # name of tips being added
                   reference = c("Pteronotropis metallicus"),  # postion of tips
                   poly = c(F))  # is polytomy?

tree_backbone_data <- tree.merger(tree_backbone_data, data)  # merge trees

### Cyprinella (Schonhuth and Mayden 2010) ####

# Use graphical Tree from Schonhuth and Mayden (2010) to add missing tips
data <- data.frame(bind = c("Cyprinella sp. Thinlip Chub"),  # name of tips being added
                   reference = c("Cyprinella zanema"),  # postion of tips
                   poly = c(F))  # is polytomy?

tree_backbone_data <- tree.merger(tree_backbone_data, data)  # merge trees


#### No trees Found ####
# Some species were not included in any phylogenetic analyses that I was able to 
# retrieve. These species were often provisional, newly described, or rare species.
# These species were added as sisters to closest related species based on research.
# These will be divided into Provisional Species and Described Species

### Provisional Species ####
# If a provisional species does not have phylogenetic information, it will be assigned
# as a sister species to the species it is described after. For example: Clinostomus sp. cf. funduloides
# would be added as a sister to Clinostomus funduloides.
data <- data.frame(bind = c("Clinostomus sp. Smoky Dace",  # Clinostomus sp. cf. funduloides
                            "Cottus sp. Colorado River Sculpin",  # Young et al. 2022 called this similar to Cottus beldingii
                            "Cottus sp. Columbia Slimy Sculpin",  # Cottus sp. cf. cognatus
                            "Cottus sp. Rocky Mountain Sculpin",  # Cottus sp. cf. bairdii
                            "Moxostoma sp. Carolina Redhorse",  # Moxostoma sp. cf. erythrurum
                            "Notropis sp. Kanawha Rosyface Shiner",  # Notropis sp. Cf. rubellus
                            "Notropis sp. Piedmont Shiner",  # Notropis sp. Cf. chlorocephalus
                            "Noturus sp. Highlands Stonecat"),  # Noturus sp. cf. flavus
                   reference = c("Clinostomus funduloides",
                                 "Cottus beldingii",
                                 "Cottus cognatus",
                                 "Cottus bairdii",
                                 "Moxostoma erythrurum",
                                 "Notropis rubellus",
                                 "Notropis chlorocephalus",
                                 "Noturus flavus"),  
                   poly = c(F,
                            F,
                            F,
                            F,
                            F,
                            F,
                            F,
                            F))  # is polytomy?

tree_backbone_data <- tree.merger(tree_backbone_data, data)
# plot(tree_backbone_data1)

### Described Species (done) ####
# described species that do not have phylogenetic data fit into the following 
# groups: former subspecies, new species, and rare species. In the case of former
# subspecies these are assigned as sisters to their former subspecies. Rare and new
# new species are added as sisters to closest related species based on literature

data <- data.frame(bind = c("Catostomus utawana",  # was formerly considered part of Catostomus commersonii. (Morse and Daniels 2009)
                            "Cottus immaculatus",  # was once part of Cottus hypselurus (Kinziger and Wood 2010)
                            "Macrhybopsis australis",  # sister species to Macrhybopsis tetranema   (Underwood et al. 2003; Eisenhour 2004).
                            "Margariscus nachtriebi",  # genus has only two species, add sister to other conger Margariscus margarita  
                            "Menidia audens",  # There is a debate if this is part of Menidia beryllina or its own speceis (Fluker et al. 2011; Suttkus et al 2005)
                            "Notropis albizonatus",  # A member of the Notropis procne species group (Warren et al. 1994) has likely relatedness. Not much else on this species
                            "Notropis buccula",  # Orginally a subspecies of (Lee et al. 1980; Robins et al. 1991; Page and Burr 1991, 2011).
                            "Oncorhynchus aguabonita"),  # debated as subspecies of Oncorhynchus mykiss
                   reference = c("Catostomus commersonii",
                                 "Cottus hypselurus",
                                 "Macrhybopsis tetranema",  # this species is added to backbone in Machybopsis tree
                                 "Margariscus margarita",
                                 "Menidia beryllina",
                                 "Notropis procne",
                                 "Notropis bairdi",  # added in Pogonichthyinae tree
                                 "Oncorhynchus mykiss"), 
                   poly = c(F,
                            F,
                            F,
                            F,
                            F,
                            F,
                            F,
                            F))



tree_backbone_data <- tree.merger(tree_backbone_data,data)
# plot(tree_backbone_data)


#### Lampreys ####
# Lamorey species are contained in a time tree from time tree. Fish tree of life
# back bone only contains boney fish, so this tree will need to be added to the
# lamprey tree
# Load in genera specific tree
tree_lamp <- ape::read.tree()  # load in lamprey tree from TimeTree

# Format name to match dataset
tree_lamp$tip.label <- gsub("_", " ", tree_lamp$tip.label)
tree_lamp$tip.label[tree_lamp$tip.label == "Lampetra appendix"] <- "Lethenteron appendix"  # same fish just named different between datasets
tree_lamp$tip.label[tree_lamp$tip.label == "Entosphenus hubbsi"] <- "Lampetra hubbsi"  # same fish just named different between datasets

# Check to see if tree contains all species in dataset
lamp_names <- species_names[word(species_names,1) %in% c("Ichthyomyzon", "Lampetra",
                                                         "Lethenteron", "Petromyzon")]
lamp_names[!lamp_names %in% tree_lamp$tip.label]
# all species in dataset are in new tree

# Plot trees
par(mfrow=c(2,1))
plot.phylo(tree_lamp, show.node.label = T,use.edge.length = F)
plot.phylo(tree_backbone_data, show.node.label = F,use.edge.length = F, cex = .4)

# Merge trees
data <- data.frame(bind = c("Polyodon spathula-Gambusia affinis"),  # name of tips being added
                   reference = c("Mesomyzon mengae-Mordacia mordax"),  # position of tips
                   poly = c(F))  # is polytomy?
nod.age <- c("Mesomyzon mengae-Polyodon spathula" = 563.4)  # age of nodes as derived from timetree
tree_final <- tree.merger(tree_lamp, data,tree_backbone_data , node.ages = nod.age)

plot(tree_final)

### Export tree  ###----
tree_trim <- keep.tip(tree_final, species_names) # retain only species from dataset
ape::write.nexus(tree_trim,"phylo_tree.nex")  # export as nex file
saveRDS(tree_trim,"phylo_tree.rds")  # export as rds file






