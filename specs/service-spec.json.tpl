{
  "assignable_to": "dimension",
  "attributes": {
    "schema": {
      "type": "object",
      "required": [
        "visibility",
        "domain"
      ],
      "properties": {
        "rules": {
          "type": "array",
          "items": {
            "type": "object",
            "required": [
              "path",
              "scope"
            ],
            "properties": {
              "path": {
                "type": "string"
              },
              "scope": {
                "type": "string"
              }
            }
          },
          "order": 2,
          "visibleOn": [
            "read"
          ]
        },
        "domain": {
          "type": "string"
        },
        "visibility": {
          "type": "string",
          "oneOf": [
            {
              "const": "internet-facing",
              "title": "Internet facing"
            },
            {
              "const": "internal",
              "title": "Internal"
            }
          ],
          "order": 1,
          "default": "internet-facing",
          "editableOn": [
            "create"
          ]
        }
      }
    },
    "values": {}
  },
  "dimensions": {},
  "name": "Service exposer",
  "selectors": {
    "category": "any",
    "imported": false,
    "provider": "any",
    "sub_category": "any"
  },
  "slug": "service-exposer",
  "type": "dependency",
  "use_default_actions": true,
  "visible_to": [
    "{{ env.Getenv "NRN" }}"
  ]
}
