#!/bin/bash

##  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
## OSM data assessment by creating network groups
##  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::s
##  [set parameters]  
##  some parameters have to be set according to own environment
##  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
##  parameters for PostgreSQL access  
PG_ID=**YOUR_USER**
PGPASSWORD=**YOUR_PASSWORD**
PG_DB=**YOUR_DB_NAME**
PG_HOST=localhost
PG_PORT=5432

## set tablee naems
OSM_SCHEMA=srilanka
OSM_ORG_TABLE=${OSM_SCHEMA}.osm_road
OSM_CHK_TABLE=${OSM_SCHEMA}.osm_road_assessment
OSM_VLD_LINK_TABLE=${OSM_SCHEMA}.osm_road_available
OSM_VLD_NODE_TABLE=${OSM_SCHEMA}.osm_node_available

## set assessment parameters
NUM_THRESHOLD=100
# JV_CLS=jp.ac.ut.csis.pflow.routing2.example.NetworkAssessmentOsm 
JV_CLS2=jp.ac.ut.csis.pflow.routing4.sample.OsmNetworkAssessment
NETWORK_TSV=dump/tsv/${OSM_SCHEMA}.osm_road.tsv
OUTFILE=${OSM_SCHEMA}.osm_road_assessment.tsv

TEMP_DIR=/tmp


##  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
##  run assessment 
##  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo "start network assessment ... "

java -Xmx8G -cp PFlowLibFull-0.1.1.jar ${JV_CLS2} ${NETWORK_TSV} ${OUTFILE}

echo "network assessment done"

##  mv output file to temporary folder 
mv ${OUTFILE} ${TEMP_DIR}/


##  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
##  conduct network assessment 
##  ========================================================
##  -- table schema of assessment result
##  create table %OSM_SCHEMA%.osm_road_assessment (
##  	groupno int4,
## 		nodeid  int4,
##  	num     int4,
##		geom    geometry(POINT,4326) 
##  );  
##  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
psql -U ${PG_ID} -d ${PG_DB} -h ${PG_HOST} -p ${PG_PORT} -q -c "drop   table if exists ${OSM_CHK_TABLE}"
psql -U ${PG_ID} -d ${PG_DB} -h ${PG_HOST} -p ${PG_PORT} -q -c "create table ${OSM_CHK_TABLE} (groupno int4,nodeid int4,num int4,geom geometry(POINT,4326))"
psql -U ${PG_ID} -d ${PG_DB} -h ${PG_HOST} -p ${PG_PORT} -q -c "create index idx_${OSM_SCHEMA}_osm_road_assessment_geom   on ${OSM_CHK_TABLE} using Gist(geom)"
psql -U ${PG_ID} -d ${PG_DB} -h ${PG_HOST} -p ${PG_PORT} -q -c "create index idx_${OSM_SCHEMA}_osm_road_assessment_nodeid on ${OSM_CHK_TABLE} using btree(nodeid)"

## import from TSV
psql             -d ${PG_DB} -h ${PG_HOST} -p ${PG_PORT} -q -c "copy   ${OSM_CHK_TABLE} from '${TEMP_DIR}/${OUTFILE}'  (delimiter E'\t',format csv,encoding 'UTF-8',header true)"
rm ${TEMP_DIR}/${OUTFILE}

mkdir -p dump/tsv
psql -d ${PG_DB} -h ${PG_HOST} -p ${PG_PORT} -q -c  "copy  ${OSM_CHK_TABLE} to '${TEMP_DIR}/${OUTFILE}'  (delimiter E'\t',format csv,encoding 'UTF-8',header true)"
mv ${TEMP_DIR}/${OUTFILE} ./dump/tsv/

mkdir -p dump/sql
pg_dump -d ${PG_DB} -h ${PG_HOST} -p ${PG_PORT} -t ${OSM_CHK_TABLE} > dump/sql/${OSM_CHK_TABLE}.sql

mkdir -p dump/shape/shp_${OSM_CHK_TABLE}
pgsql2shp -h ${PG_HOST} -p ${PG_PORT} -f dump/shape/shp_${OSM_CHK_TABLE}/${OSM_CHK_TABLE}.shp ${PG_DB} ${OSM_CHK_TABLE}



##  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
##  create validated network with threshold value for the number of nodes in a group
##  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
psql -U ${PG_ID} -d ${PG_DB} -h ${PG_HOST} -p ${PG_PORT} -q -c "drop   table if exists ${OSM_VLD_LINK_TABLE}"
psql -U ${PG_ID} -d ${PG_DB} -h ${PG_HOST} -p ${PG_PORT} -q -c "create table ${OSM_VLD_LINK_TABLE} as select o.* from ${OSM_ORG_TABLE} o where (select num from ${OSM_CHK_TABLE} a where o.source=a.nodeid) >= ${NUM_THRESHOLD}"
psql -U ${PG_ID} -d ${PG_DB} -h ${PG_HOST} -p ${PG_PORT} -q -c "create index idx_${OSM_SCHEMA}_osm_road_available_source on ${OSM_VLD_LINK_TABLE} using btree(source)"
psql -U ${PG_ID} -d ${PG_DB} -h ${PG_HOST} -p ${PG_PORT} -q -c "create index idx_${OSM_SCHEMA}_osm_road_available_target on ${OSM_VLD_LINK_TABLE} using btree(target)"
psql -U ${PG_ID} -d ${PG_DB} -h ${PG_HOST} -p ${PG_PORT} -q -c "create index idx_${OSM_SCHEMA}_osm_road_available_geom   on ${OSM_VLD_LINK_TABLE} using Gist(geom_way)"


##  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
##  dump network data
##  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
##  dump as TSV file
mkdir -p dump/tsv
psql             -d ${PG_DB} -h ${PG_HOST} -p ${PG_PORT} -q -c "copy (select * from ${OSM_VLD_LINK_TABLE}) to '${TEMP_DIR}/${OSM_VLD_LINK_TABLE}.tsv'   (delimiter E'\t',format csv,encoding 'UTF-8',header true)"
cp ${TEMP_DIR}/${OSM_VLD_LINK_TABLE}.tsv ./dump/tsv/

##  dump as SQL file
mkdir -p dump/sql 
pg_dump -d ${PG_DB} -h ${PG_HOST} -p ${PG_PORT} -t ${OSM_VLD_LINK_TABLE} > dump/sql/${OSM_VLD_LINK_TABLE}.sql

##  dump as Shape data
mkdir -p dump/shape/shp_${OSM_VLD_LINK_TABLE}
pgsql2shp -h ${PG_HOST} -p ${PG_PORT} -f dump/shape/shp_${OSM_VLD_LINK_TABLE}/${OSM_VLD_LINK_TABLE}.shp ${PG_DB} ${OSM_VLD_LINK_TABLE}



##  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
##  create valid node table
##  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
psql -U ${PG_ID} -d ${PG_DB} -h ${PG_HOST} -p ${PG_PORT} -q -c "drop   table if exists ${OSM_VLD_NODE_TABLE}"
psql -U ${PG_ID} -d ${PG_DB} -h ${PG_HOST} -p ${PG_PORT} -q -c "create table ${OSM_VLD_NODE_TABLE} as  select node,geom from ( select source as node,ST_StartPoint(geom_way) as geom from ${OSM_VLD_LINK_TABLE} union select target as node,ST_EndPoint(geom_way) as geom from ${OSM_VLD_LINK_TABLE}) sub"
psql -U ${PG_ID} -d ${PG_DB} -h ${PG_HOST} -p ${PG_PORT} -q -c "create index idx_${OSM_SCHEMA}_osm_node_available_source on ${OSM_VLD_NODE_TABLE} using btree(node)"
psql -U ${PG_ID} -d ${PG_DB} -h ${PG_HOST} -p ${PG_PORT} -q -c "create index idx_${OSM_SCHEMA}_osm_node_available_geom   on ${OSM_VLD_NODE_TABLE} using Gist(geom)"

##  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
##  dump node data
##  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
##  dump as TSV file
mkdir -p dump/tsv
psql             -d ${PG_DB} -h ${PG_HOST} -p ${PG_PORT} -q -c "copy (select * from ${OSM_VLD_NODE_TABLE}) to '${TEMP_DIR}/${OSM_VLD_NODE_TABLE}.tsv'  (delimiter E'\t',format csv,encoding 'UTF-8',header true)"
cp ${TEMP_DIR}/${OSM_VLD_NODE_TABLE}.tsv ./dump/tsv/

##  dump as SQL file
mkdir -p dump/sql
pg_dump -d ${PG_DB} -h ${PG_HOST} -p ${PG_PORT} -t ${OSM_VLD_NODE_TABLE} > dump/sql/${OSM_VLD_NODE_TABLE}.sql

##  dump as shape data
mkdir -p dump/shape/shp_${OSM_VLD_NODE_TABLE}
pgsql2shp  -h ${PG_HOST} -p ${PG_PORT} -f dump/shape/shp_${OSM_VLD_NODE_TABLE}/${OSM_VLD_NODE_TABLE}.shp ${PG_DB} ${OSM_VLD_NODE_TABLE}



psql -U ${PG_ID} -d ${PG_DB} -h ${PG_HOST} -p ${PG_PORT} -q -c "select count(distinct groupno) as N_group, count(distinct case when num>=100 then groupno else null end) as N_valid from ${OSM_CHK_TABLE}"

## select N_valid, N_valid::float8/N_all as ratio from (select count(*) as N_valid from kenya.osm_road_available) a left join (select count(*) as N_all from kenya.osm_road) b on true;
## select L_valid/1000.0, L_valid/L_all as ratio from (select sum(ST_Length(geography(geom_way))) as L_valid from kenya.osm_road_available) a left join (select sum(ST_Length(Geography(geom_way))) as L_all from kenya.osm_road) b on true;

## select N_valid, N_valid::float8/N_all as ratio from (select count(*) as N_valid from kenya.osm_node_available) a left join (select count(*) as N_all from kenya.osm_road_assessment) b on true;

