version 1.0

task prepare_refs {
  input {
    File assembly
    File ref_dir
    String sample
  }

  command {
    # combine all refs into single file
    cat ${ref_dir}/* > refs.fasta
    # align sample assembly to all references
    minimap2 -x asm5 --secondary=no ${assembly} refs.fasta > ${sample}-refs-aligned.paf
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
