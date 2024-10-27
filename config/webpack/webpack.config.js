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
        test: /\.html$/,
        loader: 'html-loader',
        options: {
          minimize: true,
          removeAttributeQuotes: false,
          caseSensitive: true,
          customAttrSurround: [ [/#/, /(?:)/], [/\*/, /(?:)/], [/\[?\(?/, /(?:)/] ],
          customAttrAssign: [ /\)?\]?=/ ]
        }
      },
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
      // {
      //   test: /.s[ac]ss$/,
      //   use: ["style-loader",
      //     "css-loader",
      //     "sass-loader"],
      // },{
      //   test: /\.css$/,
      //   use: ["style-loader",
      //     "css-loader"]
      // }
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