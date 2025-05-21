println("launchDir: ${launchDir}")
println("projectDir: ${projectDir}")
println("moduleDir: ${moduleDir}")
println("workDir: ${workDir}")

meta = [
  "resources_dir": moduleDir.toRealPath().normalize()
]

process testcaching {
  container 'ubuntu:latest'

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
  Channel.fromPath(params.input)
    | map { file ->
      [
        file.baseName,
        [output: "output.txt"],
        file,
        meta.resources_dir
      ]
    }
    | testcaching
    | view { "Output: $it" }
}
