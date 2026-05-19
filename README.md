# Source code for *Drivers of multifaceted beta diversity change in invaded stream fish communities*

## Contact information and citation

```bash
Name:

Email:

OrcID:
```
Cite as:
> CITE

## Null model work flow
HERE WE PROVIDE A GENERAL WORKFLOW FOR ESTIMATING NULL MODEL STANDARDIZATED BETA,LCBD, AND ALPHA DIVERSITY, WHICH WE USED TO CREATE THE DIVERSTIY VALUES USED IN OUR ANALYSIS. WE PROVIDE ADDITIONAL CODE AND WORKFLOW INFORMATION REGARDING THE FILTERING AND FROMATING OF THE DIVEISTY INPUT DATA (I.E., COMMUNITY, TRAIT, PHYLONGETY) IN THE APPOROIRATE SECTION. THIS IS PROVIDED FOR REPLICATION PURPOSES AND IS NOT INTENDED TO BE USED AS A GUIDE DUE TO THE WIDE RANGE IN DATA FORMATS

### Create file directories
To store to store diversity input data (e.g. community, trait, phylogeny), formatted high performance computation input data, and the resulting diversity outputs, users will need to create the below file directory. and upload the entire ```HPC_data``` directory to the high performance cluster storage.

```bash
├── Diversity Input Data
│   ├── mod_com_diversity_input.rds
│   ├── his_com_diversity_input.rds
│   ├── trait_diversity_input.rds
│   ├── phylo_tree.rds
├── HPC_data
    ├── beta_null_input_data
    │   ├── tax
    │   ├── fun
    │   ├── phy
    ├── alpha_null_input
    │   ├── fun
    │   ├── phy
    │── beta_obs_input_data
    │── null_out
    └── obs_out
```
Place community data for both species pools (contemporary and native), trait data, and phylongetic trees in ```Diversity Input Data``` with the following names: 
* ```mod_com_diversity_input.rds```: Community data for contemporary species pool. Dataframe or matrix with rows for sites and columns for species. Can contain an optional column ```HUC_12``` which represent regions and can be used to define regional species pools.
* ```his_com_diversity_input.rds```: Community data for native-only species pool. Same structure as ```mod_com_diversity_input.rds```
* ```trait_diversity_input.rds```: Trait data for all species in community data. Dataframe or matrix with rows for species and columns for traits.
* ```phylo_tree.rds```: Phylogenetic tree for all species in community data

Leave ```HPC_data``` folders empty, outputs from subsequent scripts will populate these folders

<ins>NOTE:</ins> We cannot provide raw community or trait data used in the manuscript without completed data requests, but we do provide the phylogenetic tree and scripts used to format and filter the trait and community data. See [Diversity Input Data](#diversity-input-data) for more information

### Prepare input data - perform on local machine
To best take advantage of high performance computation, we need to format our data in a manner that allows for parallel processing of diversity metrics. As we need to estimate 999 null iterations of each diversity metric and species pool (native only and contemporary), we want to prepare input data that can run simultaneously. For beta diversity null models, we need to generate 999 shuffled trait matrices and phylogenetic trees. For native alpha diversity, we need to generate 999 random community matrices. A benefit to HPC is that processes can be ran on a high number of cores among multiple computer nodes. To take advantage of HPC, we need to divide the list of null traits, trees, and/or communities into chunks based on CPU and memory limits per each node. These chunk can be ran on separate computer nodes. This reduces memory requirements within nodes and allows for better queue times. 

The following script imports ```mod_com_diversity_input.rds```, ```his_com_diversity_input.rds```, ```trait_diversity_input.rds```, and ```phylo_tree.rds```. These data are then used to create reduced functional space using PCoA and trims trees to fit community data. Both observed and null input data lists for alpha and beta diversity are then created and divided into chunks to run on separate HPC nodes.
* ```01_null_input_creation.R```

After running the above script, upload the entire ```HPC_data``` directory to the high performance cluster storage.

<ins>NOTE:</ins> This script only contains code to shuffle communities using taxa-swap and a regionally-constrained taxa-swap null model algorithms, which are ran using functions called from ```null_model_algorithms.R```. While the algorithms provided were best suited for functional and phylogenetic beta diversity, they may not be suited for all null model purposes. Users should research the best model for their usage and modify ```01_null_input_creation.R``` and ```null_model_algorithms.R``` accordingly.


### Calculate observed diversity values - perform using HPC
The below shell scripts call in their corresponding R scripts to estimate observed beta diversity for the contemporary and native only species pools using one high performance computer nodes for each time step. Alpha diversity scripts estimate alpha diversity of only native species using one computer node.
* ```02_obs_tax_beta.sh``` - ```02_obs_tax_beta.R```
* ```03_obs_fun_beta.sh``` - ```03_obs_fun_beta.R```
* ```04_obs_phy_beta.sh``` -```04_obs_phy_beta.R```
*	```05_obs_fun_alpha.sh``` - ```05_obs_fun_alpha.R```
*	```06_obs_phy_alpha.sh``` - ```06_obs_phy_alpha.R```


### Calculate null diversity values  - perform using HPC
The below shell scripts call in their corresponding R scripts to estimate null iterations of beta diversity for the contemporary and native only species pools. Due to the high memory usage of kernel density functional beta diversity metrics, we were only able to estimate 2 iterations (2 cores) and 18gb of ram per computer node for a total of 2000 high performance nodes. For phylogenetic beta diversity, we were able to estimate 37 iterations simultaneous per computer node using 45gb of ram per node for a total of 6 high performance nodes. For alpha diversity metrics, we estimated only null iterations for the native species pool and this required less than half the resources of beta diversity null models. 

*	```07_null_fun_beta.sh``` - ```07_null_fun_beta.R```
*	```08_null_phy_beta.sh``` - ```08_null_phy_beta.R```
*	```09_null_fun_alpha.sh``` - ```09_null_fun_alpha.R```
*   ```10_null_phy_alpha.sh``` - ```10_null_phy_alpha.R```

<ins>TIP:</ins> Number of nodes, cores per node, and memory per node will vary based on number of sites and methodology. Shell scripts can be edited to adjust these settings accordingly. For example: 1000 nodes: ```#SBATCH --array=1-1000```, 2 CPU cores per node: ```SBATCH --cpus-per-task=2 ```, 18gb ram per node :```#SBATCH --mem=18gb```. We recommend that users experiment with memory and CPU requirements with smaller number of null iterations before running full job.

<ins>NOTE:</ins> We provide the raw observed and null output files for these scripts. See BLANK for more details

### Calculate effect sizes - perform using HPC
Observed and null model outputs were exported in multiple files, reflecting the multi-nodal processing. We need to consolidate these files into single files that contain a list of each null iteration.  The below shell scripts run their respective R script to consolidate null model outputs into single files, separate native and contemporary species pool values, estimate the difference in diversity over time (delta), and export a single file for each diversity metric (i.e., alpha, total beta, replacement, richness difference, LCBD) for the contemporary species pool, native only species pool, and delta values.

* ```11_beta_null_model_prep.sh``` - ```11_beta_null_model_prep.R```
* ```12_alpha_null_model_prep.sh``` - ```12_alpha_null_model_prep.R```

<ins>NOTE:</ins> We provide the resulting nill model input lists. See BLANK for more details.

The lists from the functions above contain the observed values and a list of null iterations for each metric and species pool. The following shell script will run the respective R script, which estimates standardize effect sizes of each single metric. This step involves calling in a SES function created for this project: ```effect_size_function.R```. This function

* ```13_batch_ses.sh``` - ```13_batch_ses.R```

After running the above scripts, download the entire ```HPC_data``` directory to local machine.

### Summarize null model results - perfom on local machine
* 13_

<ins>NOTE:</ins> This is final step for creating null model effect sizes for alpha, beta, and LCBD diversity values. All remaining workflow is for replication of the manuscripts results

### Spatial plotting - perfom on local machine
* 14_

### Redundancy analaysis - perfom on local machine
* 15_
* 16_

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
  

## Diversity Output Data

### Observed values

### Null iterations

### SUmmarized

## RDA data

### predictor data
*
*

### Spatial data







