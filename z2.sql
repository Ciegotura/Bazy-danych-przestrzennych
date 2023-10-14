CREATE EXTENSION postgis; --To trzeba odpalić aby pracować z danymi przestrzennymi, to doposarza baze danych w funkcje do danych przestrzennych  

--4. Na podstawie poniższej mapy utwórz trzy tabele: budynki (id, geometria, nazwa), drogi
--(id, geometria, nazwa), punkty_informacyjne (id, geometria, nazwa).
CREATE TABLE budynki (
    id INT,
    geometria GEOMETRY(POLYGON),
    nazwa VARCHAR(40)
);
CREATE TABLE drogi (
    id INT PRIMARY KEY,
    geometria GEOMETRY(LINESTRING),
    nazwa VARCHAR(40)
);
CREATE TABLE punkty_informacyjne (
    id INT PRIMARY KEY,
    geometria GEOMETRY(POINT),
    nazwa VARCHAR(40)
);
--5. Współrzędne obiektów oraz nazwy (np. BuildingA) należy odczytać z mapki umieszczonej
--poniżej. Układ współrzędnych ustaw jako niezdefiniowany.
INSERT INTO budynki (id, geometria, nazwa)
VALUES 
    (
		1,
        ST_GeomFromText('POLYGON((8 4, 10.5 4, 10.5 1.5, 8 1.5, 8 4))', -1),
        'BuildingA'
    ),
    (
		2,
        ST_GeomFromText('POLYGON((4 7, 6 7, 6 5, 4 5, 4 7))', -1),
        'BuildingB'
    ),
	 (
		3,
        ST_GeomFromText('POLYGON((3 8, 5 8, 5 6, 3 6, 3 8))', -1),
        'BuildingC'
    ),
	 (
		4,
        ST_GeomFromText('POLYGON((9 9, 10 9, 10 8, 9 8, 9 9))', -1),
        'BuildingD'
    ),
	 (
		5,
        ST_GeomFromText('POLYGON((1 2, 2 2, 2 1, 1 1, 1 2))', -1),
        'BuildingF'
    );
	
SELECT id,ST_AsText(geometria),nazwa FROM budynki;

INSERT INTO drogi (id,geometria, nazwa)
VALUES 
	(
	1,
    ST_GeomFromText('LINESTRING(0 4.5, 12 4.5)', -1),
    'RoadX'
	),
	(
	2,
    ST_GeomFromText('LINESTRING(7.5 0, 7.5 10.5)', -1),
    'RoadY'
	);

SELECT id,ST_AsText(geometria),nazwa FROM drogi;

INSERT INTO punkty_informacyjne (id,geometria, nazwa)
VALUES 
	(
	1,
    ST_GeomFromText('POINT(9.5 6)', -1),
    'I'
	),
	(
	2,
    ST_GeomFromText('POINT(6.5 6)', -1),
    'J'
	),
	(
	3,
    ST_GeomFromText('POINT(6 9.5)', -1),
    'K'
	),
	(
	4,
    ST_GeomFromText('POINT(1 3.5)', -1),
    'G'
	),
	(
	5,
    ST_GeomFromText('POINT(5.5 1.5)', -1),
    'H'
	);
	
SELECT id,ST_AsText(geometria),nazwa FROM punkty_informacyjne;

--6.
--a) Wyznacz całkowitą długość dróg w analizowanym mieście.

SELECT SUM(ST_Length(geometria)) AS dlugosc_drog FROM drogi;

--b) Wypisz geometrię (WKT), pole powierzchni oraz obwód poligonu reprezentującego budynek o nazwie BuildingA.

SELECT 
    ST_AsText(geometria) AS geometria_wkt,
    ST_Area(geometria) AS powierzchnia,
    ST_Perimeter(geometria) AS obwod
FROM budynki WHERE nazwa = 'BuildingA';

--c) Wypisz nazwy i pola powierzchni wszystkich poligonów w warstwie budynki. Wyniki posortuj alfabetycznie.

SELECT 
    nazwa,
    ST_Area(geometria) AS powierzchnia
FROM budynki
ORDER BY nazwa ASC;

--d) Wypisz nazwy i obwody 2 budynków o największej powierzchni

SELECT 
    nazwa,
    ST_Perimeter(geometria) AS obwod
FROM budynki
ORDER BY ST_Area(geometria) DESC
LIMIT 2;

--e) Wyznacz najkrótszą odległość między budynkiem BuildingC a punktem G

SELECT 
    ST_Distance(b.budynki_geometria, p.punkty_geometria) AS najkrotsza_odleglosc
FROM 
    (SELECT 
        geometria AS budynki_geometria
    FROM 
        budynki
    WHERE 
        nazwa = 'BuildingC') AS b,
    (SELECT 
        geometria AS punkty_geometria
    FROM 
        punkty_informacyjne
    WHERE 
        nazwa = 'G') AS p;
		
--f) Wypisz pole powierzchni tej części budynku BuildingC, która znajduje się w
--odległości większej niż 0.5 od budynku BuildingB.

SELECT 
    ST_Area(ST_Difference(b.budynek_c, p.budynek_b_bufor)) AS powierzchnia
FROM 
    (SELECT 
        geometria AS budynek_c
    FROM 
        budynki
    WHERE 
        nazwa = 'BuildingC') AS b,
    (SELECT 
        ST_Buffer(geometria, 0.5) AS budynek_b_bufor
    FROM 
        budynki
    WHERE 
        nazwa = 'BuildingB') AS p;
		
--g) Wybierz te budynki, których centroid (ST_Centroid) znajduje się powyżej drogi
--o nazwie RoadX. 

SELECT 
    b.nazwa AS nazwa_budynku
FROM 
    budynki AS b
JOIN 
    drogi AS d
ON 
    ST_Y(ST_Centroid(b.geometria)) > ST_Y(ST_StartPoint(d.geometria))
AND 
    ST_Y(ST_Centroid(b.geometria)) > ST_Y(ST_EndPoint(d.geometria))
WHERE 
    d.nazwa = 'RoadX';

--h) Oblicz pole powierzchni tych części budynku BuildingC i poligonu
--o współrzędnych (4 7, 6 7, 6 8, 4 8, 4 7), które nie są wspólne dla tych dwóch
--obiektów.

SELECT 
    ST_Area(ST_Difference(b.geometria, p.geometria))+ST_Area(ST_Difference(p.geometria, b.geometria)) AS powierzchnia
FROM 
    (SELECT 
        geometria
    FROM 
        budynki
    WHERE 
        nazwa = 'BuildingC') AS b,
    (SELECT 
        ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))', -1) AS geometria) AS p;
