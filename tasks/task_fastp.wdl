version 1.0

task fastp_pe {
  input {
    File raw1
    File raw2
    String sample
  }

  command {
    # date and version
    date | tee DATE
    fastp -v | tee VERSION

    # run fastp
    fastp \
      -i ${raw1} \
      -I ${raw2} \
      -o ${sample}-trimmed_R1.fastq \
      -O ${sample}-trimmed_R2.fastq \
      --json ${sample}.json \
      --html ${sample}.html
  }
  output {
    File trim1 = "${sample}-trimmed_R1.fastq"
    File trim2 = "${sample}-trimmed_R2.fastq"
    File fastp_json = "${sample}.json"
    File fastp_html = "${sample}.html"
  }

#  runtime {
#    docker: "staphb/"
#    memory: "8 GB"
#    cpu: 2
#    disks: "local-disk 100 SSD"
#    preemptible: 0
#  }
}
