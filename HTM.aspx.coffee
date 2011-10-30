# per alberino indentato in console
#curl -H 'Cookie: PITROOL_DISCLAIMER=1' 'http://www.forumdeitroll.it/HTM.aspx?m_id=XXXXXXX' | tidy -i

reHeaderTitolo = /class='(textcapothread|txtcapotvisited)'>(.*?)</
reHeaderMid = /<a href='m\.aspx\?m_id=(\d+)&amp;m_rid=0' title='Leggi messaggio'/
reHeaderNRAD = /<\/a>\((\d+)\) (.{1,30}) (il \d+\/\d+\/\d+|alle)( \d+\.\d+) - voto: \d+/
reHeaderNRAD2 = /class='dotto' alt=''>(.{1,30}) (il \d+\/\d+\/\d+|alle)( \d+\.\d+) - voto: \d+/
reTabelle = /<table.*?<\/table>/g
reRisposteConSubTree = /javascript:OCMsg\(this,'(\d+)','0'\)/
reMidAutoreData = /<a href='m\.aspx\?m_id=(\d+)&amp;m_rid=0' class='nick' title='Leggi messaggio'\s?>(.*?)<span class='data'> (il \d+\/\d+\/\d+|alle)( \d+\.\d+)<\/span><\/a>/

# alberino principale
parse = (page) ->
	match = page.match reHeaderTitolo
	result =
		op :
			titolo : match[2]
		risposte : []
	result.op.m_id = (page.match reHeaderMid)[1]
	match = page.match reHeaderNRAD
	if match
		result.op.nRisposte = match[1]
		result.op.autore = match[2]
		result.op.data = match[3] + match[4]
	else
		match = page.match reHeaderNRAD2
		result.op.nRisposte = 0
		result.op.autore = match[1]
		result.op.data = match[2] + match[3]
	match = page.match reTabelle
	if match
		for table in match
			match2 = table.match reRisposteConSubTree
			risposta = {}
			if match2
				risposta.haSubTree = yes
				match2 = table.match reMidAutoreData
				risposta.m_id = match2[1]
				risposta.autore = match2[2]
				risposta.data = match2[3] + match2[4]
			else
				risposta.haSubTree = no
				match2 = table.match reMidAutoreData
				risposta.m_id = match2[1]
				risposta.autore = match2[2]
				risposta.data = match2[3] + match2[4]
			result.risposte.push risposta
	return result
	

exports.parse = parse
