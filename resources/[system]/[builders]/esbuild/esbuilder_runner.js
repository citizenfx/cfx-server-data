const esbuild = require('esbuild');
const fs = require('fs-extra');

function getFileStat(path) {
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


let cache = [];

class EsbuilderCache {
    constructor(inp) {
        this.name = "cfx-esbuilder-cache";
        // Update the cache
        cache.push({
            path:inp.config.path,
            stat:getFileStat(inp.config.path),
        });
    }

    setup(build) {
        build.onLoad({filter:/.*/s}, args => {
            cache.push({
                path:args.path,
                stat:getFileStat(args.path),
            });
        });
    }
}



module.exports = async (input, cb) => {

    const {config, resourcePath, cachePath} = input;
    const {value:options} = config;

    // Disable file watching
    options.watch = false;
    // Set the working directory to the resourcePath
    options.absWorkingDir = resourcePath;

    // Add the cache plugin
    if (!Array.isArray(options.plugins)) options.plugins = [];
    const plugin = new EsbuilderCache(input);
    options.plugins.push(plugin);

    // Run the build configuration
    try {
        let result = await esbuild.build(options);
        fs.outputFileSync(cachePath, JSON.stringify(cache));
        cb(null, result);
    } catch(e) {
        console.log(e);
        cb(e);
    }
}