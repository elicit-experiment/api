const webpack = require('webpack');
const { environment } = require('@rails/webpacker')
const marked = require("marked");
const renderer = new marked.Renderer();

const dotenv = require('./dotenv');

dotenv.loadEnv();

environment.plugins.append('env', new webpack.EnvironmentPlugin(process.env));

environment.loaders.append('html', {
  test: /\.html$/,
  use: [{
    loader: 'html-loader',
    options: {
      minimize: true,
      removeAttributeQuotes: false,
      caseSensitive: true,
      customAttrSurround: [ [/#/, /(?:)/], [/\*/, /(?:)/], [/\[?\(?/, /(?:)/] ],
      customAttrAssign: [ /\)?\]?=/ ]
    }
  }]
})

environment.loaders.append('md', {
  test: /\.md$/,
  use: [                    {
    loader: "html-loader"
  },{
    loader: 'markdown-loader',
    options: {
      pedantic: true,
      renderer
    }
  }]
})

module.exports = environment
