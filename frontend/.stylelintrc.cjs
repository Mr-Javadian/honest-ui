module.exports = {
  // Extend recommended configurations
  extends: [
    "stylelint-config-standard",
    "stylelint-config-recommended-scss",
    "stylelint-config-recommended-vue/scss",
    "stylelint-config-html/vue",
    "stylelint-config-recess-order",
  ],
  // Specify parsers for different file types
  overrides: [
    {
      files: ["**/*.{vue,html}"],
      customSyntax: "postcss-html",
    },
    {
      files: ["**/*.{css,scss}"],
      customSyntax: "postcss-scss",
    },
  ],
  // Custom rules
  rules: {
    "import-notation": "string", // Specify import notation ("string"|"url")
    "selector-class-pattern": null, // Selector class name pattern
    "custom-property-pattern": null, // Custom property naming pattern
    "keyframes-name-pattern": null, // Keyframes name pattern
    "no-descending-specificity": null, // Allow no descending specificity
    // Allow global, export, deep pseudo-classes
    "selector-pseudo-class-no-unknown": [
      true,
      {
        ignorePseudoClasses: ["global", "export", "deep"],
      },
    ],
    // Allow unknown properties
    "property-no-unknown": [
      true,
      {
        ignoreProperties: ["menuBg", "menuText", "menuActiveText"],
      },
    ],
  },
};
