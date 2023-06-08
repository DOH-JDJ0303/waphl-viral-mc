version 1.0  

import "../tasks/task_fastp.wdl" as fastp
import "../tasks/task_map-reads.wdl" as map_reads
import "../tasks/task_create-consensus.wdl" as create_consensus


workflow create_consensus {
  input {
    File read1
    File read2
    String sample
    String reference
    File ref_dir
  }

  call map_reads.map_reads_pe as map_reads_pe {
    input:
      read1=read1,
      read2=read2,
      reference=reference,
      ref_dir=ref_dir,
      sample=sample
  }

  call create_consensus.create_consensus_ivar as create_consensus_ivar {
    input:
      bam_file=map_reads_pe.mapped_reads,
      reference=reference,
      sample=sample
  }

  output {
    # map_reads
    File mapped_reads = map_reads_pe.mapped_reads
    # create_consensus
    File consensus = create_consensus_ivar.consensus
    File consensus_qual = create_consensus_ivar.consensus_qual

  }
}
