#!/usr/bin/env nextflow

/*

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

rendeirolab/lazyslide-nextflow

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Github : https://github.com/rendeirolab/lazyslide-nextflow

----------------------------------------------------------------------------------------

*/



nextflow.enable.dsl = 2

params.input = "data/input.csv"
// Path to the input CSV
params.slide_col = "slide"
params.outdir = "results/"
// Directory for outputs
params.aggregated_output = "results/aggregated_features.zarr"
params.models = "vgg16,resnet50"
params.tilePx = 256
params.mpp = 'none'

params.model_list = params.models?.split(',') as List


workflow {

    log.info(
        """
    ██       █████  ███████ ██    ██ ███████ ██      ██ ██████  ███████
    ██      ██   ██    ███   ██  ██  ██      ██      ██ ██   ██ ██
    ██      ███████   ███     ████   ███████ ██      ██ ██   ██ █████
    ██      ██   ██  ███       ██         ██ ██      ██ ██   ██ ██
    ███████ ██   ██ ███████    ██    ███████ ███████ ██ ██████  ███████

    ===================================================================


    Workflow information:
    Workflow: ${workflow.projectDir}

    Input parameters:
    Slide table: ${file(params.input)}
    Tile size: ${params.tilePx}px
    Tile mpp: ${params.mpp}
    Feature extraction models: ${params.model_list}

    The results will be available at: ${params.outdir}

"""
    )

    input = file(params.input)

    updated_csv = Channel
        .fromPath(input)
        .splitCsv(header: true)
        .map { row ->
            {
                def slide = row[params.slide_col]
                def updatedSlide

                if (file(slide).exists()) {
                    updatedSlide = slide
                }
                else {
                    updatedSlide = file(input).parent / slide
                }

                row[params.slide_col] = updatedSlide.toString()
                return row
            }
        }
    slide_list = updated_csv.map { row ->
        row[params.slide_col]
    }

    processed = processWSI(slide_list)
    processed = featureExtraction(processed, params.model_list)
    aggregateResults(processed.collect(), input, params.model_list)
}

process processWSI {
    tag { "${wsi_path}" }

    input:
    val wsi_path

    output:
    val wsi_path, emit: wsis

    script:
    def mpp_part = "--mpp ${params.mpp}"

    if (params.mpp == 'none') {
        mpp_part = ""
    }

    """
    lazyslide preprocess ${wsi_path} --tile-px ${params.tilePx} ${mpp_part}
    """
}

process featureExtraction {

    tag { "${model} ${wsi}" }

    input:
    val wsi
    each model

    output:
    val wsi, emit: wsis

    script:
    """
    lazyslide feature ${wsi} --model ${model}
    """
}



process aggregateResults {

    publishDir "${params.outdir}/agg", pattern: "*.zarr"

    input:
    val wsis
    val csv_file
    each model

    output:
    path "*.zarr"

    script:

    """
    lazyslide agg ${csv_file} --feature-key ${model} --wsi-col ${params.slide_col}
    """
}
