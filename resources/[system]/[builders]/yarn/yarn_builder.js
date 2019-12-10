const path = require('path');
const fs = require('fs');
const child_process = require('child_process');
let buildingInProgress = false;
let currentBuildingModule = '';

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
		let buildYarn = async () => {
			while (buildingInProgress) {
				console.log(`yarn is busy by another process: we are waiting to compile  ${resourceName}`);
				await sleep(3000);
			}
			buildingInProgress = true;
			currentBuildingModule = resourceName;
			const process = child_process.fork(
				require.resolve('./yarn_cli.js'),
				['install', '--ignore-scripts'],
				{
					cwd: path.resolve(GetResourcePath(resourceName))
				});

			process.on('exit', (code, signal) => {
				setImmediate(() => {
					if (code != 0 || signal) {
						buildingInProgress = false;
						currentBuildingModule = '';
						cb(false, 'yarn failed!');
						return;
					}

					const resourcePath = GetResourcePath(resourceName);
					const yarnLock = path.resolve(resourcePath, 'yarn.lock');

					try {
						fs.utimesSync(yarnLock, new Date(), new Date());
					} catch (e) {

					}

					buildingInProgress = false;
					currentBuildingModule = '';
					cb(true);
				});
			});
		};
		buildYarn().then();
	}
};

function sleep(ms) {
	return new Promise(resolve => setTimeout(resolve, ms));
}
RegisterResourceBuildTaskFactory('yarn', () => yarnBuildTask);
