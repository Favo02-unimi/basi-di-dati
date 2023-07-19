-- ESERCIZIO 1

-- ATTORI (CodAttore, Nome, AnnoNascita, Nazionalità);
-- RECITA (CodAttore*, CodFilm*)
-- FILM (CodFilm, Titolo, AnnoProduzione, Nazionalità, Regista, Genere)
-- PROIEZIONI (CodProiezione, CodFilm*, CodSala*, Incasso, DataProiezione)
-- SALE (CodSala, Posti, Nome, Città)

-- 1.1 Il nome di tutte le sale di Pisa
select s.nome
from sale as s
where s.città = 'Pisa'

-- 1.2 Il titolo dei film di F. Fellini prodotti dopo il 1960
select f.titolo
from film as f
where f.annoproduzione > 1960 and f.regista = 'F. Fellini'

-- 1.3 Il titolo e la durata dei film di fantascienza giapponesi o francesi prodotti dopo il 1990
select f.titolo, f.durata
from film as f
where f.genere = 'Fantascienza' and f.nazionalita 

-- 4- Il titolo dei film di fantascienza giapponesi prodotti dopo il 1990 oppure francesi
select f.titolo
from film as f
where (f.genere = 'Fantascienza' and f.nazionalita = 'Giapponese' and f.annoproduzione > 1990)
or f.nazionalita = 'Francese'

-- 1.5 I titolo dei film dello stesso regista di “Casablanca”
select f.titolo
from film as f
where f.regista in (
  select f2.regista
  from film as f2
  where f2.titolo = 'Casablanca'
)

-- 1.6 Il titolo ed il genere dei film proiettati il giorno di Natale 2004
select distinct f.titolo, f.genere
from film as f
inner join proiezioni as p on p.codFilm = f.codFilm
where p.dataProiezione = '25-12-2004';

-- 1.7 Il titolo ed il genere dei film proiettati a Napoli il giorno di Natale 2004
select f.titolo, f.genere
from film as f
inner join proiezioni as p on p.codFilm = f.codFilm
inner join sale as s on s.codSala = p.codSala
where p.dataProiezione = '25-12-2004' and s.citta = 'Napoli';

-- 1.8 I nomi delle sale di Napoli in cui il giorno di Natale 2004 è stato proiettato un film con R.Williams
select distinct s.nome
from sale as s
inner join proiezioni as p on p.codSala = s.codSala
inner join recita as r on r.codFilm = p.codFilm
inner join attori as a on a.codAttore = r.codAttore
where s.citta = 'Napoli'
and p.dataProiezione = '25-12-2004'
and a.nome = 'R.Williams'

-- 1.9 Il titolo dei film in cui recita M. Mastroianni oppure S.Loren
select f.titolo
from film as f
inner join recita as r on r.codFilm = f.codFilm
inner join attori as a on a.codAttore = r.codAttore
where a.nome = 'M.Mastroianni' or a.nome = 'S.Loren'

-- 1.10 Il titolo dei film in cui recitano M. Mastroianni e S.Loren
select f.titolo
from film as f
where exists (
  select *
  from recita as r
  inner join attori as a on a.codAttore = r.codAttore
  where r.codFilm = f.codFilm and a.nome = 'M.Matroianni'
) and exists (
  select *
  from recita as r
  inner join attori as a on a.codAttore = r.codAttore
  where r.codFilm = f.codFilm and a.nome = 'S.Loren'
)

-- 1.11 Per ogni film in cui recita un attore francese, il titolo del film e il nome dell’attore
select distinct a.nome, f.titolo
from attori as a
inner join recita as r on r.codAttore = a.codAttore
inner join film as f on f.codFilm = r.codFilm
where a.nazionalita = 'Francia'

-- 1.12 Per ogni film che è stato proiettato a Pisa nel gennaio 2005, il titolo del film e il nome della sala. 
select f.titolo, s.nome
from film as f
inner join proiezioni as p on p.codFilm = f.codFilm
inner join sale as s on s.codSala = p.codSala
where p.dataProiezione like '%/01/2005'

-- 1.13 Il numero di sale di Pisa con più di 60 posti
select count(*)
from sale as s
where s.posti > 60 and s.citta = 'Pisa'

-- 1.14 Il numero totale di posti nelle sale di Pisa
select sum(s.posti)
from sale as s
where s.citta = 'Pisa'

-- 1.15 Per ogni città, il numero di sale
select s.citta, count(*)
from sale as s
group by s.citta

-- 1.16 Per ogni città, il numero di sale con più di 60 posti
select s.citta, count(*)
from sale as s
where s.posti > 60
group by s.citta

-- 1.17 Per ogni regista, il numero di film diretti dopo il 1990
select f.regista, count(*)
from film as f
where f.annoproduzione > 1990
group by f.regista

-- 1.18 Per ogni regista, l’incasso totale di tutte le proiezioni dei suoi film
select f.regista, sum(p.incasso)
from film as f
inner join proiezioni as p on p.codFilm = f.codFilm
group by f.regista

-- 1.19 Per ogni film di S.Spielberg, il titolo del film, il numero totale di proiezioni a Pisa e l’incasso totale
select f.titolo, count(p.*), sum(p.incasso)
from film as f
inner join proiezioni as p on p.codFilm = f.codFilm
inner join sala as s on s.codSala = p.codSala
where f.regista = 'S.Spielberg'
and s.citta = 'Pisa'
group by f.titolo

-- 1.20 Per ogni regista e per ogni attore, il numero di film del regista con l’attore
select f.regista, a.nome, count(a.nome)
from film as f
inner join recita as r on r.codFilm = f.codFilm
inner join attori as a on a.codAttore = r.codAttore
group by f.regista, a.nome

-- 1.21 Il regista ed il titolo dei film in cui recitano meno di 6 attori
select f.regista, f.titolo
from film as f
left join recita as r on r.codFilm = f.codFilm
group by f.regista, f.codFilm, f.titolo
having count(r.*) < 6

-- 1.22 Per ogni film prodotto dopo il 2000, il codice, il titolo e l’incasso totale di tutte le sue proiezioni
select f.codFilm, f.titolo, sum(p,incasso)
from film as f
inner join proiezioni as p on p.codFilm = f.codFilm
where f.annoproduzione > 2000
group by f.codFilm, f.titolo

-- 1.23 Il numero di attori dei film in cui appaiono solo attori nati prima del 1970
select f.titolo, count(*)
from film as f
inner join recita as r on r.codFilm = f.codFilm
where not exists (
  select *
  from recita as r2
  inner join attori as a on a.codAttore = r2.codAttore 
  where r2.codFilm = f.codFilm
  and a.annoNascita >= 1970
)
group by f.codFilm, f.titolo

-- 1.24 Per ogni film di fantascienza, il titolo e l’incasso totale di tutte le sue proiezioni
select f.titolo, sum(p.incasso)
from film as f
inner join proiezioni as p on p.codFilm = f.codFilm
where f.genere = 'fantascienza'
group by f.codFilm, f.titolo

-- 1.25 Per ogni film di fantascienza il titolo e l’incasso totale di tutte le sue proiezioni successive al 1/1/01
select f.titolo, sum(p.incasso)
from film as f
inner join proiezioni as p on p.codFilm = f.codFilm
where f.genere = 'fantascienza'
and p.dataProiezione > '1/1/01'
group by f.codFilm, f.titolo

-- 1.26 Per ogni film di fantascienza che non è mai stato proiettato prima del 1/1/01 il titolo e l’incasso totale di tutte le sue proiezioni
select f.titolo, sum(p.incasso)
from film as f
inner join proiezioni as p on p.codFilm = f.codFilm
where f.genere = 'fantascienza'
and not exists (
  select *
  from proiezioni as p
  where p.codFilm = f.codFilm
  and dataProiezione < '1/1/01'
)
group by f.codFilm, f.titolo
-- having min(p.dataProiezione) > '1/1/01'

-- 1.27 Per ogni sala di Pisa, che nel mese di gennaio 2005 ha incassato più di 20000 €, il nome della sala e l’incasso totale (sempre del mese di gennaio 2005)
select s.nome, sum(p.incasso) as incasso
from sale as s
inner join proiezioni as p on p.codSala = s.codSala
where s.citta = 'Pisa'
and p.dataProiezione like '%/01/2005'
group by s.nome
having incasso > 20000

-- 1.28 I titoli dei film che non sono mai stati proiettati a Pisa
select f.titolo
from film as f
where not exists (
  select *
  from proiezioni as p
  inner join sale as s inner join s.codSala = p.codSala
  where p.codFilm = f.codFilm
  and s.citta = 'Pisa'
)

-- 1.29 I titoli dei film che sono stati proiettati solo a Pisa
select f.titolo
from film as f
where not exists (
  select *
  from proiezioni as p
  inner join sale as s inner join s.codSala = p.codSala
  where p.codFilm = f.codFilm
  and s.citta != 'Pisa'
)

-- 1.30 I titoli dei film dei quali non vi è mai stata una proiezione con incasso superiore a 500 €
select f.titolo
from film as f
where not exists (
  select *
  from proiezioni as p
  where p.codFilm = f.codFilm
  and p.incasso > 500
)

-- 1.31 I titoli dei film le cui proiezioni hanno sempre ottenuto un incasso superiore a 500 €
select f.titolo
from film as f
where not exists (
  select *
  from proiezioni as p
  where p.codFilm = f.codFilm
  and p.incasso <= 500
)

-- 1.32 Il nome degli attori italiani che non hanno mai recitato in film di Fellini
select a.nome
from attori as a
where a.nazionalita = 'Italiana'
and not exists (
  select *
  from film as f
  inner join recita as r on r.codFilm = f.codFilm
  and f.regista = 'Fellini'
)

-- 1.33 Il titolo dei film di Fellini in cui non recitano attori italiani
select f.titolo
from film as f
where f.attore = 'Fellini'
and not exists (
  select *
  from attori as a
  inner join recita as r on r.codAttore = a.codAttore
  where r.codFilm = f.codFilm
  and a.nazionalita = 'Italiana'
)

-- 1.34 Il titolo dei film senza attori
select f.titolo
from film as f
where not exists (
  select *
  from recita as r
  where r.codFilm = f.codFilm
)

select distinct f.titolo
from film as f
left join recita on f.codFilm = r.codFilm
where r.codFilm is null

-- 1.35 Gli attori che prima del 1960 hanno recitato solo nei film di Fellini
select a.nome
from attori as a
where not exists (
  select *
  from recita as r on r.codAttore = a.codAttore
  inner join film as f on f.codFilm = r.codFilm
  where f.annoproduzione < 1960
  and f.regista != 'Fellini'
)

-- 1.36 Gli attori che hanno recitato in film di Fellini solo prima del 1960
select a.nome
from attori as a
where exists (
  select *
  from recita as r on r.codAttore = a.codAttore
  inner join film as f on f.codFilm = r.codFilm
  where f.annoproduzione < 1960
  and f.regista = 'Fellini'
)
and not exists (
  select *
  from recita as r on r.codAttore = a.codAttore
  inner join film as f on f.codFilm = r.codFilm
  where f.annoproduzione >= 1960
  and f.regista = 'Fellini'
)

-- ESERCIZIO 2

-- MUSEI (NomeM, Città)
-- ARTISTI (NomeA, Nazionalità)
-- OPERE (Codice, Titolo, NomeM*, NomeA*)
-- PERSONAGGI (Personaggio, Codice*)

-- 2.11 Per ciascun artista, il nome dell’artista ed il numero di sue opere conservate alla “Galleria degli Uffizi”
SELECT o.NomeA, count(*)
FROM opere as o
WHERE o.NomeM = 'Uffizi'
GROUP BY a.NomeA

-- 2.12 I musei che conservano almeno 20 opere di artisti italiani
SELECT o.NomeM
FROM opere AS o
INNER JOIN artisti AS a ON a.NomeA = o.NomeA
WHERE a.Nazionalita = 'Italiana'
GROUP BY o.NomeM
HAVING count(o.*) >= 20

-- 2.13 Per le opere di artisti italiani che non hanno personaggi, il titolo dell’opera ed il nome dell’artista
SELECT o.Titolo, o.NomeA
FROM opere AS o
INNER JOIN artisti AS a ON a.NomeA = o.NomeA
WHERE a.Nazionalita = 'Italiana'
AND NOT EXISTS (
  SELECT *
  FROM personaggi AS p
  WHERE p.Codice = o.Codice
)

-- 2.14 Il nome dei musei di Londra che non conservano opere di artisti italiani, eccettuato Tiziano
SELECT NomeM
FROM musei AS m
WHERE m.Citta = 'Londra'
AND NOT EXISTS (
  SELECT *
  FROM opere AS o
  INNER JOIN artisti AS a ON a.NomeA = o.NomeA
  WHERE a.Nazionalita = 'Italiana'
  AND o.NomeA != 'Tiziano'
)

-- 2.15 Per ogni museo, il numero di opere divise per la nazionalità dell’artista
SELECT o.NomeM, a.Nazionalita, count(a.Nazionalita)
FROM opere AS o
INNER JOIN artisti AS a ON a.nomeA = o.nomeA
GROUP BY o.NomeM, a.Nazionalita

-- ESERCIZIO 5

-- STUDENTI (Matricola, NomeS, CorsoLaurea*, AnnoN)
-- CORSIDILAUREA (CorsoLaurea, TipoLaurea, Facoltà)
-- FREQUENTA (Matricola*, CodCorso*)
-- CORSI (CodCorso, NomeCorso, CodDocente*)
-- DOCENTI (CodDocente, NomeD, Dipartimento)

-- 5.11 Il CodCorso dei corsi seguiti solo da studenti che appartengono al Corso di Laurea Triennale in SBC
SELECT c.CodCorso
FROM corsi AS c
WHERE NOT EXISTS (
  SELECT *
  FROM studenti AS s
  INNER JOIN frequenta AS f ON f.Matricola = s.Matricola
  INNER JOIN corsidilaurea AS cdl ON s.CorsoLaurea = cdl.CorsoLaurea
  WHERE f.CodCorso = c.CodCorso
  AND s.CorsoLaurea != 'SBC'
  AND cdl.TipoLaurea = 'Triennale'
)

-- 5.13 Codice dei corsi che sono frequentati da tutti gli studenti del CorsoLaurea SBC
SELECT c.CodCorso
FROM corsi AS c
WHERE NOT EXISTS (
  SELECT s.Matricola
  FROM studenti AS s
  WHERE s.CorsoLaurea = 'SBC'
  AND NOT EXISTS (
    SELECT *
    FROM frequenta AS f
    WHERE f.Matricola = s.Matricola
    AND f.CodCorso = c.CodCorso
  )
)
