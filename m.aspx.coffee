
# varie regex m.aspx
reTitolo = /<!--titolo --><b>(.*)<\/b>/
reData = /<!-- data -->/
rePrecPresent = /<!--btnPrec -->/
rePrec = /<!--btnPrec --><a href=\'m.aspx\?m_id=(\d+)/
reSuccPresent = /<!--btnSucc -->/
reSucc = /<!--btnSucc --><a href=\'m.aspx\?m_id=(\d+)/
reNickname = /<!--nickname-->/
reNicknameNonAut = /<div class="csxItem">&nbsp;<b>non autenticato<\/b>/
reNicknameAut = /<div class="csxItem">&nbsp;<b><a href='\.\.\/cerca\.asp\?s=nick%3a%22.*%22' class='nick'>(.*)<\/a><\/b><\/div>/
reAvatarPresent = /<!--avatar-->/
reAvatarAut = /<div class="csxItem">&nbsp;<img src="(.*)" width=/
reTesto = /<!-- TESTO-->/
reTestoContent = /<DIV style="PADDING-RIGHT: 10px; PADDING-LEFT: 10px; FONT-SIZE: 0\.95em; PADDING-BOTTOM: 10px; PADDING-TOP: 10px">(.*)<\/DIV>/

stages =
    TITOLO : 0
    DATA : 1
    DATA_2 : 2
    PREC : 3
    SUCC : 4
    NICKNAME : 5
    NICKNAME_2 : 6
    NICKNAME_AVATAR : 7
    NICKNAME_AVATAR_2 : 8
    TESTO : 9
    TESTO_2 : 10
    END : 11

parse = (page) ->
    result =
        titolo : null
        data : null
        prec : null
        succ : null
        nickname : null
        autenticato : null
        avatar : null
        testo : null
    ctx =
        stage : stages.TITOLO
    for line in (page.split /[\n\r]/)
        continue if line.trim() is ''
        switch ctx.stage
            when stages.TITOLO
                if reTitolo.test line
                    result.titolo = (line.match reTitolo)[1]
                    ctx.stage++
            when stages.DATA
                if reData.test line
                    ctx.stage++
            when stages.DATA_2
                result.data = line.trim()
                ctx.stage++
            when stages.PREC
                if rePrecPresent.test line
                    match = line.match rePrec
                    result.prec = match[1] if match
                    ctx.stage++
            when stages.SUCC
                if reSuccPresent.test line
                    match = line.match reSucc
                    result.succ = match[1] if match
                    ctx.stage++
            when stages.NICKNAME
                if reNickname.test line
                    ctx.stage++
            when stages.NICKNAME_2
                if reNicknameNonAut.test line
                    result.nickname = 'non autenticato'
                    result.autenticato = false
                else
                    result.nickname = (line.match reNicknameAut)[1]
                    result.autenticato = true
                ctx.stage++
            when stages.NICKNAME_AVATAR
                if not result.autenticato
                    ctx.stage++
                else if reAvatarPresent.test line
                    ctx.stage++
            when stages.NICKNAME_AVATAR_2
                if not result.autenticato
                    ctx.stage++
                else
                    match = line.match reAvatarAut
                    result.avatar = match[1] if match
                    ctx.stage++
            when stages.TESTO
                if reTesto.test line
                    ctx.stage++
            when stages.TESTO_2
                result.testo = (line.match reTestoContent)[1] if reTestoContent.test line
                result.testo = line if not result.testo
                ctx.stage++
        if ctx.stage is stages.END
            break
    return result

exports.parse = parse
