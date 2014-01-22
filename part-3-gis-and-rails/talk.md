# Intro to GIS: Part 3, PostGIS and Rails









## Objectives

1. Setup Rails with PostGIS
2. Effectively use PostGIS with ActiveRecord









## Previously..

1. Setup Postgres & PostGIS
2. Went over GIS types and SQL functions
3. Imported Edmonton data into PostGIS database













## Setting up Rails and PostGIS

### 1. Create a new Rails app

    rails new . --database=postgresql










### 2. Install activerecord-postgis-adapter by @danielazuma

Add `activerecord-postgis-adapter` to Gemfile

    bundle install








### 3. Configure PostGIS adapter in database.yml

Remove the production configuration, and replace references to `postgresql`
with `postgis`. Also enable the `postgis-extension` settings, and add it
to the `schema_search_path`. You can get all the details in the
[gem doc](https://github.com/dazuma/activerecord-postgis-adapter/blob/master/Documentation.rdoc#recommended-configuration),
but should end up with a configuration that looks like this:

    development:
      adapter: postgis
      encoding: unicode
      postgis_extension: true
      schema_search_path: public,postgis
      pool: 5
      database: my_app_development    # substitute your dev database name
      username: my_app_user           # substitute the username your app will use to connect
      password: my_app_password       # substitute the user's password
      su_username: my_global_user     # substitute a superuser for the database
      su_password: my_global_pasword  # substitute the superuser's password

You can now create your database with `bin/rake db:create`.







### 4. Creating a spatial table

You use migrations to create spatial tables, just like normal.

    create_table :my_spatial_table do |t|
      t.column :shape1, :geometry
      t.geometry :shape2
      t.line_string :path, :srid => 3785
      t.point :lonlat, :geographic => true
      t.point :lonlatheight, :geographic => true, :has_z => true
    end

Notice the `geometry`, `line_string`, and `point` types. Notice that you can
constrain geometry columns to a single SRID, or use the `geographic` constraint
to limit to SRID 4326.
 
If you're going to use an geometry for joins or querying you should consider
adding an index:

    change_table :my_spatial_table do |t|
        t.index :lonlat, :spatial => true
    end

It's worthwhile profiling with `EXPLAIN` to determine if you're missing indexes
or have more than you need, as indexes can significantly speed up queries but
can also grow to significant size so should be used judiciously.

Try creating a simple model using a Rails generator:

    bin/rails generate model venue name:string location:point

Edit the migration to add a spatial index, and set the location point to be
geographic:

    class CreateVenues < ActiveRecord::Migration
      def change
        create_table :venues do |t|
          t.string :name
          t.point :location, :geographic => true

          t.timestamps
        end

        change_table :venues do |t|
            t.index :location, :spatial => true
        end
      end
    end

We'll also setup a special column factory so that location will work with
geographic spherical coordinates when setting/reading values.

    # By default, use the GEOS implementation for spatial columns.
    self.rgeo_factory_generator = RGeo::Geos.factory_generator

    # But use a geographic implementation for the :lonlat column.
    set_rgeo_factory_for_column(:lonlat, RGeo::Geographic.spherical_factory(:srid => 4326))

Now create some Venues in the console. We'll use these later.

    Venue.create(name: "Cavern", location: 'POINT(-113.4990033 53.542463)')
    Venue.create(name: "Credo", location: 'POINT(-113.4994857 53.5417982)')
    Venue.create(name: "Tim Hortons", location: 'POINT(-113.4952626, 53.5410348)')








### 5. Import OpenStreetMap data

We'll skip this import now, as it takes ~5 minutes. Here's the command:

    osm2pgsql -H localhost -d part-3-gis-and-rails_development alberta-latest.osm














### 6. Writing PostGIS queries in ActiveRecord

You can do simple equality queries easily:

    Venue.where(location: 'POINT(-113.4990033 53.542463)')

This is lame. You can't really do anything else interesting out of the box and
still use PostGIS with ActiveRecord and AREL.








### 7. Using Squeel

If you're looking to do more complex queries and use SQL functions you can't
with the standard ActiveRecord DSL. The recommended approach is to use the
squeel gem.

You can the write queries like this:

    my_polygon = get_my_polygon()       # Obtain the polygon as an RGeo geometry
    MySpatialTable.where{st_intersects(lonlat, my_polygon)}.first

See the `activerecord-postgis-adapter` for more examples.










### 8. Gotchas

* Querying with invalid EWKT will set geometries to `nil`, not raise an exception.
* Setting a factory for your columns can save you a lot of time later on
* These queries will be slow and use lots of memory, leave time to optimize


## Resources

* https://github.com/dazuma/activerecord-postgis-adapter/blob/master/Documentation.rdoc
* https://twitter.com/danielazuma
* https://github.com/dazuma
* http://www.postgresql.org/docs/8.3/static/performance-tips.html
* http://revenant.ca/www/postgis/workshop/analysis.html
* http://download.geofabrik.de/north-america/canada/alberta.html
