version 1.0  

import "../tasks/task_spades.wdl" as spades
import "../tasks/task_kraken2.wdl" as kraken2
import "../tasks/task_summarize-taxa.wdl" as summarize_taxa
import "../tasks/task_select-refs.wdl" as select_refs


workflow classify_viruses {
  input {
    File read1
    File read2
    String sample
    File k2_db
    File ref_dir
  }

  call spades.spades_pe as spades_pe {
    input:
      read1=read1,
      read2=read2,
      sample=sample
  }

  call kraken2.kraken2_a as kraken2_a {
    input:
      assembly=spades_pe.meta_spades,
      sample=sample,
      k2_db=k2_db
  }

  call summarize_taxa.summarize_taxa as summarize_taxa {
    input:
      k2_output=kraken2_a.k2_output,
      sample=sample
  }

  call select_refs.select_refs as select_refs {
    input:
      assembly=spades_pe.meta_spades,
      ref_dir=ref_dir,
      sample=sample
  }

  output {
    # spades
    File meta_spades = spades_pe.meta_spades
    # kraken2
    File k2_report=kraken2_a.k2_report
    File k2_output=kraken2_a.k2_output
    # summarize_taxa
    File taxa_summary=summarize_taxa.taxa_summary
    # select refs
    File ref_summary = select_refs.ref_summary
    Array[Array[String]] ref_list = read_tsv(select_refs.ref_list)

  }
}
