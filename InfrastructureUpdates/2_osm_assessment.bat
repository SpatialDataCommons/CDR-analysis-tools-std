@echo off

::  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: OSM data assessment by creating network groups
::  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::s
::  [set parameters]  
::  some parameters have to be set according to own environment
::  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::  parameters for PostgreSQL access  
set PG_ID=**YOUR_USER**
set PGPASSWORD=**YOUR_PASSWORD**
set PG_DB=**YOUR_DB_NAME**
set PG_HOST=localhost
set PG_PORT=5432
set TEMP_DIR=**FULL_TMP_PATH**
set PG_BIN_PATH=D:\PostgreSQL\9.6\bin
set PATH=%PATH%;%PG_BIN_PATH%

:: set tablee naems
set OSM_SCHEMA=**OSM_COUNTRY_ANME**
set OSM_ORG_TABLE=%OSM_SCHEMA%.osm_road
set OSM_CHK_TABLE=%OSM_SCHEMA%.osm_road_assessment
set OSM_VLD_LINK_TABLE=%OSM_SCHEMA%.osm_road_available
set OSM_VLD_NODE_TABLE=%OSM_SCHEMA%.osm_node_available

:: set assessment parameters
set NUM_THRESHOLD=100
:: JV_CLS=jp.ac.ut.csis.pflow.routing2.example.NetworkAssessmentOsm 
set JV_CLS2=jp.ac.ut.csis.pflow.routing4.sample.OsmNetworkAssessment
set NETWORK_TSV=dump\tsv\%OSM_SCHEMA%.osm_road.tsv
set OUTFILE=%OSM_SCHEMA%.osm_road_assessment.tsv

::  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::  run assessment 
::  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo "start network assessment ... "

java -Xmx8G -cp PFlowLibFull-0.1.1.jar %JV_CLS2% %NETWORK_TSV% %OUTFILE%

echo "network assessment done"

::  mv output file to temporary folder 
move %OUTFILE% %TEMP_DIR%\


::  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::  conduct network assessment 
::  ========================================================
::  -- table schema of assessment result
::  create table %OSM_SCHEMA%.osm_road_assessment (
::  	groupno int4,
:: 		nodeid  int4,
::  	num     int4,
::		geom    geometry(POINT,4326) 
::  );  
::  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
psql -U %PG_ID% -d %PG_DB% -h %PG_HOST% -p %PG_PORT% -q -c "drop   table if exists %OSM_CHK_TABLE%"
psql -U %PG_ID% -d %PG_DB% -h %PG_HOST% -p %PG_PORT% -q -c "create table %OSM_CHK_TABLE% (groupno int4,nodeid int4,num int4,geom geometry(POINT,4326))"
psql -U %PG_ID% -d %PG_DB% -h %PG_HOST% -p %PG_PORT% -q -c "create index idx_%OSM_SCHEMA%_osm_road_assessment_geom   on %OSM_CHK_TABLE% using Gist(geom)"
psql -U %PG_ID% -d %PG_DB% -h %PG_HOST% -p %PG_PORT% -q -c "create index idx_%OSM_SCHEMA%_osm_road_assessment_nodeid on %OSM_CHK_TABLE% using btree(nodeid)"

:: import from TSV
psql -U %PG_ID% -d %PG_DB% -h %PG_HOST% -p %PG_PORT% -q -c "copy   %OSM_CHK_TABLE% from '%TEMP_DIR%\%OUTFILE%'  (delimiter E'\t',format csv,encoding 'UTF-8',header true)"
del %TEMP_DIR%\%OUTFILE%

mkdir dump\tsv
psql -U %PG_ID% -d %PG_DB% -h %PG_HOST% -p %PG_PORT% -q -c  "copy  %OSM_CHK_TABLE% to '%TEMP_DIR%\%OUTFILE%'  (delimiter E'\t',format csv,encoding 'UTF-8',header true)"
move %TEMP_DIR%\%OUTFILE% dump\tsv\

mkdir dump\sql
pg_dump -U %PG_ID% -d %PG_DB% -h %PG_HOST% -p %PG_PORT% -t %OSM_CHK_TABLE% > dump\sql\%OSM_CHK_TABLE%.sql

mkdir dump\shape\shp_%OSM_CHK_TABLE%
%PG_BIN_PATH%\pgsql2shp -P %PGPASSWORD% -u %PG_ID% -h %PG_HOST% -p %PG_PORT% -f dump\shape\shp_%OSM_CHK_TABLE%\%OSM_CHK_TABLE%.shp %PG_DB% %OSM_CHK_TABLE%



::  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::  create validated network with threshold value for the number of nodes in a group
::  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
psql -U %PG_ID% -d %PG_DB% -h %PG_HOST% -p %PG_PORT% -q -c "drop   table if exists %OSM_VLD_LINK_TABLE%"
psql -U %PG_ID% -d %PG_DB% -h %PG_HOST% -p %PG_PORT% -q -c "create table %OSM_VLD_LINK_TABLE% as select o.* from %OSM_ORG_TABLE% o where (select num from %OSM_CHK_TABLE% a where o.source=a.nodeid) >= %NUM_THRESHOLD%"
psql -U %PG_ID% -d %PG_DB% -h %PG_HOST% -p %PG_PORT% -q -c "create index idx_%OSM_SCHEMA%_osm_road_available_source on %OSM_VLD_LINK_TABLE% using btree(source)"
psql -U %PG_ID% -d %PG_DB% -h %PG_HOST% -p %PG_PORT% -q -c "create index idx_%OSM_SCHEMA%_osm_road_available_target on %OSM_VLD_LINK_TABLE% using btree(target)"
psql -U %PG_ID% -d %PG_DB% -h %PG_HOST% -p %PG_PORT% -q -c "create index idx_%OSM_SCHEMA%_osm_road_available_geom   on %OSM_VLD_LINK_TABLE% using Gist(geom_way)"


::  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::  dump network data
::  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::  dump as TSV file
mkdir dump\tsv
psql -U %PG_ID% -d %PG_DB% -h %PG_HOST% -p %PG_PORT% -q -c "copy (select * from %OSM_VLD_LINK_TABLE%) to '%TEMP_DIR%\%OSM_VLD_LINK_TABLE%.tsv'   (delimiter E'\t',format csv,encoding 'UTF-8',header true)"
copy %TEMP_DIR%\%OSM_VLD_LINK_TABLE%.tsv dump\tsv\

::  dump as SQL file
mkdir dump\sql 
pg_dump -U %PG_ID% -d %PG_DB% -h %PG_HOST% -p %PG_PORT% -t %OSM_VLD_LINK_TABLE% > dump\sql\%OSM_VLD_LINK_TABLE%.sql

::  dump as Shape data
mkdir dump\shape\shp_%OSM_VLD_LINK_TABLE%
%PG_BIN_PATH%\pgsql2shp -P %PGPASSWORD% -u %PG_ID% -h %PG_HOST% -p %PG_PORT% -f dump\shape\shp_%OSM_VLD_LINK_TABLE%\%OSM_VLD_LINK_TABLE%.shp %PG_DB% %OSM_VLD_LINK_TABLE%



::  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::  create valid node table
::  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
psql -U %PG_ID% -d %PG_DB% -h %PG_HOST% -p %PG_PORT% -q -c "drop   table if exists %OSM_VLD_NODE_TABLE%"
psql -U %PG_ID% -d %PG_DB% -h %PG_HOST% -p %PG_PORT% -q -c "create table %OSM_VLD_NODE_TABLE% as  select node,geom from ( select source as node,ST_StartPoint(geom_way) as geom from %OSM_VLD_LINK_TABLE% union select target as node,ST_EndPoint(geom_way) as geom from %OSM_VLD_LINK_TABLE%) sub"
psql -U %PG_ID% -d %PG_DB% -h %PG_HOST% -p %PG_PORT% -q -c "create index idx_%OSM_SCHEMA%_osm_node_available_source on %OSM_VLD_NODE_TABLE% using btree(node)"
psql -U %PG_ID% -d %PG_DB% -h %PG_HOST% -p %PG_PORT% -q -c "create index idx_%OSM_SCHEMA%_osm_node_available_geom   on %OSM_VLD_NODE_TABLE% using Gist(geom)"

::  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::  dump node data
::  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::  dump as TSV file
mkdir dump\tsv
psql -U %PG_ID% -d %PG_DB% -h %PG_HOST% -p %PG_PORT% -q -c "copy (select * from %OSM_VLD_NODE_TABLE%) to '%TEMP_DIR%\%OSM_VLD_NODE_TABLE%.tsv'  (delimiter E'\t',format csv,encoding 'UTF-8',header true)"
copy %TEMP_DIR%\%OSM_VLD_NODE_TABLE%.tsv dump\tsv\

::  dump as SQL file
mkdir dump\sql
pg_dump -U %PG_ID% -d %PG_DB% -h %PG_HOST% -p %PG_PORT% -t %OSM_VLD_NODE_TABLE% > dump\sql\%OSM_VLD_NODE_TABLE%.sql

::  dump as shape data
mkdir dump\shape\shp_%OSM_VLD_NODE_TABLE%
%PG_BIN_PATH%\pgsql2shp -P %PGPASSWORD% -u %PG_ID% -h %PG_HOST% -p %PG_PORT% -f dump\shape\shp_%OSM_VLD_NODE_TABLE%\%OSM_VLD_NODE_TABLE%.shp %PG_DB% %OSM_VLD_NODE_TABLE%



psql -U %PG_ID% -d %PG_DB% -h %PG_HOST% -p %PG_PORT% -q -c "select count(distinct groupno) as N_group, count(distinct case when num>=100 then groupno else null end) as N_valid from %OSM_CHK_TABLE%"

