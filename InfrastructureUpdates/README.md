# Infrastructure Update Tools
A set of tools for creating/extracting infrastructure data files/database such as PoI data for reallocation, Road Network Data for route interpolation, Voronoi of Cell Tower 

## How it works
In principle,  it contain a set of programs/scripts/tools for extracting necessary data from OSM (Open Street Map) Data. OSM data can be downloaded from [geofabrik](http://download.geofabrik.de/) in .osm.pbf format, then import that file to [PostgreSQL](https://www.postgresql.org/download/) (with PostGIS) Database. 

## Prerequisites
* Linux or Mac environment
* OSM data of the target country ([geofabrik](http://download.geofabrik.de/))
* [PostgreSQL](https://www.postgresql.org/download/) (with PostGIS) Database
* Make sure PostGIS extension is installed on PostgreSQL

## Usage

#### Step 1: Import OSM data to PostgresQL
1. Put OSM data (.osm.pbf) in the same folder with the script.
2. Edit file  **1_run_osm2po.sh** to specify database connection and country name
    ```
    #!/bin/sh

    ##  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    ##  OSM data conversion with OSM2PO (http://osm2po.de/)
    ##  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    PG_ID=**YOUR_USER**                    ## user id for PostgreSQL
    PGPASSWORD=**YOUR_PASSWORD**           ## password for PostgreSQL
    PG_DB=**YOUR_DB_NAME**                 ## target database name
    PG_HOST=localhost                      ## database server ip: localhost
    PG_PORT=5432	
    OSM_SCHEMA=**OSM_COUNTRY_ANME**        ## country name data such as srilanka
    TEMP_DIR=/tmp
    ```
3. Run command  

    Open terminal navigate to software directory and run command "1_run_osm2po.sh"
    ```
    [\CDR-analysis-tools-std\InfrastructureUpdates]#./1_run_osm2po.sh
    ```
4. Check data in database with PgAdmin  

#### Step 2: OSM data assessment 
1. Edit file  **2_osm_assessment.sh** to specify database connection and country name
    ```
    #!/bin/bash

    ##  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    ## OSM data assessment by creating network groups
    ##  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::s
    ##  [set parameters]  
    ##  some parameters have to be set according to own environment
    ##  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    ##  parameters for PostgreSQL access  
    PG_ID=**YOUR_USER**                                     ## user id for PostgreSQL
    PGPASSWORD=**YOUR_PASSWORD**                            ## password for PostgreSQL
    PG_DB=**YOUR_DB_NAME**                                  ## target database name
    PG_HOST=localhost                                       ## database server ip: localhost
    PG_PORT=5432

    ## set tablee naems
    OSM_SCHEMA=**OSM_COUNTRY_ANME**                        ## country name data such as srilanka
    OSM_ORG_TABLE=${OSM_SCHEMA}.osm_road
    OSM_CHK_TABLE=${OSM_SCHEMA}.osm_road_assessment
    OSM_VLD_LINK_TABLE=${OSM_SCHEMA}.osm_road_available
    OSM_VLD_NODE_TABLE=${OSM_SCHEMA}.osm_node_available

    ```
3. Run command  

    Open terminal navigate to software directory and run command "2_osm_assessment.sh"
    ```
    [\CDR-analysis-tools-std\InfrastructureUpdates]#./2_osm_assessment.sh
    ```

#### Step 3: OSM data conversion on building POI
1. Edit file  **3_create_building_poi_table.sh** to specify database connection and country name
    ```
    #!/bin/bash

    ## ========================================================
    ## OSM data conversion on building POI
    ## ========================================================
    ## POI data from OSM building data
    ## set parameters
    PG_HOST=localhost                                   ## database server ip: localhost
    PG_ID=**YOUR_USER**                                 ## user id for PostgreSQL
    PGPASSWORD=**YOUR_PASSWORD**                        ## password for PostgreSQL
    PG_DB=**YOUR_DB_NAME**                              ## target database name
    PG_PORT=5432

    OSM_SCHEMA=**OSM_COUNTRY_ANME**                     ## country name data such as srilanka
    OSM_BLT_TABLE=${OSM_SCHEMA}.osm_buildings
    TEMP_DIR=/tmp

    ```
3. Run command  

    Open terminal navigate to software directory and run command "3_create_building_poi_table.sh"
    ```
    [\CDR-analysis-tools-std\InfrastructureUpdates]#./3_create_building_poi_table.sh
    ```


## Author
**Hiroshi KANASUGI** :  A project researcher at Center for Spatial Information Science, University of Tokyo.

## License

Free to use

## Acknowledgments

* [Spatial Data Commons](http://sdc.csis.u-tokyo.ac.jp/), CSIS, The University of Tokyo
* [Shibasaki Lab](https://shiba.iis.u-tokyo.ac.jp), The University of Tokyo
* [Center for Spatial Information Science](http://www.csis.u-tokyo.ac.jp/en/), The University of Tokyo

