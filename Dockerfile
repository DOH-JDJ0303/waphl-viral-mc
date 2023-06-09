# Use a base image with Ubuntu
FROM bioconductor/bioconductor_docker

# required R packages
RUN R -e "install.packages(c('readr', 'dplyr','tidyr'), repos='https://cran.rstudio.com/')"

# add scripts & make executable
ADD bin/select_refs.R  bin/summarize_taxa.R /bin/
RUN chmod +wrx /bin/*.R
