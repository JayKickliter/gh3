GeoJSON H3
==========

This Erlang library provides utility functions for converting
[GeoJSON] polygons to/from [H3] [polyfills]. This library is naive,
not robust, and soley exists generating [Helium]'s location to LoRaWAN
regulatory region lookup tables.

## Examples

### GeoJSON to polyfill

Helper fun:

```erlang
GeoJSON2CompactedPolyfill = fun(PathToGeoJSON, H3Resolution) ->
    {ok, JSONb} = file:read_file(PathToGeoJSON),
    JSON = jsx:decode(JSONb, []),
    Poly = gh3:to_polyfills(JSON, H3Resolution),
    Flattened = lists:flatten(Poly),
    Deduped = lists:usort(Flattened),
    Compacted = h3:compact(Deduped),
    Sorted = lists:sort(fun(A, B) -> h3:get_resolution(A) < h3:get_resolution(B) end, Compacted)
    end.
```

Generating a single polyfill from a [GeoJSON file] (can take an **extremely** long time to complete):

```erlang
US915Indices = GeoJSON2CompactedPolyfill("path/to/US915.geojson", 7).
```

### Membership tests

The functionality in this section is all provided by [`erlang-h3`].

```erl
Almont = h3:from_geo({46.72887827828476, -101.50349384893536}, 12),
BandarSeriBegawan = h3:from_geo({4.905792416533559, 114.93276723019176}, 12),
Bimini = h3:from_geo({25.726864906131482, -79.29676154106401}, 12),
ClearwaterBeach = h3:from_geo({27.97380429905559, -82.83016590438804}, 12),
DairyIsle = h3:from_geo({37.96648742360273, -91.36002165669227}, 12),
SaltLakeCity = h3:from_geo({40.74839328820584, -111.88253094070544}, 12),
TarponSprings = h3:from_geo({28.14209546931603, -82.75665097150251}, 12),
TatshenshiniAlsekProvincialPark = h3:from_geo({59.702362050078506, -137.15257362745595}, 12),

{true, DairyIsleParent} = h3:contains(DairyIsle, US915Indices),
{true, TarponSpringsParent} = h3:contains(TarponSprings, US915Indices),
{true, AlmontParent} = h3:contains(Almont, US915Indices),
{true, BiminiParent} = h3:contains(Bimini, US915Indices),
{true, SaltLakeCityParent} = h3:contains(SaltLakeCity, US915Indices),
{true, TatshenshiniAlsekProvincialParkParent} = h3:contains(TatshenshiniAlsekProvincialPark, US915Indices),
false = h3:contains(BandarSeriBegawan, US915Indices).
```

### Conversion back to GeoJSON

```erl
NewJSON = gh3:from_polyfill(US915Indices),
NewJSONb = jsx:encode(NewJSON),
ok = file:write_file("usa.reconstructed.json", NewJSONb),
```

### Google Maps via [`tokml`]

```sh
$ tokml usa.reconstructed.json > usa_hexagons.kml
```

[![usa_h3_res7](https://user-images.githubusercontent.com/2551201/108751085-a42b2580-74f6-11eb-95bf-9fafa5c088f4.png)](https://www.google.com/maps/d/u/0/viewer?hl=en&mid=1bkba4TajlAE3A8YcA647gJDAw80mtVMN&ll=9.618532832074589%2C-127.25061195&z=2)


[`tokml`]: https://github.com/mapbox/tokml


[GeoJSON]: https://geojson.org
[H3]: https://h3geo.org
[`erlang-h3`]: https://github.com/helium/erlang-h3
[GeoJSON file]: https://github.com/gradoj/hplans
[polyfills]: https://en.wikipedia.org/wiki/Flood_fill
[Helium]: https://github.com/helium


