# -- Knowledge Base ---------------------------------------------------------

resource "oci_generative_ai_agent_knowledge_base" "starter_agent_kb" {
  #Required
  compartment_id                 = local.lz_serv_cmp_ocid
  index_config  {
    index_config_type = "DEFAULT_INDEX_CONFIG"
    should_enable_hybrid_search   = "true"
  }
  display_name                  = "${var.prefix}-agent-kb"
  description                   = "${var.prefix}-agent-kb"
  freeform_tags = local.freeform_tags
}

# -- DataSource ---------------------------------------------------------

resource "oci_generative_ai_agent_data_source" "starter_agent_ds" {
  compartment_id                 = local.lz_serv_cmp_ocid
  knowledge_base_id              = oci_generative_ai_agent_knowledge_base.starter_agent_kb.id
  data_source_config  {
    data_source_config_type = "OCI_OBJECT_STORAGE"
    object_storage_prefixes {
      bucket = oci_objectstorage_bucket.starter_agent_bucket.name
      namespace = var.namespace
    }
  }
  display_name                  = "${var.prefix}-agent-ds"
  description                   = "${var.prefix}-agent-ds"
  freeform_tags = local.freeform_tags
}

# -- IngestionJob ---------------------------------------------------------

resource "oci_generative_ai_agent_data_ingestion_job" "starter_agent_ingestion_job" {
  #Required
  compartment_id                 = local.lz_serv_cmp_ocid
  data_source_id                 = oci_generative_ai_agent_data_source.starter_agent_ds.id
  display_name                  = "${var.prefix}-agent-ingestion-job"
  description                   = "${var.prefix}-agent-ingestion-job"
  freeform_tags = local.freeform_tags
}
