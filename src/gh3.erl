-module(gh3).

-export([to_polyfills/2, from_polyfill/1]).

%% @doc Transforms a pre-parsed GeoJSON map into a list of polyfills.
%%
%% Example:
%%
%% ```
%% %% First download a map from https://geojson-maps.ash.ms
%% {ok, JSONb} = file:read_file("custom.geo.json"),
%% JSON = jsx:decode(JSONb, []),
%% Poly = h3:to_polyfills(JSON, 8),
%% '''
-spec to_polyfills(JSON :: map(), Resolution :: h3:resolution()) ->
    [[h3:h3index(), ...], ...].
to_polyfills(#{<<"features">> := Features}, Resolution) ->
    to_polyfills(Features, Resolution);
to_polyfills([#{<<"geometry">> := Geometry} | _], Resolution) ->
    to_polyfills(Geometry, Resolution);
to_polyfills(
    #{<<"type">> := <<"MultiPolygon">>, <<"coordinates">> := Coordinates},
    Resolution
) ->
    geojson_parse_polygons(Coordinates, Resolution);
to_polyfills(
    #{<<"type">> := <<"Polygon">>, <<"coordinates">> := Coordinates},
    Resolution
) ->
    h3:polyfill(geojson_parse_polygon(Coordinates), Resolution).

geojson_parse_polygons(Polygons, Resolution) ->
    lists:map(
        fun (P) -> h3:polyfill(geojson_parse_polygon(P), Resolution) end,
        Polygons
    ).

geojson_parse_polygon(OutlineAndHoles) ->
    lists:map(fun (OH) -> geojson_transform_coordinates(OH) end, OutlineAndHoles).

geojson_transform_coordinates(CoordinateList) ->
    lists:map(fun ([Lat, Lon]) -> {float(Lon), float(Lat)} end, CoordinateList).

%% @doc Converts a polyfill into a GeoJSON map.
%%
%% Round-trip example:
%%
%% ```
%% %% First download a map from https://geojson-maps.ash.ms
%% {ok, JSONb} = file:read_file("custom.geo.json"),
%% JSON = jsx:decode(JSONb, []),
%% Polys = h3:to_polyfills(JSON, 9),
%% Unsorted = lists:flatten(Polys),
%% Sorted = lists:sort(fun(A, B) -> h3:get_resolution(A) < h3:get_resolution(B) end, Unsorted),
%% Compacted = h3:compact(Sorted),
%% NewJSON = h3:from_polyfill(Compacted),
%% NewJSONb = jsx:encode(NewJSON),
%% ok = file:write_file("custom.reconstructed.json", NewJSONb).
%% ## Try plotting at http://geojson.tools
%% '''
from_polyfill(Polyfill) ->
    #{
        <<"type">> => <<"MultiPolygon">>,
        <<"coordinates">> => multi_polygon_to_geojson(h3:set_to_multi_polygon(Polyfill))
    }.

multi_polygon_to_geojson({Lat, Lon}) ->
    [Lon, Lat];
multi_polygon_to_geojson(Polygons) ->
    lists:map(fun (P) -> multi_polygon_to_geojson(P) end, Polygons).
