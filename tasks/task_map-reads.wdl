version 1.0

task map_reads_pe {
  input {
    File read1
    File read2
    String reference
    File ref_dir
    String sample
  }

  command <<<
    # date and version
    date | tee DATE
    bwa 2>&1 | grep Version: | sed 's/Version: /BWA /g' > VERSION
    samtools 2>&1 | grep Version: | sed 's/Version: /Samtools /g' >> VERSION

    # setup for pipe
    set -euxo pipefail

    # decompress references
    mkdir refs
    tar xfz ~{ref_dir} -C refs

    # index reference
    bwa index refs/~{reference}

    # run bwa mem, select only mapped read, convert to .bam, and sort
    bwa mem -t 3 refs/~{reference} ~{read1} ~{read2} | samtools view -b -F 4 - | samtools sort - > ~{sample}-~{reference}.bam

  >>>
  output {
    File mapped_reads = "${sample}-${reference}.bam"
  }

  runtime {
    docker: "quay.io/staphb/ivar:1.3.1-titan"
    memory: "16 GB"
    cpu: 4
    disks: "local-disk 100 SSD"
    preemptible: 0
  }
}
