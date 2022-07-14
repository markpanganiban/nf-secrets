nextflow.enable.dsl=2

params.email = 'support@itsmp.xyz'

process someTask {
  secret 'ATHENA_USER'
  secret 'MAIL_PASSWORD'
  output: 
     stdout 
  script:
  '''
    echo "Secrets phrase: $ATHENA_USER $MAIL_PASSWORD"
  '''
}

workflow {
  someTask().view()
}


workflow.onComplete {
    def msg = """\
        Pipeline execution summary
        ---------------------------
        Completed at: ${workflow.complete}
        Duration    : ${workflow.duration}
        Success     : ${workflow.success}
        workDir     : ${workflow.workDir}
        exit status : ${workflow.exitStatus}
        """
        .stripIndent()

    sendMail(to: params.email, from: params.email, subject: 'My pipeline execution', body: msg)
}
