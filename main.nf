nextflow.enable.dsl=2

params.email = 'support@itsmp.xyz'

process someTask {
  secret 'ATHENA_USER'
  secret 'ATHENA_PASSWORD'
  secret 'MAIL_NAME'
  secret 'MAIL_ADD'
  secret 'MAIL_PASSWORD'
  output: 
     stdout 
  script:
  '''
    echo "Secrets phrase: $ATHENA_USER $ATHENA_PASSWORD $MAIL_NAME $MAIL_ADD $MAIL_PASSWORD"
  '''
}


plugins {
  id 'nf-sqldb@0.4.0'
}

sql {
    db {
        'athena' {
              url = 'jdbc:awsathena://AwsRegion=us-east-1;S3OutputLocation=s3://nf-mpanganiban'
              user = secrets.ATHENA_USER
              password = secrets.ATHENA_PASSWORD
            }
    }
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
