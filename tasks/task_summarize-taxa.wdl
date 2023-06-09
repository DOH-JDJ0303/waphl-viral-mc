version 1.0

task prepare_refs {
  input {
    File ref_dir
  }

  command <<<
    refs=$(ls ~{ref_dir})

    for ref in ${refs}
    do
        seqtk seq -C ~{ref_dir}/${ref} > tmp.fa
        seqtk rename tmp.fa ${ref} >> refs.fa
    done

    rm tmp.fa
  >>>
  output {
    File refs = "refs.fa"
  }

  runtime {
    docker: "staphb/seqtk:1.3"
    memory: "16 GB"
    cpu: 4
    disks: "local-disk 100 SSD"
    preemptible: 0
  }
}

task map_meta_ref {
  input {
    File assembly
    File refs
    String sample
  }

  command {
    # align sample assembly to all references
    minimap2 -x asm5 --secondary=no ${assembly} ${refs} > ${sample}-refs-aligned.paf
  }
  output {
    File ref_aln = "${sample}-refs-aligned.paf"
  }

  runtime {
    docker: "staphb/minimap2:2.25"
    memory: "16 GB"
    cpu: 4
    disks: "local-disk 100 SSD"
    preemptible: 0
  }
}

task summarize_taxa {
  input {
    File k2_output
    String sample
    File ref_aln
  }

  command {
    # summarize output of kraken2
    summarize_taxa.R ${k2_output} ${sample}
    # select references for consensus sequences
    select_refs.R ${ref_aln} ${sample}
  }
  output {
    File taxa_summary = "${sample}-taxa-summary.tsv"
    File ref_summary = "${sample}-ref-align-summary.tsv"
    File ref_list = "${sample}-ref-list.tsv"
  }

  runtime {
    docker: "jdj0303/waphl-viral-r:1.0.0"
    memory: "16 GB"
    cpu: 4
    disks: "local-disk 100 SSD"
    preemptible: 0
  }
}
