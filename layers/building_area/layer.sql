CREATE OR REPLACE FUNCTION layer_building_area(bbox geometry, zoom_level integer)
     RETURNS TABLE
             (
                 id       integer,
                 geometry geometry,
                 height   integer
              )
AS
$$
 SELECT id, geometry, height
 FROM osm_building_polygon
 WHERE zoom_level < %%VAR:indoor_zoom%% AND geometry && bbox
$$ LANGUAGE SQL IMMUTABLE;
