version 1.0

task scrubber {
  input {
    File read1
    String sample
  }

  command <<<
    # date - no version available
    date | tee DATE

    # run sra-human-scrubber - need to check for database in the future
    scrub.sh \
      -i ~{read1} \
      -o ~{sample}-scrubbed_R1.fastq \
      -x -r
    # print list of sequence headers to use for extracting reads from the reverse file
    cat ~{sample}-scrubbed_R1.fastq | awk 'NR % 4 == 1 {print $1}' | sed 's/^@//g' > scrubbed-seqs.txt

  >>>
  output {
    File scrub1 = "${sample}-scrubbed_R1.fastq"
    File seqs = "scrubbed-seqs.txt"
  }

  runtime {
    docker: "ncbi/sra-human-scrubber:2.1.0"
    memory: "16 GB"
    cpu: 4
    disks: "local-disk 100 SSD"
    preemptible: 0
  }
}

task match_read2 {
  input {
    File read2
    File seqs
    String sample
  }

  command <<<
    # date - no version available
    date | tee DATE

    # extract reads in forward set from reverse set
    seqtk subseq ~{read2} ~{seqs} > ~{sample}-scrubbed_R2.fastq

  >>>
  output {
    File scrub2 = "${sample}-scrubbed_R2.fastq"
  }

  runtime {
    docker: "staphb/seqtk:1.3"
    memory: "16 GB"
    cpu: 4
    disks: "local-disk 100 SSD"
    preemptible: 0
  }
}
