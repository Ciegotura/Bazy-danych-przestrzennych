CREATE EXTENSION postgis;
--tabele:
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public';

SELECT DISTINCT vegdesc FROM trees 

--1. Podaj pole powierzchni wszystkich lasów o charakterze mieszanym

SELECT area_km2 FROM trees WHERE vegdesc = 'Mixed Trees'

--2. Podziel warstwę trees na trzy warstwy. Na każdej z nich umieść inny typ lasu. Zapisz wyniki do osobnych tabel.
--Wyeksportuj je do bazy.
SELECT * FROM DeciduousTrees

CREATE TABLE DeciduousTrees AS
SELECT * FROM trees WHERE vegdesc = 'Deciduous';

CREATE TABLE MixedTrees AS
SELECT * FROM trees WHERE vegdesc = 'Mixed Trees';

CREATE TABLE EvergreenTrees AS
SELECT * FROM trees WHERE vegdesc = 'Evergreen';

--3. Oblicz długość linii kolejowych dla regionu Matanuska-Susitna.

SELECT * FROM railroads
SELECT * FROM regions WHERE name_2 = 'Matanuska-Susitna'

SELECT SUM(ST_Length(ST_Intersection(railroads.geom, regions.geom))) AS total_length
FROM railroads
JOIN regions ON ST_Intersects(railroads.geom, regions.geom)
WHERE regions.name_2 = 'Matanuska-Susitna';

--4. Oblicz, na jakiej średniej wysokości nad poziomem morza położone są lotniska o charakterze militarnym. Ile
--jest takich lotnisk? Usuń z warstwy airports lotniska o charakterze militarnym, które są dodatkowo położone
--powyżej 1400 m n.p.m. Ile było takich lotnisk? Sprawdź, czy zmiany są widoczne w tabeli bazy danych

SELECT * FROM airports WHERE use = 'Military' AND elev > 1400

DELETE FROM airports
WHERE "use" = 'Military' AND elev > 1400;

--5. Utwórz warstwę (tabelę), na której znajdować się będą jedynie budynki położone w regionie Bristol Bay
-- (wykorzystaj warstwę popp). Podaj liczbę budynków.

SELECT * FROM regions WHERE name_2 = 'Bristol Bay'
SELECT * FROM popp WHERE f_codedesc = 'Building'

DROP TABLE regions

SELECT * 
FROM popp 
JOIN regions ON ST_Within(popp.geom, regions.geom)
WHERE regions.name_2 = 'Bristol Bay'
AND f_codedesc = 'Building'

CREATE TABLE budynki_bristol_bay AS
SELECT popp.gid, popp.cat, popp.f_codedesc, popp.f_code, popp.type, popp.geom
FROM popp 
JOIN regions ON ST_Within(popp.geom, regions.geom)
WHERE regions.name_2 = 'Bristol Bay'
AND f_codedesc = 'Building';

SELECT * FROM budynki_bristol_bay

--6. W tabeli wynikowej z poprzedniego zadania zostaw tylko te budynki, które są położone nie dalej niż 100 km od
--rzek (rivers). Ile jest takich budynków?

DELETE FROM budynki_bristol_bay
WHERE gid NOT IN (
    SELECT b.gid
    FROM budynki_bristol_bay b
    JOIN rivers r ON ST_DWithin(b.geom, r.geom, 100000)
    WHERE ST_DWithin(b.geom, r.geom, 100000)
);

--7. Sprawdź w ilu miejscach przecinają się rzeki (majrivers) z liniami kolejowymi (railroads).

DROP TABLE majrivers
DROP TABLE railroads

SELECT COUNT(*) AS liczba_przeciec
FROM majrivers r
JOIN railroads rr ON ST_Intersects(r.geom, rr.geom);

-- 8. Wydobądź węzły dla warstwy railroads. Ile jest takich węzłów? Zapisz wynik w postaci osobnej tabeli w bazie
-- danych.

CREATE TABLE wezly_kolejowe AS
SELECT ST_Intersection(a.geom, b.geom) AS intersection_geom
FROM railroads a
JOIN railroads b ON ST_Intersects(a.geom, b.geom) AND a.gid <> b.gid;

--9. Wyszukaj najlepsze lokalizacje do budowy hotelu. Hotel powinien być oddalony od lotniska nie więcej niż 100
--km i nie mniej niż 50 km od linii kolejowych. Powinien leżeć także w pobliżu sieci drogowej.
SELECT * FROM airports

CREATE TABLE potencjalne_lokalizacje AS (
    SELECT ST_Centroid(airports.geom) AS geom
    FROM airports
    UNION
    SELECT ST_Centroid(railroads.geom) AS geom
    FROM railroads
    UNION
    SELECT ST_Centroid(trails.geom) AS geom
    FROM trails
)
SELECT * FROM potencjalne_lokalizacje

SELECT *
FROM potencjalne_lokalizacje
WHERE EXISTS (
    SELECT 2
    FROM airports
    WHERE ST_DWithin(ST_Centroid(potencjalne_lokalizacje.geom), airports.geom, 100000)
)
AND EXISTS (
    SELECT 2
    FROM railroads
    WHERE ST_DWithin(ST_Centroid(potencjalne_lokalizacje.geom), railroads.geom, 50000)
)
AND EXISTS (
    SELECT 2
    FROM trails
    WHERE ST_DWithin(ST_Centroid(potencjalne_lokalizacje.geom), trails.geom, 20000)
);

-- 10. Uprość geometrię warstwy przedstawiającej bagna (swamps). Ustaw tolerancję na 100. Ile Ile wierzchołków
--zostało zredukowanych? Czy zmieniło się pole powierzchni całkowitej poligonów?

SELECT SUM(areakm2) FROM swamp
SELECT * FROM swamp



