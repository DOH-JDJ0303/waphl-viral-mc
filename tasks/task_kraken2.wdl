version 1.0

task kraken2_a {
  input {
    File assembly
    String sample
    File k2_db
  }

  command {
    # date and version
    date | tee DATE
    kraken2 -v | head -n 1 | tee VERSION

    # run kraken2
    kraken2 \
      --db ${k2_db} \
      --threads 10 \
      --report ${sample}-k2-report.txt \
      --output ${sample}-k2-output.txt \
      --use-names \
      ${assembly}
  }
  output {
    File k2_report = "${sample}-k2-report.txt"
    File k2_output = "${sample}-k2-output.txt"
  }

#  runtime {
#    docker: "staphb/"
#    memory: "8 GB"
#    cpu: 2
#    disks: "local-disk 100 SSD"
#    preemptible: 0
#  }
}