const path = require('path');
const fs = require('fs');
const child_process = require('child_process');

const yarnBuildTask = {
	shouldBuild(resourceName) {
		try {
			const resourcePath = GetResourcePath(resourceName);
			
			const packageJson = path.resolve(resourcePath, 'package.json');
			const yarnLock = path.resolve(resourcePath, 'yarn.lock');
			
			const packageStat = fs.statSync(packageJson);
			
			try {
				const yarnStat = fs.statSync(yarnLock);
				
				if (packageStat.mtimeMs > yarnStat.mtimeMs) {
					return true;
				}
			} catch (e) {
				// no yarn.lock, but package.json - install time!
				return true;
			}
		} catch (e) {
			
		}
		
		return false;
	},
	
	build(resourceName, cb) {
		const process = child_process.fork(
			require.resolve('./yarn_cli.js'),
			['install'],
			{
				cwd: path.resolve(GetResourcePath(resourceName))
			});
			
		process.on('exit', (code, signal) => {
			setImmediate(() => {
				if (code != 0 || signal) {
					cb(false, 'yarn failed!');
					return;
				}
				
				const resourcePath = GetResourcePath(resourceName);
				const yarnLock = path.resolve(resourcePath, 'yarn.lock');
				
				try {
					fs.utimesSync(yarnLock, new Date(), new Date());
				} catch (e) {
				
				}
			
				cb(true);
			});
		});
	}
}

RegisterResourceBuildTaskFactory('yarn', () => yarnBuildTask);