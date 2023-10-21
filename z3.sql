CREATE EXTENSION postgis;

--4.Wyznacz liczbę budynków (tabela: popp, atrybut: f_codedesc, reprezentowane, jako punkty)
--położonych w odległości mniejszej niż 1000 jednostek od głównych rzek. Budynki spełniające to
--kryterium zapisz do osobnej tabeli tableB.

SELECT * FROM popp;
SELECT * FROM rivers;

CREATE TABLE tableB AS 
SELECT p.*
FROM popp p, rivers r
WHERE ST_Distance(p.geom, r.geom) < 1000;

SELECT * FROM tableB

SELECT COUNT(*) AS Liczba_budynkow FROM tableB;

-- 5. Utwórz tabelę o nazwie airportsNew. Z tabeli airports do zaimportuj nazwy lotnisk, ich
-- geometrię, a także atrybut elev, reprezentujący wysokość n.p.m.

SELECT * FROM airports

CREATE TABLE airportsNew AS 
SELECT name, geom, elev 
FROM airports;

SELECT * FROM airportsNew

-- 5. a) Znajdź lotnisko, które położone jest najbardziej na zachód i najbardziej na wschód

SELECT name, ST_Y(geom) AS lotnisko_najbardziej_na_wschod
FROM airports
ORDER BY ST_Y(geom) DESC
LIMIT 1;

SELECT name, ST_Y(geom) AS lotnisko_najbardziej_na_zachod
FROM airports
ORDER BY ST_Y(geom) ASC
LIMIT 1;

--5. b) Do tabeli airportsNew dodaj nowy obiekt - lotnisko, które położone jest w punkcie
--środkowym drogi pomiędzy lotniskami znalezionymi w punkcie a. Lotnisko nazwij airportB.
--Wysokość n.p.m. przyjmij dowolną.

    SELECT ST_LineInterpolatePoint(ST_MakeLine(ST_Centroid(pointA.geom), ST_Centroid(pointB.geom)), 0.5) AS geom
    FROM airportsNew AS pointA, airportsNew AS pointB
    WHERE pointA.name = 'NOATAK' 
    AND pointB.name = 'NIKOLSKI AS' 
SELECT * FROM airportsNew

INSERT INTO airportsNew (name, geom, elev)
VALUES 
    (
		'airportB',
        (SELECT ST_LineInterpolatePoint(ST_MakeLine(ST_Centroid(lotniskoA.geom), ST_Centroid(lotniskoB.geom)), 0.5) AS geom
    FROM airports AS lotniskoA, airports AS lotniskoB
    WHERE lotniskoA.name = 'NOATAK' 
    AND lotniskoB.name = 'NIKOLSKI AS'),
        20
    )
SELECT ST_AsText(geom),* FROM airportsNew WHERE airportsNew.name = 'airportB'

--SELECT *
--FROM airports,
--    (SELECT ST_LineInterpolatePoint(ST_MakeLine(ST_Centroid(pointA.geom), ST_Centroid(pointB.geom)), 0.5) AS geom
--    FROM airports AS pointA, airports AS pointB
--    WHERE pointA.name = 'NOATAK' 
--    AND pointB.name = 'NIKOLSKI AS') AS middle_point
--ORDER BY ST_Distance(airports.geom, middle_point.geom)
--LIMIT 1;

--6. Wyznacz pole powierzchni obszaru, który oddalony jest mniej niż 1000 jednostek od najkrótszej
--linii łączącej jezioro o nazwie ‘Iliamna Lake’ i lotnisko o nazwie „AMBLER”

SELECT * FROM lakes WHERE lakes.names = 'Iliamna Lake'
SELECT * FROM airports WHERE airports.name = 'AMBLER'

WITH line AS (
	SELECT ST_MakeLine(ST_Centroid(lake.geom), ST_Centroid(airport.geom)) As geom
	FROM lakes AS lake, airports AS airport
	WHERE lake.names = 'Iliamna Lake'
	AND airport.name = 'AMBLER'
	LIMIT 1
	)
	
SELECT ST_Area(ST_Buffer(geom, 1000)) AS area
FROM line;
-- dr sposob
SELECT ST_Area(ST_Buffer(ST_MakeLine(ST_Centroid(lake.geom), ST_Centroid(airport.geom)), 1000)) AS area
FROM lakes AS lake, airports AS airport
WHERE lake.names = 'Iliamna Lake'
AND airport.name = 'AMBLER'
LIMIT 1;

-- 7. Napisz zapytanie, które zwróci sumaryczne pole powierzchni poligonów reprezentujących
--poszczególne typy drzew znajdujących się na obszarze tundry i bagien (swamps).

SELECT * FROM swamp
SELECT * FROM tundra
SELECT * FROM trees --vegdesc

SELECT trees.vegdesc, SUM(ST_Area(ST_Intersection(trees.geom, tundra.geom)))+SUM(ST_Area(ST_Intersection(trees.geom, swamp.geom))) AS sumaryczne_pole_powierzchni
FROM trees
JOIN tundra ON ST_Intersects(trees.geom, tundra.geom)
JOIN swamp ON ST_Intersects(trees.geom, swamp.geom)
GROUP BY trees.vegdesc;

	
	
	
	