fx_version 'adamant'
author 'c3'
description 'by c3'
lua54 'yes'

game 'gta5'

client_scripts {
    'config.lua',
    'client.lua'
}

server_scripts {
    'config.lua',
    'server.lua'
}

files {
    'gardener_en.sql',
    'gardener_blk.sql',
    'config.lua',
    'server.lua',
    'client.lua'
}

-- escrow_ignore {
   -- 'gardener_en.sql',
   -- 'gardener_blk.sql',
   -- 'config.lua',
   -- 'server.lua',
   -- 'client.lua'
 -- }

  dependency '/assetpacks'

