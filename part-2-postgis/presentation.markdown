






    ____      __                __           _______________
   /  _/___  / /__________     / /_____     / ____/  _/ ___/
   / // __ \/ __/ ___/ __ \   / __/ __ \   / / __ / / \__ \ 
 _/ // / / / /_/ /  / /_/ /  / /_/ /_/ /  / /_/ // / ___/ / 
/___/_/ /_/\__/_/   \____/   \__/\____/   \____/___//____/  
                                                            


























    ____             __     ___        ____             __  _______________
   / __ \____ ______/ /_   |__ \ _    / __ \____  _____/ /_/ ____/  _/ ___/
  / /_/ / __ `/ ___/ __/   __/ /(_)  / /_/ / __ \/ ___/ __/ / __ / / \__ \ 
 / ____/ /_/ / /  / /_    / __/_    / ____/ /_/ (__  ) /_/ /_/ // / ___/ / 
/_/    \__,_/_/   \__/   /____(_)  /_/    \____/____/\__/\____/___//____/  
                                                                           

























# Last time

* GIS Primitives

    * (Multi)Point
    * (Multi)Linestring
    * (Multi)Polygon

* Coordinate systems and SRID

* Representation formats

    * Well Known Text (WKT)
    * Well Known Binary (WKB)
    * Keyhole Markup Language (KML)
    * GeoJSON
























# Correction

  "GeoJSON DOES support coordianate systems and SRID. It just optional, and
   the default is the same as Google Maps so it's almost never included."























# Today's Objectives

* Work with some tools to explore a dataset
* Learn some basic GIS SQL extensions
* Run some queries


























# Tools

* Postgres.app (w/ Postgres & PostGIS)
* OpenJUMP


































# Our Dataset

Let's explore..

    ______    __                      __              __
   / ____/___/ /___ ___  ____  ____  / /_____  ____  / /
  / __/ / __  / __ `__ \/ __ \/ __ \/ __/ __ \/ __ \/ / 
 / /___/ /_/ / / / / / / /_/ / / / / /_/ /_/ / / / /_/  
/_____/\__,_/_/ /_/ /_/\____/_/ /_/\__/\____/_/ /_(_)   
                                                        
















# Create our database

    psql -h localhost

    CREATE DATABASE itg_p2;


















# Setup GIS Functions

    SELECT PostGIS_Version();                                   // BOOM!!

    CREATE SCHEMA postgis;
    CREATE EXTENSION postgis WITH SCHEMA postgis;

    SELECT postgis.PostGIS_Version();    			// YUCK!

    ALTER ROLE "mark" SET search_path TO "$user",postgis,public;

    SELECT PostGIS_Version();           			// SUCCESS














# Load in the data

   osm2pgsql -H localhost -U mark -d itg_p2 edmonton.osm















# Explore this data

    psql -h localhost itg_p2

    \d

* One table for each type of data (line, point, polygon, roads)
* But what does it look like?









# Visualizing the data

    /x ON
    SELECT osm_id, way FROM planet_osm_point LIMIT 10;		// WHAT?

* Use OpenJUMP to turn Geometry columns to visual data

    SELECT * FROM planet_osm_point;				// IN OpenJUMP

* Select a Feature and view it's info






# Query the data

    SELECT * FROM planet_osm_point WHERE amenity='cafe';      // Coffee & tea
    SELECT * FROM planet_osm_roads WHERE name LIKE '%Jasper Avenue%';










# Use some GIS functions

* PostGIS implements "Simple Features for SQL Specification" from
  the Open Geospatial Consortium
* Lots of SQL functions you can use to modify and query your geometry








# GIS Query Examples

    SELECT ST_BUFFER(way, 50) FROM planet_osm_roads WHERE name LIKE '%Jasper%';

    SELECT *
    FROM
	planet_osm_point AS point,
	(SELECT * FROM planet_osm_roads WHERE name LIKE '%Jasper%') AS jasper
    WHERE point.amenity='cafe' and ST_DWITHIN(point.way, jasper.way, 100);






# GIS Functions you should know

ST_DWithin(geometry1, geometry2, distance)

    Returns true if geometries are within a certain distance of one another.

ST_Contains(geometry1, geometry2)

    Geometry 1 entirely contains geometry 2.

ST_Buffer(geometry, distance)

    Create a new geometry by expanding the outer bounds of one by a certain
    distance.

