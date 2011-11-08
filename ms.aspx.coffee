rePager = /Pagina <b>(\d+)<\/b> di <b>(\d+)<\/b>/
reSplitter = /<!-- tabella contenuto-->/

parse = (body) ->
    msgs = body.split reSplitter
    result =
    	pagina : 1
    	nPagine : 1
    	posts : []
    for line in msgs[0].split /[\n\r]/
    	match = line.match rePager
    	if match
    		result.pagina = parseInt match[1], 10
    		result.nPagine = parseInt match[2], 10
    		break
    for msg in msgs.slice 1
        oneline = msg.replace /[\n\r]/,' '
        post = {}
        post.titolo = (oneline.match /<!--titolo -->[\s\t]+<b>[\s\t]+(.{1,80})<\/b>[\s\t]+<!-- data -->/)[1].trim()
        post.data = (oneline.match /<!-- data -->[\s\t]+del[\s\t]+(\d+\s\w+\s\d+\s\d+\.\d+)[\s\t]+<\/td>/)[1]
        post.m_id = (oneline.match /A\shref='r\.aspx\?m_id=(\d+)&amp;/)[1]
        match = oneline.match /class='nick'>(.{1,30})<\/a/
        if match
            post.autore = match[1]
        post.testo = (oneline.match /<!-- TESTO-->[\s\t]+<div style="PADDING:10px;FONT-SIZE:0.95em;">[\s\t]+(.{1,10000})<\/div>/)[1]
        result.posts.push post
    return result

exports.parse = parse
