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
paf_file <- args[1]
sample <- args[2]

# load alignment file
paf <- read_tsv(paf_file, col_names = F) %>%
  select(X1,X2,X11) %>%
  rename(contig=X1,length=X2,align=X11) %>%
  mutate(assembly=gsub(contig, pattern="[0-9]$",replacement=""))

# sum alignments
ref.summary <- paf %>% 
  select(-align) %>%
  unique() %>%
  group_by(assembly) %>%
  summarise(tot_length = sum(length))

# sum assembly lengths
align.summary <- paf %>%
  group_by(assembly) %>%
  summarise(tot_align = sum(align)) %>%
  merge(ref.summary, by = "assembly") %>%
  mutate(genome_frac = tot_align / tot_length)

# select references
ref.list <- align.summary %>%
  subset(genome_frac > 0.90) %>%
  select(assembly)

# write outputs
write.table(x= align.summary, file = paste0(sample,"-ref-align-summary.tsv"), quote = F, sep = "\t", row.names = F)
write.table(x= ref.list, file = paste0(sample,"-ref-list.tsv"), quote = F, sep = "\t", row.names = F, col.names = F)
