# Infrastructure Update Tools
A set of tools for creating/extracting infrastructure data files/database such as PoI data for reallocation, Road Network Data for route interpolation, Voronoi of Cell Tower 

## How it works
In principle,  it contain a set of programs/scripts/tools for extracting necessary data from OSM (Open Street Map) Data. OSM data can be downloaded from [geofabrik](http://download.geofabrik.de/) in .osm.pbf format, then import that file to [PostgreSQL](https://www.postgresql.org/download/) (with PostGIS) Database. 

## Prerequisites
* Linux or Mac environment or Windows
* OSM data of the target country ([geofabrik](http://download.geofabrik.de/))
* [PostgreSQL](https://www.postgresql.org/download/) (with PostGIS) Database (tested on 9.6)
* Make sure PostGIS extension is installed on PostgreSQL

## Usage
#### Step 0: Prepare PostgresQL Database
1. Create database name postgres "osmdata"
2. Create PostGIS extension on newly created database
    ```
    use osmdata;
    create extension postgis;
    ```
3. Make sure you have user/pass for connecting database

#### Step 1: Import OSM data to PostgresQL
1. Put OSM data (.osm.pbf) in the same folder with the script.
2. Edit file **"1_run_osm2po.bat"** for windows or **"1_run_osm2po.sh"** for linux to specify database connection and country name

    For Windows
    ```
    @echo off

    :: ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    ::  OSM data conversion with OSM2PO (http://osm2po.de/)
    ::  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    set PG_ID=**YOUR_USER**                    ## user id for PostgreSQL
    set PGPASSWORD=**YOUR_PASSWORD**           ## password for PostgreSQL
    set PG_DB=**YOUR_DB_NAME**                 ## target database name
    set PG_HOST=localhost                      ## database server ip: localhost
    set PG_PORT=5432	
    set OSM_SCHEMA=**OSM_COUNTRY_ANME**        ## country name data such as srilanka
    set TEMP_DIR=**FULL_TMP_PATH**             ## ex: D:\CDR-analysis-tools-std\InfrastructureUpdates\tmp
    set PG_BIN_PATH=D:\PostgreSQL\9.6\bin      ## full path of postgres bin folder

    ```

    For Linux
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

    **For windows**, Open command prompt and navigate to software directory and run command "1_run_osm2po.bat"
    ```
    D:\CDR-analysis-tools-std\InfrastructureUpdates\>1_run_osm2po.bat
    ```

    **For Linux**, Open terminal navigate to software directory and run command "1_run_osm2po.sh"
    ```
    [\CDR-analysis-tools-std\InfrastructureUpdates]#./1_run_osm2po.sh
    ```
4. Check data in database with PgAdmin and exported file on dump folder

#### Step 2: OSM data assessment 
1. Edit file   **2_osm_assessment.bat** for Windows or **2_osm_assessment.sh** for Linux for Linux  to specify database connection and country name
  
    For Windows
    ```
    @echo off

    ::  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    :: OSM data assessment by creating network groups
    ::  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::s
    ::  [set parameters]  
    ::  some parameters have to be set according to own environment
    ::  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    ::  parameters for PostgreSQL access  
    set PG_ID=**YOUR_USER**                                     ## user id for PostgreSQL
    set PGPASSWORD=**YOUR_PASSWORD**                            ## password for PostgreSQL
    set PG_DB=**YOUR_DB_NAME**                                  ## target database name
    set PG_HOST=localhost
    set PG_PORT=5432
    set TEMP_DIR=**FULL_TMP_PATH**                              ## ex: D:\CDR-analysis-tools-std\InfrastructureUpdates\tmp
    set PG_BIN_PATH=D:\PostgreSQL\9.6\bin                       ## full path of postgres bin folder

    :: set tablee naems
    set OSM_SCHEMA=**OSM_COUNTRY_ANME**        ## country name data such as srilanka
    set OSM_ORG_TABLE=%OSM_SCHEMA%.osm_road
    set OSM_CHK_TABLE=%OSM_SCHEMA%.osm_road_assessment
    set OSM_VLD_LINK_TABLE=%OSM_SCHEMA%.osm_road_available
    set OSM_VLD_NODE_TABLE=%OSM_SCHEMA%.osm_node_available

    ```

    For Linux
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


    **For windows**, Open command prompt and navigate to software directory and run command "2_osm_assessment.bat"
    ```
    D:\CDR-analysis-tools-std\InfrastructureUpdates\>2_osm_assessment.bat
    ```

    **For Linux**, Open terminal navigate to software directory and run command "2_osm_assessment.sh"
    ```
    [\CDR-analysis-tools-std\InfrastructureUpdates]#./2_osm_assessment.sh
    ```
4. Check data in database with PgAdmin and exported file on dump folder (_assessment)

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

