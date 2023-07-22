-- esercizio A: derivare lo schema ER del db scopus4ds (reverse engineering)

-- esercizio B: svolgere i seguenti esercizi di algebra relazionale e SQL

-- 1. conta il numero di pubblicazioni nel db
SELECT count(*)
FROM publications.publication

-- 2. quali sono i pubtype utilizzati nelle pubblicazioni
SELECT DISTINCT p.pubType
FROM publications.publication AS p

-- 3. trovare le keyword che non sono mai usate su pubblicazioni di tipo article
SELECT DISTINCT k.keyword
FROM publications.keyword AS k
WHERE not exists (
  SELECT *
  FROM publications.keyword AS k2
  INNER JOIN publications.publication AS p ON p.id = k2.pubid
  WHERE p.pubtype = 'article'
  AND k2.keyword = k.keyword
)

-- 4. trovare le keyword usate in tutte le pubblicazioni della rivista 'computer communications'
SELECT k.keyword
FROM publications.keyword AS k
WHERE NOT EXISTS (
	SELECT *
	FROM publications.publication AS p
	WHERE p.pubname = 'computer communications'
	AND NOT EXISTS (
		SELECT *
		FROM publications.keyword AS k2
		WHERE k2.keyword = k.keyword
    AND k2.pubid = p.id
	)
)

-- 5. trovare le pubblicazioni che hanno sia 'social networks' sia 'community detection' come keyword
SELECT k.pubid
FROM publications.keyword AS k
WHERE k.keyword = 'social networks'
AND EXISTS (
  SELECT *
  FROM publications.keyword AS k2
  WHERE k2.keyword = 'community detection'
  AND k.pubid = k2.pubid
)

(SELECT k.pubid
FROM publications.keyword AS k
WHERE k.keyword = 'social networks')
INTERSECT 
(SELECT k.pubid
FROM publications.keyword AS k
WHERE k.keyword = 'community detection')

-- 6. trovare le pubblicazioni che hanno almeno una keyword in comune
SELECT DISTINCT k1.pubid, k2.pubid
FROM publications.keyword AS k1
INNER JOIN ON k1.keyword = k2.keyword
AND k1.pubid != k2.pubid

-- 7. trovare gli autori che partecipano a una pubblicazione con almeno due affiliazioni diverse
SELECT DISTINCT pa1.authid
FROM publications.pub_author AS pa1
INNER JOIN publications.pub_author AS pa2
ON (
  pa1.authid = pa2.authid AND
  pa1.pubid = pa2.pubid AND
  pa1.afid != pa2.afid
)

-- 8. trovare le pubblicazioni con citazioni superiori alla media considerando le pubblicazioni della rivista 'information and computer security'
WITH average AS (
  SELECT avg(p.citedby) as avg
  FROM publications.publication AS p
  WHERE p.pubname = 'information and computer security'
)
SELECT p.id
FROM publications.publication
WHERE p.pubname = 'information and computer security'
AND p.citedby > (select avg from average)


-- trovare le pubblicazioni con il maggior numero di keyword associate

-- trovare tutte le expertise da cui discende conceptual design

-- ulteriori esercizi

-- trovare le pubblicazioni X con citazioni superiori alla media considerando le pubblicazioni della rivista di X
-- inefficiente

-- trovare i co-autori di montanelli stefano (autori di pubblicazioni in cui montanelli stefano è autore)

-- trovare le keyword usate solo sulla rivista 'information and computer security'

-- Trovare la keyword usata il maggior numero di volte

-- trovare gli autori che non pubblicano con persone appartenenti alla medesima affiliazione
