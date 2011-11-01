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
    panel : require './panel'
    m     : require './m.aspx'
    HTM   : require './HTM.aspx'
    HT    : require './HT.aspx'
    forum : require './forum'



#get '/', (body) ->
#    panel = parsers.panel.parse body
#    console.log util.inspect panel.threads[0]
#    first = panel.threads[0].m_id
#    get "/m.aspx?m_id=#{first}", (body) ->
#        post = parsers.m.parse body
#        console.log util.inspect post
#        get "/HTM.aspx?m_id=#{first}", (body) ->
#            tree = parsers.HTM.parse body
#            console.log util.inspect tree
#            if tree.risposte
#                for risposta in tree.risposte
#                    if risposta.haSubTree
#                        get "/HT.aspx?m_id=#{risposta.m_id}", (body) ->
#                            console.log util.inspect (parsers.HT.parse body), no, 15
#                        break

get '/hp.aspx?f_id=3868', (body) ->
    console.log util.inspect parsers.forum.parse body