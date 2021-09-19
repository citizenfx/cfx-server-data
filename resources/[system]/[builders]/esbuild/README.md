## Esbuilder

What is [esbuild](https://esbuild.github.io/)?
----
"esbuild - An extremely fast JavaScript bundler"
esbuild claims that the current build tools are 10-100x slower than what they really could be. They want to create a simple build API and lead the way for the new build tool era

Why [esbuild](https://esbuild.github.io/)?
----
- Because its extremly fast.
- Easy to use api
- Builtin TypeScript support (no need for an extra plugin)

Why not to use esbuild?
----
- In early development (some features may be buggy)
- Has a small community, therefore it is more difficult to find helpful resources if you ever get stuck

How-to use this resource
====
Using external .js files as configs
----
#### **fxmanifest.lua**
```lua
fx_version 'cerulean'
game 'common'


client_script 'dist/index.js'

esbuild_config 'build.js'
```
#### **build.js**
```js
module.exports = {
    entryPoints: [ 'src/main.ts' ],
    bundle: true,
    minify: true,
    outputFile: 'dist/index.js',
}
```

Embedding the config inside the fxmanifest
----
```lua
fx_version 'cerulean'
game 'common'


client_script 'dist/index.js'

esbuild 'label here' {
    entryPoints = { 'src/main.ts' },
    bundle = true,
    minify = true,
    outputFile = 'dist/index.js',
}
```

### For more information visit the [esbuild website](https://esbuild.github.io/) and check out the [documentation](https://esbuild.github.io/api/)