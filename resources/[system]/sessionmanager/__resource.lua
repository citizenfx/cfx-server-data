resource_manifest_version '77731fab-63ca-442c-a67b-abc70f28dfa5'

server_scripts {
  'server/host_lock.lua',
  'shared/resource_monitor.lua'
}

server_export 'isResourceRunning'