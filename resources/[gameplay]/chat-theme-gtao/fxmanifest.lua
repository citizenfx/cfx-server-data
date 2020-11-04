-- This resource is part of the default FiveM/RedM resource pack (aka cfx-server-data)
-- Modifying or rewriting this resource for local use only is strongly discouraged.

version '1.0.0'
author 'The CitizenFX Collective'
description 'A GTA Online theme for the included default chat resource.'
repository 'https://github.com/citizenfx/cfx-server-data'

file 'style.css'
file 'shadow.js'

chat_theme 'gtao' {
    styleSheet = 'style.css',
    script = 'shadow.js',
    msgTemplates = {
        default = '<b>{0}</b><span>{1}</span>'
    }
}

game 'common'
fx_version 'adamant'