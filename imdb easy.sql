-- TROVARE TUTTI I FILM SIMILI A INCEPTION
WITH id_inception AS (
	select m.id from imdb.movie as m
	where m.official_title = 'Inception'
),
simil1 AS (
	select s.movie1 from imdb.sim as s
	where s.movie2 in (select id from id_inception)
),
simil2 AS (
	select s.movie2 from imdb.sim as s
	where s.movie1 in (select id from id_inception)
) -- in opposto di all, almeno un record della subquery (in caso subquery > 1 record)
select * from (
	select * from simil1 as s1
		union
	select * from simil2 as s2
) as s;

-- soluzione 2
WITH inc1 AS (
	SELECT s.movie1, s.movie2, m.official_title
	FROM imdb.sim AS s
	JOIN imdb.movie AS m
	ON s.movie1 = m.id
),
inc2 AS (
	SELECT s.movie1, s.movie2, m.official_title
	FROM imdb.sim AS s
	JOIN imdb.movie AS m
	ON s.movie2 = m.id
)
SELECT i1.movie2
FROM inc1 AS i1
WHERE i1.official_title = 'Inception'
UNION (
	SELECT i2.movie1
	FROM inc2 AS i2
	WHERE i2.official_title = 'Inception'
);

-- soluzione 3
select sim.*, m2.official_title
from imdb.movie
inner join imdb.sim on movie.id = sim.movie1
inner join imdb.movie m2 on sim.movie2 = m2.id
where movie.official_title = 'Inception';


-- SELEZIONARE I FILM CHE NON SONO STATI DISTRIBUITI NEI PAESI NEI QUALI SONO STATI PRODOTTI
select m.id
from imdb.movie as m
except
select m.id
from imdb.movie as m
inner join imdb.produced as p on p.movie = m.id
where exists (
	select * from imdb.released as r
	where r.movie = m.id and r.country = p.country
)

-- SELEZIONARE I FILM NEL CUI CAST NON FIGURANO ATTORI NATI IN PAESI DOVE IL FILM È STATO PRODOTTO
select m.id
from imdb.movie as m
where not exists (
	select cr.person, lo.country
	from imdb.crew as cr
	inner join imdb.location as lo on lo.person = cr.person
	where lo.d_role = 'B'
	and cr.p_role = 'actor'
	and cr.movie = m.id
	and exists (
		select * from imdb.produced as pr
		where pr.movie = m.id
		and pr.country = lo.country
	)
)

-- SELEZIONARE I FILM CHE SONO STATI DISTRIBUITI IN TUTTI I PAESI
select m.id
from imdb.movie as m
where not exists (
	select c.iso3
	from imdb.country as c
	where not exists (
		select *
		from imdb.released as r
		where r.movie = m.id and r.country = c.iso3
	)
)

-- SELEZIONARE I FILM CON CAST PIÙ NUMEROSO DELLA MEDIA DEI FILM DEL MEDESIMO GENERE

-- per ogni film associare genere e numero di crew
with film_crew_genre as (
	select g.genre, c.movie, count(c.*) as count
	from imdb.crew as c
	inner join imdb.genre as g on g.movie = c.movie
	group by g.genre, c.movie
),
-- raggruppare su genere e fare la media, per ogni genere si ha la media
genre_average as (
	select fcg.genre, avg(fcg.count) as avg
	from film_crew_genre as fcg
	group by fcg.genre
)
-- estrarre genere e count da ogni film (salvati nella prima vista)
-- joinare la seconda vista e filtrare dove count > avg
select fcg.movie, fcg.genre, fcg.count, ga.avg
from film_crew_genre as fcg
inner join genre_average as ga on fcg.genre = ga.genre
where fcg.count > ga.avg;


-- SELEZIONARE IL TITOLO DEI FILM CHE HANNO VALUTAZIONI (almeno una) SUPERIORI ALLA MEDIA DELLE VALUTAZIONI DEI FILM PRODOTTI NEL MEDESIMO ANNO
with year_rating as (
	select m.year, avg(r.score) as avg
	from imdb.rating as r
	inner join imdb.movie as m on m.id = r.movie
	group by m.year
)
select m.id, m.official_title, m.year, yr.avg
from imdb.movie as m
inner join year_rating as yr on yr.year = m.year
where exists (
	select * from imdb.rating as r
	where r.score > yr.avg and m.id = r.movie
)
order by m.year;



-- SELEZIONARE IL TITOLO DEI FILM CHE HANNO tutte le VALUTAZIONI SUPERIORI ALLA MEDIA DELLE VALUTAZIONI DEI FILM PRODOTTI NEL MEDESIMO ANNO

-- non è perfetta perchè conta anche dove l'anno è null
with year_rating as (
	select m.year, avg(r.score) as avg
	from imdb.rating as r
	inner join imdb.movie as m on m.id = r.movie
	group by m.year
)
select m.id, m.official_title, m.year, yr.avg
from imdb.movie as m
left join year_rating as yr on yr.year = m.year
where not exists (
	select * from imdb.rating as r
	where m.id = r.movie and r.score <= yr.avg 
)
order by m.official_title;


-- SELEZIONARE LE PERSONE CHE HANNO RECITATO IN TUTTI I FILM DI GENERE CRIME
select distinct c.person
from imdb.crew as c
inner join imdb.genre as g on g.movie = c.movie
where c.p_role = 'actor'
	and g.genre = 'Crime'
	and not exists (
		select m1.id
		from imdb.movie as m1
		where not exists (
			select *
			from imdb.crew as c2
			where c2.movie = m1.id and c2.person = c.person
		) 
	)

-- SELZIONARE FILM DOVE NON È PRESENTE UN ATTORE
select m.id, m.official_title
from imdb.movie as m
where not exists (
	select * from imdb.crew as c
	where c.movie = m.id and c.p_role = 'actor'
)
