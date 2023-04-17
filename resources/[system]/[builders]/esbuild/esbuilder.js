const fs = require('fs');
const path = require('path');
const workerFarm = require('worker-farm');
const { getResourceConfigs, getFileStat } = require('./util');

let esbuild_configs = {};

const esbuildTask = {
    shouldBuild(resourceName) {
        let resourceConfigs = getResourceConfigs(resourceName);
        // Filter out all the configs that doesn't need to be built, based on the cache
        resourceConfigs = resourceConfigs.filter(config => {
            let cacheFile = path.resolve('cache/esbuild', resourceName, `cache_${config.label.toLowerCase().replace(/\//g, '-')}_config.json`);
            if (!fs.existsSync(cacheFile)) return true;
            let cache = JSON.parse(fs.readFileSync(cacheFile, 'utf8'));

            // Check the cache for file changes
            if(Array.isArray(cache)) {
                return cache.some(file => {
                    let fileStat = getFileStat(file.path);                    
                    return fileStat.mtime != file.stat.mtime ||
                            fileStat.inode != file.stat.inode ||
                            fileStat.size != file.stat.size;
                });
            }
            return false;
        });

        if (!resourceConfigs.length) return false;
        esbuild_configs[resourceName] = resourceConfigs;
        return true;
    },

    build(resourceName, cb) {
        (async () => {
            const promises = [];

            esbuild_configs[resourceName].forEach(config => {
                let promise = new Promise((resolve, reject) => {
                    const worker = workerFarm(require.resolve('./esbuilder_runner'));
                    worker({
                        config,
                        resourcePath: path.resolve(GetResourcePath(resourceName)),
                        cachePath: path.resolve('cache/esbuild', resourceName, `cache_${config.label.toLowerCase().replace(/\//g, '-')}_config.json`),
                    }, function(error, result) {
                        workerFarm.end(worker);
                        if (error) reject(error);
                        if (result) resolve(result);
                        return;
                    });
                });
                promises.push(promise);
            });

            await Promise.all(promises);

        })()
        .then(()=>cb(true))
        .catch(()=>cb(false));
    }
}

RegisterResourceBuildTaskFactory('esbuilder', ()=>esbuildTask);