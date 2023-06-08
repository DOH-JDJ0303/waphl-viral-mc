version 1.0

task summarize_taxa {
  input {
    File k2_output
    String sample
  }

  command {
    /home/pipelines/waphl-viral/alpha/bin/summarize_taxa.R ${k2_output} ${sample}
  }
  output {
    File taxa_summary = "${sample}-taxa-summary.tsv"
  }

#  runtime {
#    docker: "staphb/"
#    memory: "8 GB"
#    cpu: 2
#    disks: "local-disk 100 SSD"
#    preemptible: 0
#  }
}
