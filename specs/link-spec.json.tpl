{
  "assignable_to": "scope",
  "attributes": {
    "schema": {
      "properties": {
        "path": {
          "type": "string",
          "order": 1
        },
        "additional_paths": {
          "type": "array",
          "title": "Additional Paths",
          "items": {
            "type": "string"
          },
          "order": 2
        }
      },
      "required": [
        "path"
      ],
      "type": "object"
    },
    "values": {}
  },
  "dimensions": {},
  "name": "Publish",
  "selectors": {
    "category": "any",
    "imported": false,
    "provider": "any",
    "sub_category": "any"
  },
  "slug": "publish",
  "specification_id": "{{ env.Getenv "SERVICE_SPECIFICATION_ID" }}",
  "unique": false,
  "use_default_actions": true,
  "visible_to": [
    "{{ env.Getenv "NRN" }}"
  ]
}
