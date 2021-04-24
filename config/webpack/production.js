const SpeedMeasurePlugin = require('speed-measure-webpack-plugin');
const TerserPlugin = require('terser-webpack-plugin');
const environment = require('./environment');

process.env.NODE_ENV = process.env.NODE_ENV || 'production';
const smp = new SpeedMeasurePlugin();

// const ManifestPlugin = require('webpack-manifest-plugin');

const config = environment.toWebpackConfig();
// config.plugins.prepend = (new ManifestPlugin());

config.mode = 'production';

config.optimization = {
  minimizer: [
    new TerserPlugin({
      parallel: true,
      terserOptions: {
        ecma: 6,
      },
    }),
  ],
};

module.exports = smp.wrap(config);
