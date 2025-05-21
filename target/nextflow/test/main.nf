nextflow.preview.output = true

println("launchDir: ${launchDir}")
println("projectDir: ${projectDir}")
println("moduleDir: ${moduleDir}")
println("workDir: ${workDir}")

process testcaching {
    input:
      tuple val(id), val(args), path(viash_par_input), path(resourcesDir, stageAs: ".viash_meta_resources")

    output:
      tuple val("$id"), path{args.output}, optional: true

    script:
    """
    export VIASH_META_RESOURCES_DIR="${resourcesDir}"

    cp -r "${viash_par_input}" "${args.output}"
    """
}

workflow {
  out0 = Channel.fromPath(params.input)
    | map { file ->
      [
        file.baseName,
        [output: "output.txt"],
        file,
        moduleDir.toRealPath().normalize()
      ]
    }
    | testcaching

  publish:
    out = out0
}

output {
  out {
    path '.'
  }
}