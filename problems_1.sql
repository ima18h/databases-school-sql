-- oppgave 2
-- get the name of all planets around the star named Proxima Centauri
SELECT navn
  FROM planet
 WHERE stjerne = 'Proxima Centauri';

-- get distinct oppdaget values from planet, where stjerne is TRAPPIST-1 or Kepler-154
SELECT DISTINCT oppdaget
  FROM planet
 WHERE stjerne IN ('TRAPPIST-1', 'Kepler-154');

-- count how many rows in planet has masse NULL
SELECT COUNT(*)
  FROM planet
 WHERE masse IS NULL;

-- get navn and masse of all planet with oppdaget = 2020, with masse > average of all planet masse
SELECT navn, masse
  FROM planet
 WHERE oppdaget = 2020
   AND masse > (SELECT AVG(masse) FROM planet);

-- get difference between the highest and lowest oppdaget value from planet table
SELECT MAX(oppdaget) - MIN(oppdaget)
  FROM planet;


-- oppgave 3
-- get all planet with masse 3 <= masse <= 10, and planet has molekyl 'H2O' in table materie
SELECT navn, masse
  FROM planet
 WHERE masse BETWEEN 3 AND 10
   AND navn IN (SELECT planet FROM materie WHERE molekyl = 'H2O');

-- TODO: check
-- get all planet names where avstand of stjerne is < 12 * masse of stjerne, and materie of planet has the letter 'H' in molekyl using inner join
SELECT p.navn
  FROM planet p
           JOIN stjerne s
           ON p.stjerne = s.navn
           JOIN materie m
           ON p.navn = m.planet
 WHERE s.avstand < 12 * s.masse
   AND m.molekyl LIKE '%H%';

-- TODO: check
-- get two planet with same stjerne, and avstand < 50 for stjerne
SELECT p1.navn, p2.navn
  FROM planet p1
           JOIN planet p2
           ON p1.stjerne = p2.stjerne
           JOIN stjerne s
           ON p1.stjerne = s.navn
 WHERE p1.navn < p2.navn
   AND s.avstand < 50;


-- oppgave 4
/* Det er fordi de to tabellene har bare navn som felles
   kolonne, men ingen av de kolonenne vil ha samme verdi.
   for å fikse dette bruker man en inner join istedenfor:
*/
SELECT oppdaget
  FROM planet
           INNER JOIN stjerne
           ON planet.stjerne = stjerne.navn
 WHERE avstand > 8000;


-- DEL 2
-- oppgave 5
-- insert row in stjerne with navn = 'Sola', avstand = 0 and masse = 1
INSERT INTO stjerne (navn, avstand, masse)
VALUES ('Sola', 0, 1);

-- insert row in planet with navn = 'Jorda', stjerne = 'Sola', masse = 0.003146, and oppdaget = NULL
INSERT INTO planet (navn, stjerne, masse, oppdaget)
VALUES ('Jorda', 'Sola', 0.003146, NULL);


-- oppgave 6
-- create table observasjon with primary key column observasjons_id(int), tidspunkt(timestamp), kommentar(text), and foreign key column planet(text) referencing the planet table
CREATE TABLE observasjon
    (
        observasjons_id int,
        tidspunkt timestamp NOT NULL,
        kommentar text,
        planet text,
        PRIMARY KEY (observasjons_id),
        FOREIGN KEY (planet) REFERENCES planet (navn)
    );
