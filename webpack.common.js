/*jshint esversion: 6*/
const path = require('path');
const { VueLoaderPlugin } = require('vue-loader');

module.exports = {
	entry: {
		'forms' : path.join(__dirname, 'src/js/', 'main.js'),
	},
	output: {
		path: path.resolve(__dirname, './js'),
		publicPath: '/js/',
		filename: '[name].js'
	},
	module: {
		rules: [
			{
				test: /\.css$/,
				use: [
					'vue-style-loader',
					'css-loader'
				]
			},
			{
				test: /\.scss$/,
				use: [
					'vue-style-loader',
					'css-loader',
					'sass-loader'
				]
			},
			{
				test: /\.vue$/,
				loader: 'vue-loader'
			},
			{
				test: /\.js$/,
				loader: 'babel-loader',
				exclude: /node_modules/
			},
			{
				test: /\.(png|jpg|gif|svg)$/,
				loader: 'file-loader',
				options: {
					name: '[name].[ext]?[hash]'
				}
			},
		]
	},
	plugins: [new VueLoaderPlugin()],
	resolve: {
		alias: {
			vue$: 'vue/dist/vue.esm.js'
		},
		extensions: ['*', '.js', '.vue', '.json']
	}
};
