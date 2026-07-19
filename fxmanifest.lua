fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'bsrp-banking'
author 'BS Race'
description 'BSRP futuristic banking — ATMs, Fleeca banks, deposit/withdraw/transfer'
version '1.0.0'

ui_page 'html/index.html'

shared_script 'config.lua'

client_script 'client/main.lua'
server_script 'server/main.lua'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
}

-- Soft framework: exports.bsrp when started (no hard dep)

