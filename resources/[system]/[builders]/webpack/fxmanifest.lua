-- This resource is part of the default FiveM/RedM resource pack (aka cfx-server-data)
-- Modifying or rewriting this resource for local use only is strongly discouraged.

version '1.0.0'
author 'The CitizenFX Collective'
description 'Builds resources with webpack. To know more: https://webpack.js.org'
repository 'https://github.com/citizenfx/cfx-server-data'

dependency 'yarn'
server_script 'webpack_builder.js'

fx_version 'adamant'
game 'common'