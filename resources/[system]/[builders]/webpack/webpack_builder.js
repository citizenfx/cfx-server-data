const path = require('path');
const workerFarm = require('worker-farm');
const async = require('async');

const justBuilt = {};

const webpackBuildTask = {
	shouldBuild(resourceName) {
		const numMetaData = GetNumResourceMetadata(resourceName, 'webpack_config');
		
		if (numMetaData > 0) {
			if (!(resourceName in justBuilt)) {
				return true;
			}
			
			delete justBuilt[resourceName];
		}
		
		return false;
	},
	
	build(resourceName, cb) {
		const configs = [];
		const numMetaData = GetNumResourceMetadata(resourceName, 'webpack_config');
		
		for (let i = 0; i < numMetaData; i++) {
			configs.push(GetResourceMetadata(resourceName, 'webpack_config', i));
		}
	
		async.forEachOf(configs, (configName, i, acb) => {
			const configPath = GetResourcePath(resourceName) + '/' + configName;
			
			const config = require(configPath);
			
			const workers = workerFarm(require.resolve('./webpack_runner'));
			
			if (config) {
				const resourcePath = path.resolve(GetResourcePath(resourceName));
			
				workers({
					configPath,
					resourcePath
				}, (err, outp) => {
					workerFarm.end(workers);
				
					if (err) {
						console.error(err.stack || err);
						if (err.details) {
							console.error(err.details);
						}
					
						acb("worker farm webpack errored out");
						return;
					}
					
					if (outp.errors) {
						for (const error of outp.errors) {
							console.log(error);
						}
						acb("webpack got an error");
						return;
					}
					
					acb();
				});
				
				return;
			}
			
			acb("no configuration");
		}, (err) => {
			setImmediate(() => {
				if (err) {
					cb(false, err);
					return;
				}
				
				justBuilt[resourceName] = true;
				
				cb(true);
			});
		});
	}
}

RegisterResourceBuildTaskFactory('z_webpack', () => webpackBuildTask);