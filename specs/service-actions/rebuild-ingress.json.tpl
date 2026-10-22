{
    "name": "Rebuild ingress",
    "slug": "rebuild-ingress",
    "type": "custom",
    "annotations": {},
    "enabled_when": "",
    "retryable": false,
    "service_specification_id": "{{ env.Getenv "SERVICE_SPECIFICATION_ID" }}",
    "parameters": {
        "schema": {
            "type": "object",
            "required": [],
            "properties": {}
        },
        "values": {}
    },
    "results": {
        "schema": {
            "type": "object",
            "required": [],
            "properties": {}
        },
        "values": {}
    }
}