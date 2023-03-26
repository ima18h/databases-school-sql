  WITH played_in AS (SELECT DISTINCT fp.personid, fp.filmid, r.rank
                       FROM filmparticipation AS fp
                                INNER JOIN film AS f
                                USING (filmid)
                                INNER JOIN filmrating AS r
                                USING (filmid)
                      WHERE fp.parttype = 'cast ')
SELECT p.personid, p.firstname, p.lastname, COUNT(*) AS nr_played_in
  FROM person AS p
           INNER JOIN played_in AS pi
           USING (personid)
 GROUP BY p.personid, p.firstname, p.lastname
HAVING AVG(pi.rank) > 9
 ORDER BY nr_played_in DESC
 LIMIT 10;


WITH
years AS (
SELECT prodyear AS year FROM film
UNION ALL
SELECT firstprodyear AS year FROM series
)
SELECT ((year/10)*10)::text || ' - ' || (((year/10)*10)+9)::text AS tiår ,
count(*) AS nr
FROM years
GROUP BY year/10
ORDER BY nr;

SELECT film.title, person.firstname || ' ' || person.lastname AS fullname
FROM filmcountry
     JOIN film USING (filmid)
     JOIN filmparticipation USING (filmid)
     JOIN person USING (personid)
WHERE filmcountry.country = 'Norway'
    AND parttype = 'director'
    AND prodyear < 1960;


-- oppgave 1
-- get the names of all actors and their roles in the movie with title "Star Wars"
SELECT p.firstname, p.lastname, c.filmcharacter
  FROM filmparticipation x,
       person p,
       film f,
       filmcharacter c
 WHERE f.title = 'Star Wars'
   AND x.personid = p.personid
   AND x.filmid = f.filmid
   AND x.partid = c.partid;

-- oppgave 2
-- find the number of movies made in each country and sorted by the number of movies per country
SELECT country, COUNT(*) AS antall
  FROM filmcountry
 GROUP BY country
 ORDER BY antall DESC;

-- oppgave 3
-- using time ~ '^\ d + $' to check if the string only contains digits. get the average time of movies per country
SELECT country, AVG(CAST(time AS integer)) AS gjennomsnitt, COUNT(*) AS antall
  FROM runningtime
 WHERE time ~ '^\d+$' IS TRUE
   AND country IS NOT NULL
 GROUP BY country
HAVING COUNT(*) > 200
 ORDER BY gjennomsnitt DESC;

-- oppgave 4
-- select the 10 films with the most different filmgenre.genre and filmitem.filmtype = 'C'
SELECT f.filmid, f.title, COUNT(*) AS antall
  FROM film f,
       filmitem i,
       filmgenre g
 WHERE f.filmid = i.filmid
   AND f.filmid = g.filmid
   AND i.filmtype = 'C'
 GROUP BY f.filmid, f.title
 ORDER BY antall DESC, f.title
 LIMIT 10;

-- oppgave 5
-- find the number of movies per filmcountry.country, their average filmrating.rank and the most common genre per country
SELECT country, COUNT(*) AS antall, AVG(rank) AS gjennomsnitt
  FROM filmcountry,
       filmrating
 WHERE filmcountry.filmid = filmrating.filmid
 GROUP BY country
 ORDER BY antall DESC;

-- jeg klarte ikke å forstå hvordan oppgave 5 virker
SELECT c.country,
      (delspørring som finner antall filmer) AS movies,
      (delspørring som finner gjennomsnittlig rating) AS avg_rating,
      (delspørring som finner vanligste sjanger) AS genre,
FROM country AS c
GROUP BY c.country;

-- oppgave 6
-- find all pairs of actors that have acted together in at least 40 movies from norway and filmtype = 'C'
SELECT p1.firstname, p1.lastname, p2.firstname, p2.lastname, COUNT(*) AS antall
  FROM filmparticipation x1,
       filmparticipation x2,
       person p1,
       person p2,
       film f,
       filmitem i
 WHERE x1.personid = p1.personid
   AND x2.personid = p2.personid
   AND x1.filmid = x2.filmid
   AND x1.filmid = f.filmid
   AND f.filmid = i.filmid
   AND i.filmtype = 'C'
   AND p1.personid < p2.personid
   AND f.filmid IN (SELECT filmid FROM filmcountry WHERE country = 'Norway')
 GROUP BY p1.firstname, p1.lastname, p2.firstname, p2.lastname
HAVING COUNT(*) > 40
 ORDER BY antall DESC;

-- DEL 2
-- oppgave 7
-- find the name and production year of movies with a title containing the word "Dark" or "Night" and is of genre "Horror" or produced in Romania without duplicates
SELECT f.title, f.prodyear
  FROM film f,
       filmgenre g
 WHERE f.filmid = g.filmid
   AND (f.title LIKE '%Dark%' OR f.title LIKE '%Night%')
   AND (g.genre = 'Horror' OR f.filmid IN (SELECT filmid FROM filmcountry WHERE country = 'Romania'))
 GROUP BY f.title, f.prodyear;

-- oppgave 8
-- find the title of all movies produced after 2009 which only have less than 3 participants. add the movies with 0 participants?
SELECT f.title, COUNT(*) AS antall
  FROM film f,
       filmparticipation x
 WHERE f.filmid = x.filmid
   AND f.prodyear > 2009
 GROUP BY f.title
HAVING COUNT(*) < 3;

-- jeg tror denne finner filmene med 0 deltagere, men usikker på hvordan jeg legger det til
SELECT f.title
  FROM film f
 WHERE f.filmid NOT IN (SELECT filmid FROM filmparticipation)
   AND f.prodyear > 2009;

-- oppgave 9
-- find the number of movies that dont have genre "Horror" or "Sci-Fi"
SELECT COUNT(*) AS antall
  FROM film f
 WHERE f.filmid NOT IN (SELECT filmid FROM filmgenre WHERE genre = 'Horror' OR genre = 'Sci-Fi');

-- oppgave 10
-- find the title and the amount of languages spoken in (the 10 highest rank movies), or (movies where genre is "Comedy" or "Romance") or (movies where the actor "Harrison" has casttype "cast") with filmtype "C"
SELECT f.title, COUNT(*) AS antall
  FROM film f,
       filmitem i,
       filmlanguage l
 WHERE f.filmid = i.filmid
   AND f.filmid = l.filmid
   AND i.filmtype = 'C'
   AND (f.filmid IN (SELECT filmid FROM filmrating ORDER BY rank DESC LIMIT 10) OR
        f.filmid IN (SELECT filmid FROM filmgenre WHERE genre = 'Comedy' OR genre = 'Romance') OR
        f.filmid IN (SELECT filmid
                       FROM filmparticipation
                      WHERE personid IN (SELECT personid FROM person WHERE firstname = 'Harrison')
                        AND parttype = 'cast'))
 GROUP BY f.title
 ORDER BY antall DESC;


-- find the title and the amount of languages spoken in (the 10 highest rank movies), or (movies where genre is "Comedy" or "Romance") or (movies where the actor "Harrison" "Ford" has casttype "cast") with filmtype "C"
-- Er der så få romance og comedy filmer? jeg får veldig mange fra: SELECT filmid FROM filmgenre WHERE genre = 'Comedy' OR genre = 'Romance'
SELECT f.title, COUNT(*) AS antall
  FROM film f
       JOIN filmitem i ON f.filmid = i.filmid
       JOIN filmlanguage l ON f.filmid = l.filmid
 WHERE i.filmtype = 'C'
   AND (f.filmid IN (SELECT filmid FROM filmrating LIMIT 10) OR
        f.filmid IN (SELECT filmid FROM filmgenre WHERE genre = 'Comedy' OR genre = 'Romance') OR
        f.filmid IN (SELECT filmid
                       FROM filmparticipation
                      WHERE personid IN (SELECT personid FROM person WHERE firstname = 'Harrison' and lastname = 'Ford')
                        AND parttype = 'cast'))
 GROUP BY f.title
 ORDER BY antall DESC;
