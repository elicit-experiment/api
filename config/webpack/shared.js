// Note: You must restart bin/webpack-dev-server for changes to take effect

/* eslint global-require: 0 */
/* eslint import/no-dynamic-require: 0 */

const webpack = require('webpack');
const { basename, dirname, join, relative, resolve } = require('path');
const { sync } = require('glob');
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const ManifestPlugin = require('webpack-manifest-plugin');
const extname = require('path-complete-extname');
const { env, settings, output, loadersDir } = require('./configuration.js');

const extensionGlob = `**/*{${settings.extensions.join(',')}}*`;
const entryPath = join(settings.source_path, settings.source_entry_path);
const packPaths = sync(join(entryPath, extensionGlob));

const dotenv = require('./dotenv');

dotenv.loadEnv();

throw 'this file is no longer used';

module.exports = {
  entry: packPaths.reduce(
    (map, entry) => {
      const localMap = map;
      const namespace = relative(join(entryPath), dirname(entry));
      localMap[join(namespace, basename(entry, extname(entry)))] = resolve(entry);
      return localMap
    }, {}
  ),

/* this causes the entry to not even get called
TODO: investigate
  output: {
    filename: '[name].js',
    path: output.path,
    publicPath: output.publicPath
  },
 */

  module: {
    rules: sync(join(loadersDir, '*.js')).map(loader => require(loader))
  },

  plugins: [
    new webpack.EnvironmentPlugin(JSON.parse(JSON.stringify(process.env))),
    new MiniCssExtractPlugin({
      filename: (env.NODE_ENV === 'production' ? '[name]-[hash].css' : '[name].css'),
      chunkFilename: "[id].css"
    }),
    new ManifestPlugin({
      entrypoints: true,
      writeToDisk: true,
      publicPath: output.publicPath,
      writeToFileEmit: true
    }),
  ],

  resolve: {
    extensions: settings.extensions,
    modules: [
      resolve(settings.source_path),
      'node_modules'
    ]
  },

  resolveLoader: {
    modules: ['node_modules']
  }
};
