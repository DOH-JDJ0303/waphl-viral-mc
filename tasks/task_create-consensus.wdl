version 1.0

task create_consensus_ivar {
  input {
    File bam_file
    String reference
    String sample
  }

  command {
    # date and version
    date | tee DATE
    samtools 2>&1 | grep Version: | sed 's/Version: /Samtools /g' >> VERSION
    ivar version | head -n 1 >> VERSION

    # setup for pipe
    set -euxo pipefail

    # create mpilup and call consensus
    samtools mpileup -aa -A -Q 0 -d 0 ${bam_file} | ivar consensus -p ${sample}-${reference} -m 10 -n N -t 0.5 > IVAR 2>&1
  }
  output {
    File consensus = "${sample}-${reference}.fa"
    File consensus_qual = "${sample}-${reference}.qual.txt"
  }

  runtime {
    docker: "quay.io/staphb/ivar:1.3.1-titan"
    memory: "16 GB"
    cpu: 4
    disks: "local-disk 100 SSD"
    preemptible: 0
  }
}
