{
  "assignable_to": "dimension",
  "attributes": {
    "schema": {
      "properties": {
        "domain": {
          "type": "string",
          "editableOn": []
        },
        "rules": {
          "items": {
            "properties": {
              "path": {
                "type": "string"
              },
              "scope": {
                "type": "string"
              }
            },
            "required": [
              "path",
              "scope"
            ],
            "type": "object"
          },
          "type": "array",
          "visibleOn": [
            "read"
          ]
        }
      },
      "required": [
        "domain"
      ],
      "type": "object"
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
