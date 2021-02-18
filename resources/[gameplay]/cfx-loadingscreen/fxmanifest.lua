fx_version 'cerulean'
games { 'rdr3', 'gta5' }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

version '1.0.0'
author 'Cfx.re <root@cfx.re> & @Mackgame4'
description 'Provides baseline chat functionality using a NUI-based interface.'
repository 'https://github.com/citizenfx/cfx-server-data'


files {
    'assets/images/bg.jpg',
    'assets/images/bgpat.png',
    'assets/images/citizen_cursor.png',
    'data/changelog.js',
    'data/tips.js',
    'index.html',
    'style.css',
    'script.js',
    'lib/vue.min.js',
    'lib/lodash.js'
}

loadscreen 'index.html'
