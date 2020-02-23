--       Licensed under: AGPLv3        --
--  GNU AFFERO GENERAL PUBLIC LICENSE  --
--     Version 3, 19 November 2007     --

ip = GetConvar('es_couchdb_url', '127.0.0.1') 	        -- Change to wherever your DB is hosted, use convar
port = GetConvar('es_couchdb_port', '5984') 	        -- Change to whatever port you have CouchDB running on, use convar
auth = GetConvar('es_couchdb_password', 'root:1202') 	-- "user:password", if you have auth setup, use convar
metrics = GetConvar('es_enable_metrics', '1')           -- Change to '0' to disable metrics, no identifiable data is stored