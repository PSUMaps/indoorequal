
-- etldoc: layer_area_name[shape=record fillcolor=lightpink,
-- etldoc:     style="rounded,filled", label="layer_area_name | <z17_> z17+" ] ;

DROP FUNCTION IF EXISTS layer_building_area_name(geometry, integer, numeric);
DROP FUNCTION IF EXISTS layer_building_area_name(geometry, integer);
CREATE FUNCTION layer_building_area_name(bbox geometry, zoom_level integer)
RETURNS TABLE(geometry geometry, name text) AS $$
   -- etldoc: osm_area_point -> layer_area_name:z17_
   SELECT geometry,
          COALESCE(NULLIF(name, ''), '') AS name
    FROM osm_building_area_point
    WHERE zoom_level < %%VAR:indoor_zoom%% AND geometry && bbox;

$$ LANGUAGE SQL IMMUTABLE;
