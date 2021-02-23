GeoJSON H3
==========

This is an Erlang library providing helpers for between [GeoJSON] polygons and [H3] polyfills.

## Examples

### GeoJSON to polyfill

```erl
{ok, JSONb} = file:read_file("usa.geo.json"),
JSON = jsx:decode(JSONb, []),
Poly = gh3:to_polyfills(JSON, 7),
Flattened = lists:flatten(Poly),
Unsorted = h3:compact(Flattened),
Sorted = lists:sort(fun(A, B) -> h3:get_resolution(A) < h3:get_resolution(B) end, Unsorted),
```

### Membership tests

The functionality in this section is all provided by [`herlang-h3`].

```erl
DairyIsle = h3:from_geo({37.96648742360273, -91.36002165669227}, 12),
TarponSprings = h3:from_geo({28.14209546931603, -82.75665097150251}, 12),
Bimini = h3:from_geo({25.726864906131482, -79.29676154106401}, 12),
{true, _} = timer:tc(fun() -> h3:contains(DairyIsle, Unsorted),
{true, _} = h3:contains(TarponSprings, Unsorted),
false = h3:contains(Bimini, Unsorted),
{true, _} = h3:contains(DairyIsle, Sorted),
{true, _} = h3:contains(TarponSprings, Sorted),
false = h3:contains(Bimini, Sorted),
```

### Conversion back to GeoJSON
```erl
NewJSON = gh3:from_polyfill(Sorted),
NewJSONb = jsx:encode(NewJSON),
ok = file:write_file("usa.reconstructed.json", NewJSONb),
```

### Google Maps via [`tokml`]

```sh
$ tokml usa.reconstructed.json > usa_hexagons.kml
```

[![usa_h3_res7](https://user-images.githubusercontent.com/2551201/108751085-a42b2580-74f6-11eb-95bf-9fafa5c088f4.png)](https://www.google.com/maps/d/u/0/viewer?hl=en&mid=1y5R6LfUvqWovkH9ln0GOX3Q3UM1gDoEg&ll=56.00475824195842%2C-113.44115859990532&z=3)


[`tokml`]: https://github.com/mapbox/tokml


[GeoJSON]: https://geojson.org
[H3]: https://h3geo.org
[`erlang-h3`]: https://github.com/helium/erlang-h3
