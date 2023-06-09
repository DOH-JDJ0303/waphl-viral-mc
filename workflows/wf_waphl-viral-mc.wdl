version 1.0  

import "../tasks/task_fastp.wdl" as fastp
import "../tasks/task_sra-human-scrubber.wdl" as scrubber
import "../subworkflows/subwf_classify-viruses.wdl" as classify
import "../subworkflows/subwf_create-consensus.wdl" as consensus

workflow waphl_viral_mc {
  input {
    File raw1
    File raw2
    String sample
    File k2_db
    File ref_dir
  }

  call fastp.fastp_pe as fastp_pe {
    input:
      raw1=raw1,
      raw2=raw2,
      sample=sample
  }

  call scrubber.scrubber as scrubber {
    input:
      read1=fastp_pe.trim1,
      sample=sample
  }

  call scrubber.match_read2 as match_read2 {
    input:
      read2=fastp_pe.trim2,
      seqs=scrubber.seqs,
      sample=sample
  }

  call classify.classify_viruses as classify_viruses {
    input:
      read1=scrubber.scrub1,
      read2=match_read2.scrub2,
      sample=sample,
      k2_db=k2_db,
      ref_dir=ref_dir
  }

  scatter(ref in classify_viruses.ref_list) {
    call consensus.create_consensus as create_consensus {
      input:
        read1=scrubber.scrub1,
        read2=match_read2.scrub2,
        sample=sample,
        reference=ref[0],
        ref_dir=ref_dir
    }
  }

  output {
    # scrubber
    File scrub1 = scrubber.scrub1
    File scrub2 = match_read2.scrub2
    # classify viruses
    File taxa_summary=classify_viruses.taxa_summary
    # create_consensus
    Array[File] consensus = create_consensus.consensus

  }
}
