reTitolo1 = /<a href='m\.aspx\?m_id=(\d+)' class='fh1' style='font-size:1\.25em; color: #0000EE;'>(.*?)<\/a>/
reTitolo2 = /\(<b>(\d+)<\/b>\)/
reTitolo3 = /<a href='\.\.\/cerca.asp\?s=nick%3a%22.*%22' class=\'nick\'>(.*)<\/a><\/b>/

reLastReply1 = /<div><img src='images\/trasp\.gif' border='0' alt=' ' class='dotto' style='padding-right: 3px;'>(di <b><a href='\.\.\/cerca\.asp\?s=nick%3a%22.*%22' class='nick'>(.*?)<\/a><\/b> )? (alle|del) (.*)<\/div>/
reLastReply2 = /<div><img src='images\/trasp\.gif' border='0' alt=' ' class='dotto' style='padding-right: 3px;'>Ultimo: <a href='m\.aspx\?m_id=(\d+)' class='fh1' style='font-size:1\.25em; color: #0000EE;'>(.*?)<\/a>( di <b><a href='\.\.\/cerca\.asp\?s=nick%3a%22.*%22' class='nick'>(.*?)<\/a><\/b>)?  (alle|del) (.*)<\/div>/

reSubforum = /<div><img src='images\/trasp\.gif' border='0' alt=' ' class='dotto' style='padding-right: 3px;'><a href='hp\.aspx\?m_id=\d+' style='color: green; font-weight: bold;'>(.*)<\/a><\/div>/
rePager = /<td style="FONT-SIZE:0.85em;PADDING-TOP:10px"> Pagina <b>(\d+)<\/b> di <b>(\d+)<\/b> - /
stages =
    T_TITOLO : 0
    T_LAST_REPLY : 1
    T_SUBFORUM : 2
    T_PAGER : 3
    END : 4

parse = (page) ->
    result =
        threads : []
    ctx =
        stage : stages.T_TITOLO
        t_current : {}
    for line in page.split /[\n\r]/
        continue if line.trim() is ''
        switch ctx.stage
            when stages.T_TITOLO
                if reTitolo1.test line
                    match = line.match reTitolo1
                    ctx.t_current.m_id = match[1]
                    ctx.t_current.titolo = match[2]
                    match = line.match reTitolo2
                    if match
                        ctx.t_current.n_reply = match[1]
                    match = line.match reTitolo3
                    if match
                        ctx.t_current.autore = match[1]
                    ctx.stage++
                else
                    if rePager.test line
                        match = line.match rePager
                        result.pagina = match[1]
                        result.nPagine = match[2]
                        ctx.stage = stages.END
            when stages.T_LAST_REPLY
                # questa riga contiene l'autore se autenticato e un solo messaggio
                # oppure il titolo dell'ultimo messaggio di #{autore} alle/del #{data}
                match = line.match reLastReply1
                if match
                    if not ctx.t_current.autore and match and match[2]
                        ctx.t_current.autore = match[2]
                    ctx.t_current.data = match[4]
                else
                    # thread con risposte
                    if not ctx.t_current.n_reply
                        throw new Error("FDTParseError: 01")
                    match = line.match reLastReply2
                    ctx.t_current.last = {}
                    ctx.t_current.last.titolo = match[2]
                    ctx.t_current.last.autore = match[4]
                    ctx.t_current.last.data = match[6]
                ctx.stage++
            when stages.T_SUBFORUM
                if reSubforum.test line
                    ctx.t_current.subforum = (line.match reSubforum)[1] if (line.match reSubforum)[1] isnt ''
                result.threads.push ctx.t_current
                if result.threads.length is 10
                    ctx.stage++
                    break #sondaggi ri-parsati a parte
                ctx.t_current = {}
                ctx.stage = stages.T_TITOLO
            when stages.T_PAGER
                if rePager.test line
                    match = line.match rePager
                    result.pagina = match[1]
                    result.nPagine = match[2]
                    ctx.stage++
            when stages.END
                break
    return result

exports.parse = parse
