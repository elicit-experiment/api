const { environment } = require('@rails/webpacker')
const marked = require("marked");
const renderer = new marked.Renderer();

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
