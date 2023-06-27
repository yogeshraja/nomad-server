locals {
  job_files = fileset(path.module, "jobs/*.nomad")
}

provider "nomad" {
  address = var.nomad_address
}

resource "nomad_job" "statup_jobs" {
    for_each = local.job_files

    jobspec = file(each.value)
    detach = true
    purge_on_destroy = true
}