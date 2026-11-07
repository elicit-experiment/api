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
//              renderer,
            }
          }
        ]
      },
    ]
  },
  plugins: [
    new webpack.EnvironmentPlugin(['PUBLIC_CLIENT_ID', 'PUBLIC_CLIENT_SECRET', 'WEBAPP_CLIENT_SECRET'])
  ],
  resolve: {
    // fallback: {
    //   url: false,
    // }
  }
};

module.exports = generateWebpackConfig(customConfig);