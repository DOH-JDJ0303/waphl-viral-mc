version 1.0

task select_refs {
  input {
    File assembly
    File ref_dir
    String sample
  }

  command {
    /home/pipelines/waphl-viral/alpha/bin/select_refs.sh ${assembly} ${ref_dir} ${sample}
    /home/pipelines/waphl-viral/alpha/bin/select_refs.R ${sample}-refs-aligned.paf ${sample}
  }
  output {
    File ref_summary = "${sample}-ref-align-summary.tsv"
    File ref_list = "${sample}-ref-list.tsv"
  }

#  runtime {
#    docker: "staphb/"
#    memory: "8 GB"
#    cpu: 2
#    disks: "local-disk 100 SSD"
#    preemptible: 0
#  }
}
