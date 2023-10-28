CREATE EXTENSION postgis;
--tabele:
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public';

SELECT * FROM t2018_kar_buildings
SELECT * FROM t2019_kar_buildings

-- 1. Znajdź budynki, które zostały wybudowane lub wyremontowane na przestrzeni roku (zmiana
--pomiędzy 2018 a 2019).

SELECT b2019.*
FROM t2019_kar_buildings AS b2019
LEFT JOIN t2018_kar_buildings AS b2018
ON b2019.geom = b2018.geom
WHERE b2018.gid IS NULL 

-- 2. Znajdź ile nowych POI pojawiło się w promieniu 500 m od wyremontowanych lub
--wybudowanych budynków, które znalezione zostały w zadaniu 1. Policz je wg ich kategorii.
--T2018_KAR_POI_TABLE
--T2019_KAR_POI_TABLE
SELECT COUNT(*) FROM T2018_KAR_POI_TABLE --2751
SELECT COUNT(*) FROM T2019_KAR_POI_TABLE --3622


WITH NoweBudynki AS (
    SELECT ST_Collect(b2019.geom) AS geom
    FROM t2019_kar_buildings AS b2019
    LEFT JOIN t2018_kar_buildings AS b2018
    ON b2019.geom = b2018.geom
    WHERE b2018.gid IS NULL
),
NowePunkty AS (
    SELECT p2019.geom, p2019.type
    FROM T2019_KAR_POI_TABLE AS p2019
    LEFT JOIN T2018_KAR_POI_TABLE AS p2018
    ON p2019.geom = p2018.geom
    WHERE p2018.gid IS NULL
)

SELECT np.type, COUNT(np.geom)
FROM NoweBudynki AS nb, NowePunkty AS np
WHERE ST_DWithin(nb.geom, np.geom, 500)
GROUP BY np.type;

--3. Utwórz nową tabelę o nazwie ‘streets_reprojected’, która zawierać będzie dane z tabeli
--T2019_KAR_STREETS przetransformowane do układu współrzędnych DHDN.Berlin/Cassini.
SELECT * FROM streets_reprojected
DROP TABLE streets_reprojected

CREATE TABLE streets_reprojected AS
SELECT s2019.gid,s2019.link_id,s2019.st_name,s2019.ref_in_id,s2019.nref_in_id,s2019.func_class,s2019.speed_cat,s2019.fr_speed_l,s2019.to_speed_l,s2019.dir_travel,
	ST_Transform(s2019.geom, 31468) AS geom
FROM T2019_KAR_STREETS as s2019;

SELECT * FROM streets_reprojected

--4. Stwórz tabelę o nazwie ‘input_points’ i dodaj do niej dwa rekordy o geometrii punktowej.
--Użyj następujących współrzędnych:
--X Y
--8.36093 49.03174
--8.39876 49.00644
--Przyjmij układ współrzędnych GPS.
DROP TABLE input_points
CREATE TABLE input_points (
    id SERIAL PRIMARY KEY,
    geom geometry(Point, 4326)
);

INSERT INTO input_points (geom) VALUES
(ST_SetSRID(ST_MakePoint(8.36093, 49.03174), 4326)),
(ST_SetSRID(ST_MakePoint(8.39876, 49.00644), 4326));

SELECT * FROM input_points

--5. Zaktualizuj dane w tabeli ‘input_points’ tak, aby punkty te były w układzie współrzędnych
--DHDN.Berlin/Cassini. Wyświetl współrzędne za pomocą funkcji ST_AsText()

ALTER TABLE input_points
ALTER COLUMN geom TYPE geometry(Point, 31468) USING ST_Transform(geom, 31468);

UPDATE input_points
SET geom = ST_Transform(geom, 31468);

SELECT id, ST_AsText(geom) FROM input_points;

-- 6. Znajdź wszystkie skrzyżowania, które znajdują się w odległości 200 m od linii zbudowanej
--z punktów w tabeli ‘input_points’. Wykorzystaj tabelę T2019_STREET_NODE. Dokonaj
--reprojekcji geometrii, aby była zgodna z resztą tabel.
SELECT * FROM T2019_KAR_STREET_NODE

ALTER TABLE input_points
ALTER COLUMN geom TYPE geometry(Point, 4326) USING ST_Transform(geom, 4326);

UPDATE input_points
SET geom = ST_Transform(geom, 4326);

SELECT * FROM input_points
SELECT *
FROM T2019_KAR_STREET_NODE AS sn
WHERE ST_DWithin((SELECT ST_MakeLine(geom) FROM input_points),sn.geom,  200);

WITH input_buffer AS (
    SELECT ST_Buffer(ST_MakeLine(geom ORDER BY id), 200) AS buffer
    FROM input_points
)
SELECT sn.*
FROM T2019_KAR_STREET_NODE sn
JOIN input_buffer ib
ON ST_Intersects(sn.geom, ib.buffer);

--7. Policz jak wiele sklepów sportowych (‘Sporting Goods Store’ - tabela POIs) znajduje się
--w odległości 300 m od parków (LAND_USE_A).
SELECT * FROM t2019_kar_land_use_a WHERE t2019_kar_land_use_a.type LIKE 'Park (City/County)';
SELECT * FROM t2019_kar_poi_table WHERE t2019_kar_poi_table.type LIKE 'Sporting Goods Store'


WITH Parki AS (
    SELECT ST_Collect(p2019.geom) AS geom
    FROM t2019_kar_land_use_a AS p2019
    WHERE p2019.type LIKE 'Park (City/County)'
),
Sklepy AS (
    SELECT t2019_kar_poi_table.geom AS geom 
    FROM t2019_kar_poi_table 
    WHERE t2019_kar_poi_table.type LIKE 'Sporting Goods Store'
)

SELECT COUNT(sk.geom)
FROM Sklepy AS sk
JOIN Parki AS pa
ON ST_DWithin(pa.geom, sk.geom, 300);

-- 8. Znajdź punkty przecięcia torów kolejowych (t2019_kar_railways) z ciekami (t2019_kar_water_lines). Zapisz
--znalezioną geometrię do osobnej tabeli o nazwie ‘T2019_KAR_BRIDGES’.
SELECT * FROM t2019_kar_railways
SELECT * FROM t2019_kar_water_lines

CREATE TABLE T2019_KAR_BRIDGES AS
SELECT ST_Intersection(r.geom, w.geom) AS geom
FROM t2019_kar_railways r, t2019_kar_water_lines w
WHERE ST_Intersects(r.geom, w.geom);

SELECT ST_AsText(geom) FROM T2019_KAR_BRIDGES 




