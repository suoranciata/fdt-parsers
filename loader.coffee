#!/usr/bin/env coffee

get = (resource, callback) ->
    (require 'http').get
        host : 'www.forumdeitroll.it'
        port : 80
        path : resource
        headers :
            Cookie: 'PITROOL_DISCLAIMER=1'
    , (res) ->
        chunks = []
        res.on 'data', (data) ->
            chunks.push data
        res.on 'end', () ->
            body = chunks.map ((buf) ->
                buf.toString 'utf8')
            .join ''
            callback(body)

util = require 'util'

parsers =
    panel : (require './parsers/panel')
    m     : (require './parsers/m.aspx')
    HTM   : (require './parsers/HTM.aspx')
    HT    : (require './parsers/HT.aspx')

get '/', (body) ->
    panel = parsers.panel.parse body
    for thread in panel.threads
        get "/HTM.aspx?m_id=#{thread.m_id}", (body) ->
            maintree = parsers.HTM.parse body
            console.log util.inspect maintree, no, 5
            for risposta in maintree.risposte
                if risposta.haSubTree
                    get "/HT.aspx?m_id=#{risposta.m_id}", (body) ->
                        console.log "parse: #{risposta.m_id}"
                        subtree = parsers.HT.parse body
                        console.log util.inspect subtree, no, 10