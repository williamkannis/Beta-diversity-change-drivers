# Source code for *Drivers of multifaceted beta diversity change in invaded stream fish communities*

## Contact information and citation
Name:

Email:

OrcID:

Cite as:

## Analysis work flow
Description

### Prepare input data - perform on local machine
The below script 
* ```01_null_input_creation.R```

### Calculate observed diversity values - perform using HPC
The below shell scripts call in their corresponding R scripts to estimate observed beta diversity for the contemporary and native only species pools using one high performance computer nodes for each time step. Alpha diversity scripts estimate alpha diversity of only native species using one computer node.
* ```02_obs_tax_beta.sh``` - ```02_obs_tax_beta.R```
* ```03_obs_fun_beta.sh``` - ```03_obs_fun_beta.R```
*	```04_obs_fun_alpha.sh```
*	```05_obs_phy_alpha.sh```

### Calculate null divesiry values  - perform using HPC
The below shell scripts call in their corresponding R scripts to estimate
*	```06_null_fun_beta.sh```:
*	```07_null_phy_beta.sh```:
*	```08_null_fun_alpha.sh```:
* ```09_null_phy_alpha.sh```:

### Calculate effect sizes - perform using HPC
* 10_
* 11_batch_ses.sh

### Analysis scripts - perfom on local machine
* 12_
* 13_
* 14_
* 15_

### Helper functions
* ```null_model_algorithms.R```: Contains algorithms to randomize community, trait, or phylogenetic data for null model analysis
* ```diversity_batch_functions.R```: Contains functions that estimate multiple iterations of diversity metrics using parallel computation.
* ```effect_size_function.R```:


## Diversity Input Data
We are not able to publicly provide all the data necessary to replicate the multidimensional diversity data. The fish occurrence data used to estimate multidimensional diversity metrics were obtained through data sharing agreements with United States governmental agencies. While these raw data are not directly available from the authors for redistribution due to data sharing agreements, they can be accessed through formal requests to the agencies listed in Appendix 1. Individuals with completed data requests may contact the corresponding author for harmonized versions of the data. Phylogenetic data was obtained from a variety of publicly available datasets with citations found in Appendix 3. We provided a harmonized phylogenetic tree that contains all species in our community dataset. Trait data were obtained from public and private datasets and harmonized data cannot be shared without permission. Despite not being able to share all data, we provide R scripts used to harmonize the community, phylogenetic, and trait data used to estimate the multidimensional alpha and beta diversity values, which we do make publicly available.


### Community  data
Harmonized community data is avalable upon request after written approval from each data source in appendix 1 of manuscript. Community data should be stored: ```Diversity Input Data/```. While we cannot publicly share raw community data, we provide the list of species in the analysis for use in the trait and phylogenetic data preparation scripts.
* ```full_species_list.csv```: List of all species in the community data set before filtering, used for construction of phylogenetic super tree and compilation of trait data.
* ```filtered_species_list.csv```: List of all species in the community data set after filtering, used for to trim tree and compile trait data. 
* ```community_data_prep.R```: Compiles stream fish community data at the stream segment scale for the conterminous United States (US) and to filter data to only include comparable surveys based on sampling methods. This code also rarefies stream segments based on hydrological region to ensure consistent sampling densities across the study extent. Finally, stream segments are split into two species pools, a contemporary that includes all species records, and native only species pool, which represents communities before nonnative introductions. <ins>NOTE:</ins> Running this script requires data not publicly available without data requests.

### Phylogenetic data
* ```phylo_tree.rds```: Phylogenetic super tree created using the methods of [Castiglione et al.,  (2022)](https://doi.org/10.1111/pala.12588) and ```phylo_data_prep.R```. This tree includes all 815 species from the community dataset used in the analysis. This tree used the [Fish Tree of Life (Rabosky et al., 2018)](https://fishtreeoflife.org/) as a backbone (Contains ~89% of species) with phylogenetic information supplemented by [TimeTree (Kumar et al., 2022)](http://www.timetree.org/), and several genus specific trees found in Appendix 3. <ins>NOTE:</ins> Phylogenetic super trees are constructed from trees created with differing methodology and caution should be used when making evolutionary inferences with super trees. However they are adequate for capturing general phylogenetic relationships among species.
* ```phylo_data_prep.R```: Compiles phylogenetic data from multiple trees into a super tree that includes all 449 fish species in the analysis. This script loads in a compressive fish phylogeny from the [Fish Tree of Life](https://fishtreeoflife.org/), and uses downloaded data from [TimeTree](http://www.timetree.org/) and other publicly available datasets to fill in missing species. The output of this script was used to estimate missing trait values and to calculate phylogenetic beta diversity. <ins>NOTE:</ins> Running this script requires users to download all phylogenetic trees from their original data sources found in Appendix 3 of manuscript.

### Trait data
Raw trait data obtained from publicly available datasets and upon request should be stored ```Diversity Input Data/```.
* ```trait_data_prep.R```: Compile trait data for all 449 fish. This script uses trait data from two trait databases and fills in missing trait values based on phylogenetic relationships and literature review. The output of this script was used to calculate functional beta diversity. <ins>NOTE:</ins> Running this script requires users to download the publicly available data set from [Frimpong & Angermeier (2009)](https://www.sciencebase.gov/catalog/item/5a7c6e8ce4b00f54eb2318c0) and request the database from [Giam & Olden (2016)](https://doi.org/10.1111/geb.12475).
  

## HPC Input Data ```HPC_inputs```


## Diversity Output Data

### Observed values

### Null iterations

### SUmmarized

## RDA data

### predictor data
*
*

### Spatial data







