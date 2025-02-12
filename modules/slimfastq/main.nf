def VERSION = '2.04'

process SLIMFASTQ {
    tag "$meta.id"
    label 'process_low'

    conda (params.enable_conda ? "bioconda::slimfastq=2.04" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/slimfastq:2.04--h87f3376_2':
        'quay.io/biocontainers/slimfastq:2.04--h87f3376_2' }"

    input:
    tuple val(meta), path(fastq)

    output:
    tuple val(meta), path("*.sfq"), emit: sfq
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    if (meta.single_end) {
        """
        gzip -d -c '${fastq}' | slimfastq \\
            $args \\
            -f '${prefix}.sfq'

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            slimfastq: ${VERSION}
        END_VERSIONS
        """
    } else {
        """
        gzip -d -c '${fastq[0]}' | slimfastq \\
            $args \\
            -f '${prefix}_1.sfq'

        gzip -d -c '${fastq[1]}' | slimfastq \\
            $args \\
            -f '${prefix}_2.sfq'

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            slimfastq: ${VERSION}
        END_VERSIONS
        """
    }
}
