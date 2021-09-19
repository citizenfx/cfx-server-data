function DebugPrint(label, message, resource) {
    switch(label.toLowerCase()) {
        case 'error':
            label = `^1${label}^7`;
            break;
        case 'warning':
            label = `^3${label}^7`;
            break;
        case 'info':
            label = `^4${label}^7`;
            break;
    }
    console.log(`[^5esbuilder^7] [${resource ? `${resource}:` : ''}${label}] ${message}^7`)
}

// Get the path or internal config from a resource fxmanifest.lua file
function getResourceConfigs(resourceName) {
    let configs = [];
    let resourcePath = GetResourcePath(resourceName);
    // Get embedded configs
    for(let i = 0; i < GetNumResourceMetadata(resourceName, 'esbuild'); i++) {
        let embeddedConfig = JSON.parse(GetResourceMetadata(resourceName, 'esbuild_extra', i));
        if(embeddedConfig != null) {
            configs.push({
                label: GetResourceMetadata(resourceName, 'esbuild', i),
                type:'embedded',
                path: path.resolve(resourcePath, 'fxmanifest.lua'),
                value: embeddedConfig
            });
        }
    }
    // Get the config paths
    for(let i = 0; i < GetNumResourceMetadata(resourceName, 'esbuild_config'); i++) {
        
        let configPath = GetResourceMetadata(resourceName, 'esbuild_config', i);
        if (fs.existsSync(path.resolve(resourcePath,configPath))) {
            try {
                let configData = require(path.resolve(resourcePath,configPath));
                if(!!configData) {
                    configs.push({
                        label:configPath,
                        type:'external',
                        path: path.resolve(resourcePath,configPath),
                        value:configData
                    });
                }
            } catch(e) {
                console.log(e);
            }
        } else {
            DebugPrint('error', `Could not find the build config file: ${configPath}`, resourceName);
        }
    }
    return configs;
}

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

module.exports = {DebugPrint, getResourceConfigs, getFileStat};