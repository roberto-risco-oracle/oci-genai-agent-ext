locals {
  db_root_url = replace(data.oci_database_autonomous_database.starter_atp.connection_urls[0].apex_url, "/ords/apex", "" )
}

resource "oci_apigateway_deployment" "starter_apigw_deployment_api" {   
  count          = var.fn_image == "" ? 0 : 1   
  compartment_id = local.lz_web_cmp_ocid
  display_name   = "${var.prefix}-apigw-deployment"
  gateway_id     = local.apigw_ocid
  path_prefix    = "/app"
  specification {
    logging_policies {
      access_log {
        is_enabled = true
      }
      execution_log {
        #Optional
        is_enabled = true
      }
    }
    routes {
      path    = "/query"
      methods = [ "ANY" ]
      backend {
        type = "HTTP_BACKEND"
        url    = "http://${data.oci_core_instance.starter_bastion.public_ip}/app/query"
        connect_timeout_in_seconds = 10
        read_timeout_in_seconds = 30
        send_timeout_in_seconds = 30        
      }
    }    
    routes {
      path    = "/generate"
      methods = [ "ANY" ]
      backend {
        type = "HTTP_BACKEND"
        url    = "http://${data.oci_core_instance.starter_bastion.public_ip}:8080/generate"
        connect_timeout_in_seconds = 10
        read_timeout_in_seconds = 30
        send_timeout_in_seconds = 30        
      }
    }      
    routes {
      path    = "/cohere_chat"
      methods = [ "ANY" ]
      backend {
        type = "HTTP_BACKEND"
        url    = "http://${data.oci_core_instance.starter_bastion.public_ip}:8080/cohere_chat"
        connect_timeout_in_seconds = 10
        read_timeout_in_seconds = 30
        send_timeout_in_seconds = 30        
      }
    }    
    routes {
      path    = "/llama_chat"
      methods = [ "ANY" ]
      backend {
        type = "HTTP_BACKEND"
        url    = "http://${data.oci_core_instance.starter_bastion.public_ip}:8080/llama_chat"
        connect_timeout_in_seconds = 10
        read_timeout_in_seconds = 30
        send_timeout_in_seconds = 30        
      }
    }            
    routes {
      path    = "/info"
      methods = [ "ANY" ]
      backend {
        type = "STOCK_RESPONSE_BACKEND"
        body   = "Function ${var.language}"
        status = 200
      }
    }    
    routes {
      path    = "/"
      methods = [ "ANY" ]
      backend {
        type = "HTTP_BACKEND"
        url    = "http://${data.oci_core_instance.starter_bastion.public_ip}/"
        connect_timeout_in_seconds = 10
        read_timeout_in_seconds = 30
        send_timeout_in_seconds = 30
      }
    }    
    routes {
      path    = "/{pathname*}"
      methods = [ "ANY" ]
      backend {
        type = "HTTP_BACKEND"
        url    = "http://${data.oci_core_instance.starter_bastion.public_ip}/$${request.path[pathname]}"
      }
    }
  }
  freeform_tags = local.api_tags
}

# One single entry "/" would work too. 
# The reason of the 3 entries is to allow to make it work when the APIGW is shared with other URLs (ex: testsuite)
resource "oci_apigateway_deployment" "starter_apigw_deployment_ords" {
  compartment_id = local.lz_app_cmp_ocid
  display_name   = "${var.prefix}-apigw-deployment"
  gateway_id     = local.apigw_ocid
  path_prefix    = "/ords"
  specification {
    # Go directly from APIGW to APEX in the DB    
    routes {
      path    = "/{pathname*}"
      methods = [ "ANY" ]
      backend {
        type = "HTTP_BACKEND"
        url    = "${local.db_root_url}/ords/$${request.path[pathname]}"
        connect_timeout_in_seconds = 60
        read_timeout_in_seconds = 120
        send_timeout_in_seconds = 120            
      }
      request_policies {
        header_transformations {
          set_headers {
            items {
              name = "Host"
              values = ["$${request.headers[Host]}"]
            }
          }
        }
      }
    }
  }
  freeform_tags = local.api_tags
}

resource "oci_apigateway_deployment" "starter_apigw_deployment_i" {
  compartment_id = local.lz_app_cmp_ocid
  display_name   = "${var.prefix}-apigw-deployment"
  gateway_id     = local.apigw_ocid
  path_prefix    = "/i"
  specification {
    # Go directly from APIGW to APEX in the DB    
    routes {
      path    = "/{pathname*}"
      methods = [ "ANY" ]
      backend {
        type = "HTTP_BACKEND"
        url    = "${local.db_root_url}/i/$${request.path[pathname]}"
        connect_timeout_in_seconds = 60
        read_timeout_in_seconds = 120
        send_timeout_in_seconds = 120            
      }
      request_policies {
        header_transformations {
          set_headers {
            items {
              name = "Host"
              values = ["$${request.headers[Host]}"]
            }
          }
        }
      }
    }
  }
  freeform_tags = local.api_tags
}