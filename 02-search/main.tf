provider "mongodbatlas" {
  public_key  = var.mongodb_atlas_api_pub_key
  private_key = var.mongodb_atlas_api_pri_key
}


locals {
  cluster = "jpmc-search-index"
  database = "database_test"
  collection_name = "collection_test"
}


resource "mongodbatlas_search_index" "jpmc-search-index" {

  name   = local.cluster
  project_id = var.mongodb_atlas_project_id
  cluster_name = local.cluster

  analyzer = "lucene.standard"
  database = local.database
  collection_name = local.collection_name

  mappings_dynamic = true
  search_analyzer = "lucene.standard"

  wait_for_index_build_completion = true
}
