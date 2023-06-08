#!/usr/bin/env Rscript

# check for required packages
list.of.packages <- c("readr", "dplyr","tidyr")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

# load packages
library(readr)
library(dplyr)
library(tidyr)

# load args
args <- commandArgs(trailingOnly=T)
k2_output <- args[1]
sample <- args[2]

# determine approx. percentages of each taxa observed and output as .tsv
read_tsv(k2_output, col_names = F) %>%
  separate(col="X2", sep = "_", into = c("label1", "node", "label2", "length", "label3","coverage"), convert = T) %>%
  separate(col="X3", sep = " \\(taxid ", into = c("name", "taxid")) %>%
  mutate(taxid = gsub(taxid, pattern = ")$", replacement = "")) %>%
  mutate(est_reads=as.numeric(length)*as.numeric(coverage)) %>%
  group_by(name, taxid) %>%
  summarise(group_sum = sum(est_reads), total_length = sum(length), mean_coverage = mean(coverage)) %>%
  ungroup() %>%
  mutate(tot_reads = sum(group_sum)) %>%
  mutate(est_perc_abund = as.character(100*group_sum / tot_reads)) %>%
  select(name, taxid, est_perc_abund, total_length, mean_coverage) %>% 
  arrange(desc(est_perc_abund)) %>%
  write.table(file = paste0(sample,"-taxa-summary.tsv"), quote = F, sep = "\t", row.names = F)
