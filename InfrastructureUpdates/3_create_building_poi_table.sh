#!/bin/bash

## ========================================================
## OSM data conversion on building POI
## ========================================================
## POI data from OSM building data
## set parameters
PG_HOST=localhost
PG_ID=**YOUR_USER**
PGPASSWORD=**YOUR_PASSWORD**
PG_DB=**YOUR_DB_NAME**
PG_PORT=5432

OSM_SCHEMA=srilanka
OSM_BLT_TABLE=${OSM_SCHEMA}.osm_buildings
TEMP_DIR=/tmp

## convert shape to sql
shp2pgsql -s 4326:4326 -I ${OSM_SCHEMA}-latest-free.shp/gis_osm_buildings_a_free_1.shp ${OSM_BLT_TABLE} > ${OSM_SCHEMA}.osm_buildings.sql

## import into PostgreSQL/PostGIS DB
psql -U ${PG_ID} -d ${PG_DB} -c "create schema if not exists ${OSM_SCHEMA};"
psql -U ${PG_ID} -d ${PG_DB} -c "drop table if exists ${OSM_BLT_TABLE};"
psql -U ${PG_ID} -d ${PG_DB} -q -f ${OSM_SCHEMA}.osm_buildings.sql

## add column for building area size(m^2)
psql -U ${PG_ID} -d ${PG_DB} -c "alter  table ${OSM_BLT_TABLE} add column area float8;"
psql -U ${PG_ID} -d ${PG_DB} -c "update ${OSM_BLT_TABLE} set area = ST_Area(Geography(geom));"

## add column of building centroid
psql -U ${PG_ID} -d ${PG_DB} -c "alter  table ${OSM_BLT_TABLE} add column centroid GEOMETRY(POINT,4326);"
psql -U ${PG_ID} -d ${PG_DB} -c "update ${OSM_BLT_TABLE} set centroid = ST_PointOnSurface(geom) where ST_IsValid(geom);"
psql -U ${PG_ID} -d ${PG_DB} -c "CREATE INDEX idx_${OSM_SCHEMA}_osm_buildings_centroid on ${OSM_BLT_TABLE} USING Gist(centroid);"


## export road data as tsv format
mkdir -p dump/tsv
psql -d ${PG_DB} -q  -c "copy ${OSM_BLT_TABLE} to '${TEMP_DIR}/${OSM_BLT_TABLE}.tsv'  (delimiter E'\t',format csv,header true)"
cp ${TEMP_DIR}/${OSM_BLT_TABLE}.tsv ./dump/tsv/

## dump road data as sql
mkdir -p dump/sql
pg_dump -d ${PG_DB} -t ${OSM_BLT_TABLE} > dump/sql/${OSM_BLT_TABLE}.sql 

## dump as shape 
rm    -rf dump/shape/shp_osm_buildings
mkdir -p  dump/shape/shp_osm_buildings
pgsql2shp -f dump/shape/shp_osm_buildings/${OSM_BLT_TABLE}.shp ${PG_DB} "select gid,osm_id,name,type,area,centroid from ${OSM_BLT_TABLE} where centroid is not null"

psql -U ${PG_ID} -d ${PG_DB} -q -AF, -c "select type,count(*) as N from ${OSM_BLT_TABLE} group by type order by N desc" > dump/${OSM_BLT_TABLE}.fclass_stats.txt
## 
## tempdb=> \d ${OSM_SCHEMA}.osm_buildings
##                                         Table "${OSM_SCHEMA}.osm_buildings"
##   Column  |            Type             |                              Modifiers
## ----------+-----------------------------+----------------------------------------------------------------------
##  gid      | integer                     | not null default nextval('${OSM_SCHEMA}.osm_buildings_gid_seq'::regclass)
##  osm_id   | character varying(10)       |
##  code     | smallint                    |
##  fclass   | character varying(20)       |
##  name     | character varying(100)      |
##  type     | character varying(20)       |
##  geom     | geometry(MultiPolygon,4326) |
##  area     | double precision            |
##  centroid | geometry(Point,4326)        |
## Indexes:
##     "osm_buildings_pkey" PRIMARY KEY, btree (gid)
##     "idx_thailand_osm_buildings_centroid" gist (centroid)
##     "osm_buildings_geom_idx" gist (geom)
## 

psql -U ${PG_ID} -d ${PG_DB} -c "select 1-count(type)::float8/count(gid) from ${OSM_BLT_TABLE}"


