-- SELEZIONARE TUTTE LE PERSONE CHE NON HANNO MAI RECITATO IN UN FILM
create or replace view imdb.tutti_attori as
select person as id from imdb.crew as c
where c.p_role = 'actor';

create or replace view persone_mai_recitato as
select id from imdb.person p except (
	select id from imdb.tutti_attori
);

select * from persone_mai_recitato;


--SELEZIONARE LE PELLICOLE PRODOTTE SOLO IN ITALIA:
create or replace view imdb.prodotti_anche_italia as
select p.movie as id from imdb.produced as p
where p.country = 'ITA';

create or replace view imdb.prodotti_non_italia as
select p.movie as id from imdb.produced as p
where p.country != 'ITA';

create or replace view imdb.prodotti_solo_italia as
select id from imdb.prodotti_anche_italia except (
	select id from imdb.prodotti_non_italia
);

select pi.id, pr.country from imdb.prodotti_solo_italia as pi
inner join imdb.produced as pr on pi.id = pr.movie;


--SELEZIONARE I PAESI NEI QUALI NON SONO PRODOTTI FILM:
create or replace view imdb.tutti_paesi as
select iso3 as id from imdb.country;

select id from imdb.tutti_paesi
except (
	select country as id from imdb.produced	
);


--SELEZIONARE I PAESI NEI QUALI SONO PRODOTTI FILM:
select distinct country from imdb.produced;

--ESTRARRE IL NUMERO DI FILM PRODOTTI IN ITALIA:
select count(*) from imdb.produced as p
where p.country = 'ITA';

select p.country, count(*) from imdb.produced as p group by p.country;

--RESTITUIRE IL NUMERO DI PELLICOLE PER LE QUALI È NOTO IL TITOLO DEL FILM:
select count(*) from imdb.movie as m where m.official_title is not null; 

--RESTITUIRE IL NUMERO DI PELLICOLE PER LE QUALI È NOTO L'ANNO DI PRODUZIONE:
select count(*) from imdb.movie as m where m.year is not null; 

--RESTITUIRE I FILM (CON ID E TITOLO) CON DURATA MAGGIORE DI QUELLA DI INCEPTION:
create or replace view imdb.inception_length as
select m.length from imdb.movie as m
where m.official_title = 'Inception';

select m.id, m.official_title, m.length from imdb.movie as m
where m.length > all (
	select length from imdb.inception_length
);

insert into imdb.movie values(1000000, 'Inception', 1, 2023, 300, 'puffi');

--RESTITUIRE IL NUMERO DI PELLICOLE PER OGNI ANNO DISPONIBILE:
select m.year, count(*) from imdb.movie as m
group by m.year
having m.year is not null
order by m.year asc;

--RESTITUIRE IL NUMERO DI PELLICOLE PER OGNI ANNO A PARTIRE DAL 2014:
select m.year, count(*) from imdb.movie as m
group by m.year
having m.year is not null and m.year >= '2014'
order by m.year asc;

--RESTITUIRE LA DURATA MEDIA DELLE PELLICOLE PER OGNI ANNO:
select m.year, avg(m.length) from imdb.movie as m
where m.length is not null
group by m.year
having m.year is not null
order by m.year asc;

--RESTITUIRE IL NUMERO DI PERSONE PER RUOLO:
select c.p_role, count(*) from imdb.crew as c
group by c.p_role;

--RESTITUIRE PER CIASCUN FILM IL NUMERO DI PERSONE COINVOLTE IN CIASCUN RUOLO:
select m.official_title, c.p_role, count(*) from imdb.crew as c
join imdb.movie as m on c.movie = m.id  
group by c.p_role, m.official_title
order by m.official_title;
