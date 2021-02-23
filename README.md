GeoJSON H3
==========

This is an Erlang library providing helpers for between [GeoJSON] polygons and [H3] polyfills.

## Example usage

Added to this patch is a commit for converting polyfills to and from
GeoJSON. This commit _should_ be removed before merging as it is out
of scope and adds a decency on `jsx`. But it's immensely helpful for
visualizing polyfill behavior:

### GeoJSON to polyfill

```erl
1> {ok, JSONb} = file:read_file("usa.geo.json").
2> JSON = jsx:decode(JSONb, []).
3> {_, Poly} = timer:tc(fun() -> gh3:to_polyfills(JSON, 7) end).
{14853371, <Output Cut>}
4> {_, Flattened} = timer:tc(fun() -> lists:flatten(Poly) end).
{150723, <Output Cut>}
5> {_, Unsorted} = timer:tc(fun() -> h3:compact(Flattened) end).
{281417,  <Output Cut>}
6> {_, Sorted} = timer:tc(fun() -> lists:sort(fun(A, B) -> h3:get_resolution(A) < h3:get_resolution(B) end, Unsorted) end).
{351589, <Output Cut>}
```

### Membership tests

```erl
7> DairyIsle = h3:from_geo({37.96648742360273, -91.36002165669227}, 12).
631177005232211967
8> TarponSprings = h3:from_geo({28.14209546931603, -82.75665097150251}, 12).
631702052826179071
9> Bimini = h3:from_geo({25.726864906131482, -79.29676154106401}, 12).
631711456926748159
10> {_, {true, _}} = timer:tc(fun() -> h3:contains(DairyIsle, Unsorted) end).
{26,{true,581641651093503999}}
11> {_, {true, _}} = timer:tc(fun() -> h3:contains(TarponSprings, Unsorted) end).
{1105,{true,609184054696214527}}
12> {_, false} = timer:tc(fun() -> h3:contains(Bimini, Unsorted) end).
{1415,false}
13> {_, {true, _}} = timer:tc(fun() -> h3:contains(DairyIsle, Sorted) end).
{26,{true,581641651093503999}}
14> {_, {true, _}} = timer:tc(fun() -> h3:contains(TarponSprings, Sorted) end).
{775,{true,609184054696214527}}
15> {_, false} = timer:tc(fun() -> h3:contains(Bimini, Sorted) end).
{1413,false}
```

### Conversion back to GeoJSON
```erl
16> NewJSON = gh3:from_polyfill(Sorted).
<Output Cut>
17> NewJSONb = jsx:encode(NewJSON).
<<"{\"coordinates\":[[[[-139.2018275927827,60.05446522351501]]],[[[-162.75235291579057,54.98223800380008]]],[[[-139.18351"...>>
18> ok = file:write_file("custom.reconstructed.json", NewJSONb).
ok
```

### Google Maps via [`tokml`]

```sh
$ tokml custom.reconstructed.json > usa_hexagons.kml
```

[![usa_h3_res7](https://user-images.githubusercontent.com/2551201/108751085-a42b2580-74f6-11eb-95bf-9fafa5c088f4.png)](https://www.google.com/maps/d/u/0/viewer?hl=en&mid=1y5R6LfUvqWovkH9ln0GOX3Q3UM1gDoEg&ll=56.00475824195842%2C-113.44115859990532&z=3)


[`tokml`]: https://github.com/mapbox/tokml


[GeoJSON]: https://geojson.org
[H3]: https://h3geo.org
[`erlang-h3`]: https://github.com/helium/erlang-h3
