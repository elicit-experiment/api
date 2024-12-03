// config/webpack/base.js
const { generateWebpackConfig } = require('shakapacker');

const webpack = require('webpack');
const marked = require("marked");
const renderer = new marked.Renderer();

const dotenv = require('./dotenv');

dotenv.loadEnv();

const customConfig = {
  module: {
    rules: [
      {
        test: /\.md$/,
        use: [
          {
            loader: "html-loader",
          },
          {
            loader: 'markdown-loader',
            options: {
              pedantic: true,
              renderer,
            }
          }
        ]
      },
    ]
  },
  plugins: [
    new webpack.EnvironmentPlugin(process.env)
  ],
  resolve: {
    // fallback: {
    //   url: false,
    // }
  }
};

module.exports = generateWebpackConfig(customConfig);