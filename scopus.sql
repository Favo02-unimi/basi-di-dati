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

-- 9. trovare le pubblicazioni con il maggior numero di keyword associate
WITH max_keywords AS (
  SELECT k.pubid, count(*) AS count
  FROM publications.keyword AS k
  GROUP BY k.pubid
)
SELECT mk.pubid
FROM max_keywords AS mk
HAVING mk.count = max(mk.count)

-- 10. trovare tutte le expertise da cui discende conceptual design
WITH RECURSIVE parents AS (

  -- non-recursive term
  SELECT e1.parent_field
  FROM publications.expertise AS e1
  WHERE e1.field = 'conceptual design'

    UNION

  -- recursive term
  SELECT e2.parent_field
  FROM publications.expertise AS e2
  INNER JOIN parents AS p
  ON p.parent_field = e2.field

)
SELECT * FROM parents;

-- 11. trovare le pubblicazioni X con citazioni superiori alla media considerando le pubblicazioni della rivista di X
WITH avg_cit AS (
  SELECT p.pubname, avg(p.citedby) AS avg
  FROM publications.publication AS p
  GROUP BY p.pubname
)
SELECT p.id
FROM publications.publication AS p
WHERE p.citedby > (
  SELECT avg
  FROM avg_cit AS ac
  WHERE ac.pubname = p.pubname
)

WITH avg_cit AS (
  SELECT p.pubname, avg(p.citedby) AS avg
  FROM publications.publication AS p
  GROUP BY p.pubname
)
SELECT p.id
FROM publications.publication AS p
INNER JOIN avg_cit AS ac ON ac.pubname = p.pubname
WHERE p.citedby > ac.avg

-- 12. trovare i co-autori di montanelli stefano (autori di pubblicazioni in cui montanelli stefano è autore)
SELECT DISTINCT authid
FROM publications.pub_author AS pa
INNER JOIN publications.author AS a
WHERE a2.name != 'Stefano'
AND a2.surname != 'Montanelli'
AND EXISTS (
  SELECT *
  FROM publications.pub_author AS pa2
  INNER JOIN publications.author AS a2
  WHERE  pa.pubid = pa2.pubid
  AND a2.name = 'Stefano'
  AND a2.surname = 'Montanelli'
)

SELECT DISTINCT a2.*
FROM publications.author AS a1
INNER JOIN publications.pub_author AS pa1 ON a1.authid = pa1.authid 
INNER JOIN publications.pub_author pa2 ON pa1.pubid = pa2.pubid 
INNER JOIN publications.author a2 ON pa2.authid = a2.authid
AND a1.name != 'Stefano' AND a1.surname != 'Montanelli'
AND a2.name = 'Stefano' AND a2.surname = 'Montanelli'

-- 13. trovare le keyword usate solo sulla rivista 'information and computer security'
SELECT k.keyword
FROM publications.keyword AS k
WHERE NOT EXISTS (
	SELECT *
	FROM publications.keyword AS k2
  INNER JOIN publications.publication AS p on p.id = k.pubid
	WHERE k2.keyword = k.keyword
  AND p.pubname != 'information and computer security'
)

-- 14. trovare la keyword usata il maggior numero di volte
WITH keyword_count AS (
  SELECT keyword, count(*) AS count
  FROM publications.keyword AS k
  GROUP BY keyword
), max_keyword AS (
  SELECT max(kc.count) AS max
  FROM keyword_count AS kc
)
SELECT kc2.keyword
FROM keyword_count AS kc2
WHERE kc2.count = (SELECT mk.max FROM max_keyword AS mk)

-- 15. trovare gli autori che non pubblicano con persone appartenenti alla medesima affiliazione
SELECT pa.authid
FROM publications.pub_author AS pa
WHERE NOT EXISTS (
  SELECT *
  FROM publications.pub_author AS pa2
  WHERE pa.pubid = pa2.pubid
  AND pa.authid != pa2.authid
  AND pa.afid = pa2.afid
)
