CREATE EXTENSION postgis;
CREATE EXTENSION postgis_raster;
CREATE EXTENSION ogr_fdw;

SELECT * FROM uk_250k

ogr2ogr -f PGDump "PG:host=127.0.0.1 port=5432 user=postgres password=piotr dbname=cw8" "C:\Users\ciego\Desktop\5 semestr\Bazy dnanych przestrzennych\zaj8\OS_Open_Zoomstack.gpkg" -sql "SELECT * FROM national_parks" -nln national_parks -skipfailures

SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public';

SELECT * FROM national_parks;

--6.Utwórz nową tabelę o nazwie uk_lake_district, gdzie zaimportujesz mapy rastrowe z
--punktu 1., które zostaną przycięte do granic parku narodowego Lake District
CREATE TABLE uk_lake_district AS
SELECT ST_Clip(a.rast, b.geom, true)
FROM uk_250k AS a, national_parks AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.id = 1;

SELECT * FROM public.uk_lake_district

--7. Wyeksportuj wyniki do pliku GeoTIFF

COPY (SELECT ST_AsGDALRaster(ST_Union(st_clip), 'GTiff') FROM public.uk_lake_district) TO 'C:\Users\ciego\Desktop\5 semestr\Bazy dnanych przestrzennych\zaj8\uk_lake_district.tiff';


--raster2pgsql.exe -s 32630 -N -32767 -t 254x254 -I -C -M -d "C:\Users\ciego\Desktop\5 semestr\Bazy dnanych przestrzennych\zaj8\B04.tiff" public.B04 | psql -d cw8 -h localhost -U postgres -p 5432

--raster2pgsql.exe -s 32630 -N -32767 -t 254x254 -I -C -M -d "C:\Users\ciego\Desktop\5 semestr\Bazy dnanych przestrzennych\zaj8\B08.tiff" public.B08 | psql -d cw8 -h localhost -U postgres -p 5432

SELECT * FROM B04

SELECT * FROM B08


--10. Policz indeks NDWI (to inny indeks niż NDVI) oraz przytnij wyniki do granic Lake District.
CREATE TABLE public.temp_brands AS
SELECT
  B04.rid,
  B04.rast AS rast_b04,
  B08.rast AS rast_b08
FROM
  B04
JOIN
  B08
ON
  B04.rid = B08.rid;
  DROP TABLE public.temp_brands
  SELECT * FROM public.temp_brands
  
  
    create table ndvi as
SELECT ST_MapAlgebra(temp_brands.rast_b04, temp_brands.rast_b08,'([rast1.val] - [rast2.val]) / ([rast2.val] +
[rast1.val])::float','32BF') AS rast 
FROM temp_brands

CREATE TABLE ndvi_clip as
SELECT ST_Union(ST_Clip(a.rast, ST_Transform(b.geom, 32630), true)) as rast
			FROM public.ndvi AS a, public.national_parks AS b
			WHERE ST_Intersects(a.rast, ST_Transform(b.geom, 32630)) AND b.id=1
			
			SELECT * FROM ndvi_clip

CREATE TABLE B08_clip as
SELECT ST_Union(ST_Clip(a.rast, ST_Transform(b.geom, 32630), true)) as rast
			FROM public.B08 AS a, public.national_parks AS b
			WHERE ST_Intersects(a.rast, ST_Transform(b.geom, 32630)) AND b.id=1
CREATE TABLE B04_clip as			
SELECT ST_Union(ST_Clip(a.rast, ST_Transform(b.geom, 32630), true)) as rast
			FROM public.B04 AS a, public.national_parks AS b
			WHERE ST_Intersects(a.rast, ST_Transform(b.geom, 32630)) AND b.id=1
  
  create table ndwi as
SELECT ST_MapAlgebra(B04_clip.rast, B08_clip.rast,'([rast1.val] - [rast2.val]) / ([rast2.val] +
[rast1.val])::float','32BF') AS rast 
FROM B08_clip, B04_clip

--
SELECT * FROM clip_bands
CREATE TABLE public.clip_bands AS SELECT B04_clip.rast AS rast_4, B08_clip.rast AS rast_8 FROM B04_clip, B08_clip

    create table ndwwi as
SELECT ST_MapAlgebra(clip_bands.rast_4, clip_bands.rast_8,'([rast1.val] - [rast2.val]) / ([rast2.val] +
[rast1.val])::float','32BF') AS rast 
FROM clip_bands

SELECT * FROM ndwi
