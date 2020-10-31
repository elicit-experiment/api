module.exports = {
  "parserOptions": {
    "parser": "babel-eslint"
  },
  "extends": ["eslint:recommended", "airbnb-base", "plugin:react/recommended", "prettier"],
  "env": {
    "browser": true,
    "commonjs": true,
    "es6": true,
    "jquery": true
  },
  "globals": {
    "newrelic": true,
    "fbq": true,
    "FB": true,
    "gtag": true
  },
  rules: {
    'no-console': 'off',
    "no-restricted-syntax": ["error", "ForInStatement", "LabeledStatement", "WithStatement"],
    "class-methods-use-this": 'off',
    "no-param-reassign": 'off',
    "max-len": ["error", 120, 2],
    "vue/max-attributes-per-line": ["error", {
      "singleline": 5,
      "multiline": {
        "max": 1,
        "allowFirstLine": false
      }
    }],
    "no-underscore-dangle": 'off',
    "vue/script-indent": ["error", 2, { "baseIndent": 1 }]
  },
  "overrides": [ // https://github.com/vuejs/eslint-plugin-vue/blob/master/docs/rules/script-indent.md
    {
      "files": ["*.vue"],
      "rules": {
        "indent": "off"
      }
    }],
  "settings": {
    "import/resolver": {
      "webpack": {
        "config": "./config/webpack/production.js"
      },
    },
    "react": {
      "createClass": "createReactClass", // Regex for Component Factory to use,
                                         // default to "createReactClass"
      "pragma": "React",  // Pragma to use, default to "React"
      "fragment": "Fragment",  // Fragment to use (may be a property of <pragma>), default to "Fragment"
      "version": "16.7", // React version. "detect" automatically picks the version you have installed.
                           // You can also use `16.0`, `16.3`, etc, if you want to override the detected value.
                           // default to latest and warns if missing
                           // It will default to "detect" in the future
    },
  },
};
