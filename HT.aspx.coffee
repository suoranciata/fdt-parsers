

reTables = /<tr valign='top'>(.*?)<\/tr>/g
reMidAutoreData = /<a href='m\.aspx\?m_id=(\d+)&amp;m_rid=0' class='nick' title='Leggi messaggio'\s?>(.*?)\s?<span class='data'> (il \d+\/\d+\/\d+|alle)( \d+\.\d+)<\/span><\/a>/
#struttura del sub-alberino
#3 trasp.gif per la prima risposta
#un link.gif se ha fratelli
#un linkpass è come un trasp (sarebbe il | quando sotto ci sono fratelli di un padre)
#un lastlink sta prima del link
reImmys = /images\/(trasp|link|linkpass|lastlink)\.gif/g

parse = (page) ->
	parts = page.match reTables
	subtree =
		childs : []
	post = null
	parent = subtree
	for part in parts
		match = part.match reMidAutoreData
		current =
			m_id : match[1]
			autore : match[2]
			data : match[3] + match[4]
			childs : []
		immys = part.match reImmys
		current.nImmys = immys.length
		current.lastImmy = immys[immys.length-1]
		if not post
			#primo
			subtree.childs.push current
			post = current
			parent = subtree
		else if post.lastImmy is 'images/link.gif' and post.nImmys is current.nImmys
			#fratello di post
			parent.childs.push current
			post = current
		else if current.lastImmy is 'images/lastlink.gif' and (post.nImmys+1) is current.nImmys
			#figlio di post
			post.childs.push current
			parent = post
			post = current
		else if post.nImmys > current.nImmys
			#fratello di un parent - cerca il parent giusto
			count = post.nImmys - current.nImmys
			parent = subtree
			post = subtree.childs[subtree.childs.length-1]
			while count > 0
				parent = post
				post = post.childs[post.childs.length-1]
				count--
			parent.childs.push current
	return subtree

exports.parse = parse