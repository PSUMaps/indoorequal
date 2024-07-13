CREATE OR REPLACE FUNCTION layer_building_area(bbox geometry, zoom_level integer)
     RETURNS TABLE
             (
                 id       integer,
                 geometry geometry
              )
AS
$$
 SELECT id, geometry
 FROM osm_building_polygon
 WHERE zoom_level < %%VAR:indoor_zoom%% AND geometry && bbox
$$ LANGUAGE SQL IMMUTABLE;
