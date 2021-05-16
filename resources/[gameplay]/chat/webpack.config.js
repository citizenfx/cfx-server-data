const HtmlWebpackPlugin = require('html-webpack-plugin');
const path = require('path');
const HtmlWebpackInlineSourcePlugin = require('html-webpack-inline-source-plugin');
const { VueLoaderPlugin } = require('vue-loader');
const CopyPlugin = require('copy-webpack-plugin');
const { CleanWebpackPlugin } = require('clean-webpack-plugin');

module.exports = {
    mode: 'production',
    entry: './html/main.ts',
    output: {
      filename: '[name].[contenthash:8].js',
      chunkFilename: '[name].[contenthash:8].js',
      path: path.resolve(__dirname, 'dist')
    },
    module: {
        rules: [
            {
                test: /\.ts$/,
                loader: 'ts-loader',
                exclude: /node_modules/,
                options: {
                  appendTsSuffixTo: [/\.vue$/],
                }
            },
            {
                test: /\.vue$/,
                loader: 'vue-loader',
            },
        ]
    },
    plugins: [
        new VueLoaderPlugin(),
        new HtmlWebpackPlugin({
            inlineSource: '.(js|css)$',
            template: path.resolve(__dirname, 'html', 'index.html'),
            filename: 'ui.html'
        }),
        new HtmlWebpackInlineSourcePlugin(),
        new CleanWebpackPlugin(),
        new CopyPlugin({
          patterns: [
            { from: 'html/index.css', to: 'index.css' },
            { from: 'html/vendor/animate.3.5.2.min.css', to: 'animate.3.5.2.min.css'},
            { from: 'html/vendor/flexboxgrid.6.3.1.min.css', to: 'flexboxgrid.6.3.2.min.css'},
            { from: 'html/vendor/latofonts.css', to: 'latofonts.css'},
            { from: 'html/vendor/fonts/LatoBold.woff2', to: 'fonts/LatoBold.woff2'},
            { from: 'html/vendor/fonts/LatoBold2.woff2', to: 'fonts/LatoBold2.woff2'},
            { from: 'html/vendor/fonts/LatoLight.woff2', to: 'fonts/LatoLight.woff2'},
            { from: 'html/vendor/fonts/LatoLight2.woff2', to: 'fonts/LatoLight2.woff2'},
            { from: 'html/vendor/fonts/LatoRegular.woff2', to: 'fonts/LatoRegular.woff2'},
            { from: 'html/vendor/fonts/LatoRegular2.woff2', to: 'fonts/LatoRegular2.woff2'},
          ],
        }),
    ],
    resolve: {
        extensions: ['.ts', '.js', '.vue', '.json', '.css'],
        alias: {
          'vue$': 'vue/dist/vue.esm.js'
        }
    },
    optimization: {
        moduleIds: 'hashed',
        runtimeChunk: 'single',
        splitChunks: {
          cacheGroups: {
            vendor: {
              test: /[\\/]node_modules[\\/]/,
              name: 'vendors',
              priority: -10,
              chunks: 'all',
            },
          },
        },
      }
};