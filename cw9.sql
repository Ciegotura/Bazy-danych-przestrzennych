CREATE EXTENSION postgis;
CREATE EXTENSION postgis_raster;

SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public';

SELECT * FROM "exports"

--raster2pgsql.exe -s 27700 -N -32767 -t 254x254 -I -C -M -d "C:\Users\ciego\Desktop\5 semestr\Bazy dnanych przestrzennych\zaj9\tify\*.tif" public.Exports | psql -d cw9 -h localhost -U postgres -p 5432

--4. Za pomocą odpowiedniego zapytania SQL i funkcji geoprzestrzennej w PostGIS scal wyniki
--z punktu 3. i wynikowy raster zapisz do osobnej tabeli.
DROP table "wynikraster"

CREATE TABLE "Wynik" AS
SELECT ST_Union(rast) AS raster
FROM "exports";

SELECT * FROM "Wynik"