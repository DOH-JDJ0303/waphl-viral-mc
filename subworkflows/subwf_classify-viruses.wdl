version 1.0  

import "../tasks/task_spades.wdl" as spades
import "../tasks/task_kraken2.wdl" as kraken2
import "../tasks/task_prepare-references.wdl" as prepare_refs
import "../tasks/task_summarize-taxa.wdl" as summarize_taxa


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

  call summarize_taxa.prepare_refs as prepare_refs {
    input:
      ref_dir=ref_dir
  }

  call summarize_taxa.map_meta_ref as map_meta_ref {
    input:
      assembly=spades_pe.meta_spades,
      refs=prepare_refs.refs,
      sample=sample
  }

  call summarize_taxa.summarize_taxa as summarize_taxa {
    input:
      k2_output=kraken2_a.k2_output,
      sample=sample,
      ref_aln=map_meta_ref.ref_aln
  }

  output {
    # summarize_taxa
    File taxa_summary = summarize_taxa.taxa_summary
    File ref_summary = summarize_taxa.ref_summary
    Array[Array[String]] ref_list = read_tsv(summarize_taxa.ref_list)
  }
}
