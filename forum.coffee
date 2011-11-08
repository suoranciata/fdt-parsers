rePager = /class="fh3" align="center" width="100%"> Pagina <b>(\d+)<\/b> di <b>(\d+)<\/b> - <b>\d+<\/b>/
reForumLine = /m\.aspx/
reThreadSplitter = /<\/div><\/div><div class='separator'>&nbsp;<\/div><div class='divcont2?'><div class='divthread' >/g



parse = (body) ->
	forum =
		threads : []
		pagina : 0
		nPagine : 0
	for line in body.split /[\r\n]/
		continue if line is ''
		match = line.match rePager
		if match
			forum.pagina = match[1]
			forum.nPagine = match[2]
			break
		else
			match = line.match reForumLine
			if match
				parts = line.split reThreadSplitter
				for part in parts
					thread = {}
					thread.m_id = (part.match /m\.aspx\?m_id=(\d+)/)[1]
					thread.titolo = (part.match /class='(textcapothread|txtcapotvisited)'>(.{1,40})<\/a> \(media: \d+\)/)[2]
					haRisposte = part.match /OCThread/
					if haRisposte
						match = part.match /Apri ramo'><\/a>\((\d+)\) (.{1,20}) (il \d+\/\d+\/\d+|alle)( \d+\.\d+)<\/div>/
						thread.nRisposte = match[1]
						thread.autore = match[2]
						thread.data = match[3] + match[4]
						thread.ultimo = {}
						match= part.match /Ultimo: &nbsp;<a href='m\.aspx\?m_id=(\d+)&amp;m_rid=0' title='Leggi messaggio' class='nick'>(.{1,20})<span class='data'> (il \d+\/\d+\/\d+|alle)( \d+\.\d+)<\/span>/
						thread.ultimo.m_id = match[1]
						thread.ultimo.autore = match[2]
						thread.ultimo.data = match[3] + match[4]
					else
						match = part.match /alt=''>(.{1,20}) (il \d+\/\d+\/\d+|alle)( \d+\.\d+)<\/div>/
						thread.autore = match[1]
						thread.data = match[2] + match[3]
					forum.threads.push thread
	return forum


exports.parse = parse


