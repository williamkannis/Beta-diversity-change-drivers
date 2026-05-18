# Source code for *Drivers of multifaceted beta diversity change in invaded stream fish communities*

## Contact information and citation
Name:

Email:

OrcID:

Cite as:

## Analysis work flow

### Prepare input data - perform on local machine
* 01_null_input_creation.R: 

### Caclaute observed diversity values - perform using HPC
* 02_obs_tax_beta.sh:
* 03_obs_fun_beta.sh:
*	04_obs_fun_alpha.sh:
*	05_obs_phy_alpha.sh:

### Calculate null divesiry values  - perform using HPC
*	06_null_fun_beta.sh:
*	07_null_phy_beta.sh:
*	08_null_fun_alpha.sh:
*	09_null_phy_alpha.sh:

### Calculate effect sizes - perform using HPC
* 10_
* 11_batch_ses.sh

### Analysis scripts - perfom on local machine
* 12_
* 13_
* 14_
* 15_

### Helper functions
* Null model algorithms.R:
* diversity_batch_functions.R:
* effect_size_function.R:

# Input Data

Community data is avalable upon request after written approval from each data source. Trait data can be obatined BLANK. We provide raw alpha and beta diversity values which allow for users to replicate our analysis from script 10 and onward

## Communityy data
Descritpyion of how to obtian and where to store
* ```full_species_list.csv```: List of all species in the community data set before filtering, used for construction of phylogenetic super tree and compilation of trait data.
* ```filtered_species_list.csv```: List of all species in the community data set after filtering, used for to trim tree and compile trait data. 
* ```community_data_prep.R```: Compiles stream fish community data at the stream segment scale for the conterminous United States (US) and to filter data to only include comparable surveys based on sampling methods. This code also rarefies stream segments based on hydrological region to ensure consistent sampling densities across the study extent. Finally, stream segments are split into two species pools, a contemporary that includes all species records, and native only species pool, which represents communities before nonnative introductions. <ins>NOTE:</ins> Running this script requires data not publicly available without data requests.

## Phylogenetic data
* tree_file:
* ```phylo_data_prep.R```: Compiles phylogenetic data from multiple trees into a super tree that includes all 449 fish species in the analysis. This script loads in a compressive fish phylogeny from the [Fish Tree of Life](https://fishtreeoflife.org/), and uses downloaded data from [TimeTree](http://www.timetree.org/) and other publicly available datasets to fill in missing species. The output of this script was used to estimate missing trait values and to calculate phylogenetic beta diversity. <ins>NOTE:</ins> Running this script requires users to download all phylogenetic trees from their original data sources found in Appendix 3 of manuscript.

## Trait data
Descritpyion of how to obtian and where to store
* ```trait_data_prep.R```: Compile trait data for all 449 fish. This script uses trait data from two trait databases and fills in missing trait values based on phylogenetic relationships and literature review. The output of this script was used to calculate functional beta diversity. <ins>NOTE:</ins> Running this script requires users to download the publicly available data set from [Frimpong & Angermeier (2009)](https://www.sciencebase.gov/catalog/item/5a7c6e8ce4b00f54eb2318c0) and request the database from Giam & Olden (2016).
  

# Diversisty data

# RDA data

## predictor data
*
*

## Spatial data







