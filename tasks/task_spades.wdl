version 1.0

task spades_pe {
  input {
    File read1
    File read2
    String sample
  }

  command {
    # date and version
    date | tee DATE
    spades.py -v | tee VERSION

    # run spades
    spades.py \
      -1 ${read1} \
      -2 ${read2} \
      -o ${sample} \
      -t 10 \
      --meta 
  }
  output {
    File meta_spades = "${sample}/scaffolds.fasta"
  }

  runtime {
    docker: "staphb/spades:3.15.5"
    memory: "16 GB"
    cpu: 4
    disks: "local-disk 100 SSD"
    preemptible: 0
  }
}
