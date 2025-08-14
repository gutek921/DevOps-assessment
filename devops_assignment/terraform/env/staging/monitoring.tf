resource "google_monitoring_alert_policy" "high_cpu_nodes" {
  display_name = "GKE: node CPU > 80% (5m)"
  combiner     = "OR"

  conditions {
    display_name = "Node CPU high"
    condition_threshold {
      filter          = "metric.type=\"kubernetes.io/node/cpu/allocatable_utilization\" resource.type=\"k8s_node\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.8
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  notification_channels = var.notification_channels
}

resource "google_monitoring_alert_policy" "lb_5xx" {
  display_name = "GKE: LB HTTP 5xx > 5% (5m)"
  combiner     = "OR"

  conditions {
    display_name = "HTTP 5xx ratio high"
    condition_threshold {
      # Metryka: liczba żądań 5xx
      filter = <<-EOT
        metric.type="loadbalancing.googleapis.com/https/request_count"
        AND metric.label."response_code_class"="5xx"
        AND resource.type="https_lb_rule"
      EOT
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.05
      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_SUM"
        group_by_fields      = ["resource.label.forwarding_rule_name"]
      }
    }
  }

  documentation {
    content   = "Alert when LB serves more than 5% 5xx errors over 5 minutes."
    mime_type = "text/markdown"
  }

  notification_channels = var.notification_channels
}
