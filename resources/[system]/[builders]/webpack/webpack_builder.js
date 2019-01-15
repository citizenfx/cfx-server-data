const fs = require('fs');
const path = require('path');
const workerFarm = require('worker-farm');
const async = require('async');

const webpackBuildTask = {
	shouldBuild(resourceName) {
		const numMetaData = GetNumResourceMetadata(resourceName, 'webpack_config');
		
		if (numMetaData > 0) {
			for (let i = 0; i < numMetaData; i++) {
				const configName = GetResourceMetadata(resourceName, 'webpack_config');

				if (shouldBuild(configName)) {
					return true;
				}
			}
		}
		
		return false;

		function loadCache(config) {
			const cachePath = `cache/${resourceName}/${config.replace(/\//g, '_')}.json`;
	
			try {
				return JSON.parse(fs.readFileSync(cachePath, { encoding: 'utf8' }));
			} catch {
				return null;
			}
		}
	
		function shouldBuild(config) {
			const cache = loadCache(config);
	
			if (!cache) {
				return true;
			}
	
			for (const file of cache) {
				const stats = getStat(file.name);
	
				if (!stats ||
					stats.mtime !== file.stats.mtime ||
					stats.size !== file.stats.size ||
					stats.inode !== file.stats.inode) {
					return true;
				}
			}
	
			return false;
		}
		
		function getStat(path) {
			try {
				const stat = fs.statSync(path);
	
				return stat ? {
					mtime: stat.mtimeMs,
					size: stat.size,
					inode: stat.ino,
				} : null;
			} catch {
				return null;
			}
		}
	},
	
	build(resourceName, cb) {
		const configs = [];
		const numMetaData = GetNumResourceMetadata(resourceName, 'webpack_config');
		
		for (let i = 0; i < numMetaData; i++) {
			configs.push(GetResourceMetadata(resourceName, 'webpack_config', i));
		}
	
		async.forEachOf(configs, (configName, i, acb) => {
			const configPath = GetResourcePath(resourceName) + '/' + configName;

			const cachePath = `cache/${resourceName}/${configName.replace(/\//g, '_')}.json`;

			try {
				fs.mkdirSync(path.dirname(cachePath));
			} catch {}
			
			const config = require(configPath);
			
			const workers = workerFarm(require.resolve('./webpack_runner'));
			
			if (config) {
				const resourcePath = path.resolve(GetResourcePath(resourceName));
			
				workers({
					configPath,
					resourcePath,
					cachePath
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

					console.log(`${resourceName}: built ${configName}`);
					
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
				
				cb(true);
			});
		});
	}
}

RegisterResourceBuildTaskFactory('z_webpack', () => webpackBuildTask);