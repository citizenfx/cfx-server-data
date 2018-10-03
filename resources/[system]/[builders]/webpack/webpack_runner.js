const weebpack = require('webpack');
const path = require('path');

module.exports = (inp, callback) => {
	const config = require(inp.configPath);
	
	config.context = inp.resourcePath;
	
	if (config.output && config.output.path) {
		config.output.path = path.resolve(inp.resourcePath, config.output.path);
	}
	
	weebpack(config, (err, stats) => {
		if (err) {
			callback(err);
			return;
		}
		
		if (stats.hasErrors()) {
			callback(null, stats.toJson());
			return;
		}
		
		callback(null, {});
	});
};