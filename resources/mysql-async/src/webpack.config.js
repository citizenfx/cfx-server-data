const path = require('path');
const { VueLoaderPlugin } = require('vue-loader');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const OptimizeCssnanoPlugin = require('@intervolga/optimize-cssnano-plugin');
const VuetifyLoaderPlugin = require('vuetify-loader/lib/plugin');

const serverConfig = {
  entry: './entry/server.js',
  target: 'node',
  mode: 'production',
  output: {
    filename: 'mysql-async.js',
    path: path.resolve(__dirname, '..'),
  },
  optimization: {
    minimize: false,
  },
};

const clientConfig = {
  entry: './entry/client.js',
  target: 'node',
  mode: 'production',
  output: {
    filename: 'mysql-async-client.js',
    path: path.resolve(__dirname, '..'),
  },
  optimization: {
    minimize: false,
  },
};

const nuiConfig = {
  entry: './entry/nui.js',
  mode: 'production',
  output: {
    filename: 'app.js',
    path: path.resolve(__dirname, '../ui'),
  },
  optimization: {
    minimize: true,
  },
  externals: {
    moment: 'moment',
  },
  stats: {
    children: false,
    warnings: false,
  },
  module: {
    rules: [
      {
        test: /\.vue$/,
        use: 'vue-loader',
      },
      {
        test: /\.css$/,
        loader: [MiniCssExtractPlugin.loader, 'css-loader'],
      },
      {
        test: /\.styl(us)?$/,
        loader: [MiniCssExtractPlugin.loader, 'css-loader', 'stylus-loader'],
      },
      {
        test: /\.(woff2?|eot|ttf|otf)(\?.*)?$/i,
        use: [{
          loader: 'file-loader',
          options: {
            name: '[name].[ext]',
            outputPath: './fonts',
          },
        }],
      },
    ],
  },
  plugins: [
    new VueLoaderPlugin(),
    new HtmlWebpackPlugin({
      filename: 'index.html',
      template: './template/index.html',
    }),
    new MiniCssExtractPlugin({
      filename: 'app.css',
      chunkFilename: '[id].css',
    }),
    new OptimizeCssnanoPlugin({
      sourceMap: false,
      cssnanoOptions: {
        preset: ['default', {
          mergeLonghand: false,
          cssDeclarationSorter: false,
        }],
      },
    }),
    new VuetifyLoaderPlugin(),
  ],
};

module.exports = [serverConfig, clientConfig, nuiConfig];
