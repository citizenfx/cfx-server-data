const path = require("path");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const webpack = require('webpack')
const CopyPlugin = require('copy-webpack-plugin');

module.exports = {
  mode: 'production',
  entry: './ui/index.tsx',
  output: {
    path: "./html",
    filename: '[name].js',
  },

  module: {
    rules: [
      {
				test: /\.tsx?$/,
				use: [
					{
						loader:'ts-loader',
						options: {
							transpileOnly: true
						},
					},
				],
				exclude: /node_modules/,
			},
      {
				test: /\.css$/,
				exclude: /node_modules/,
				use: ['style-loader', 'css-loader']
			},
			{
				test: /\.css$/,
				include: /node_modules/,
				use: ['style-loader', 'css-loader']
			},
      {
				test: /\.(jpg|png|gif)$/,
				use: [
					{
						loader: 'url-loader',
						options: {
							// Inline files smaller than 10 kB
							limit: 10 * 1024,
						},
					},
				],
			},
    ]
  },

  plugins: [
    new webpack.EnvironmentPlugin({
			NODE_ENV: 'production'
		}),
    new HtmlWebpackPlugin({
      template: "ui/index.html",
    }),
    new CopyPlugin([
      { from: 'ui/App.css', to: 'App.css' }
    ])
  ],


  resolve: {
		modules: ['src', 'node_modules'],
		extensions: ['.js', '.jsx', '.ts', '.tsx', '.react.js']
	}
}
