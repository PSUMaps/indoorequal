DROP TRIGGER IF EXISTS trigger_flag_point ON osm_building_polygon;
DROP TRIGGER IF EXISTS trigger_refresh ON building_area_point.updates;

DROP MATERIALIZED VIEW IF EXISTS  osm_building_area_point CASCADE;

CREATE MATERIALIZED VIEW osm_building_area_point AS (
    SELECT
        wp.id,
        ST_PointOnSurface(wp.geometry) AS geometry,
        wp.name
    FROM osm_building_polygon AS wp
);
CREATE INDEX IF NOT EXISTS osm_area_point_geometry_idx ON osm_building_area_point USING gist (geometry);

-- Handle updates

CREATE SCHEMA IF NOT EXISTS building_area_point;

CREATE TABLE IF NOT EXISTS building_area_point.updates(id serial primary key, t text, unique (t));
CREATE OR REPLACE FUNCTION building_area_point.flag() RETURNS trigger AS $$
BEGIN
    INSERT INTO building_area_point.updates(t) VALUES ('y')  ON CONFLICT(t) DO NOTHING;
    RETURN null;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION building_area_point.refresh() RETURNS trigger AS
  $BODY$
  BEGIN
    RAISE LOG 'Refresh building_area_point';
    REFRESH MATERIALIZED VIEW osm_area_point;
    DELETE FROM building_area_point.updates;
    RETURN null;
  END;
  $BODY$
language plpgsql;

CREATE TRIGGER trigger_flag_point
    AFTER INSERT OR UPDATE OR DELETE ON osm_indoor_polygon
    FOR EACH STATEMENT
    EXECUTE PROCEDURE building_area_point.flag();

CREATE CONSTRAINT TRIGGER trigger_refresh
    AFTER INSERT ON building_area_point.updates
    INITIALLY DEFERRED
    FOR EACH ROW
    EXECUTE PROCEDURE building_area_point.refresh();
