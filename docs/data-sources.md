# Metro data sources

`assets/metro_seed.json` is the only data the app ships. This file records where
each part of it came from and how sure we are of it, because the official site
does not cover the whole network and some of it is out of date.

Snapshot date in the seed: **2026-11-19**.

## Lines 1 and 2

- **Official:** <https://cairometro.gov.eg/operations/1> and
  <https://cairometro.gov.eg/operations/2>. Used to confirm the station counts
  (35 and 20), the interchanges (الشهداء and أنور السادات between lines 1 and 2,
  العتبة between lines 2 and 3, جمال عبد الناصر between lines 1 and 3) and the
  names the site calls out by name, including جامعة حلوان, عزبة النخل, عين شمس
  and دار السلام.
- **Order and the full list:** the Arabic Wikipedia station list
  ([قائمة محطات مترو القاهرة](https://ar.wikipedia.org/wiki/قائمة_محطات_مترو_القاهرة)),
  read on 2026-11-19, because the official pages describe the lines but do not
  print the stop-by-stop sequence.

## Line 3

The Cairo Metro site has no Line 3 page (it only documents lines 1 and 2), so:

- **Order and branches:** the same Wikipedia station list, which matches the
  opening notices for phases 3 and 4 (the fork after الكيت كات into محور روض
  الفرج and جامعة القاهرة) and the operator's announcements.
- **Status:** least verified part of the seed. The station names are the ones
  used on the map and in the press; a native review against a current printed
  map is still worth doing.

## Fares

- 2026 table: 8 EGP up to 9 stations, 10 up to 16, 15 up to 23, 20 beyond.
  Taken from the fare table published in January 2026.
- `fareEffectiveDate` in `lib/core/constants.dart` is the date shown in the app;
  it is a claim about when the table took effect, not something we could verify.

## Known loose ends

- **المرج vs المرج القديمة:** the official Line 1 page calls the station
  المرج القديمة; the map and the seed call it المرج. The station id is `marg`
  and stays, but the display name may deserve the fuller form.
- **جامعة حلوان:** one Wikipedia table cell now reads جامعة العاصمة while the
  rest of the page and the official site say جامعة حلوان. The seed keeps
  جامعة حلوان.
- **Line 4, the LRT and the monorail** are out of scope (see `AGENTS.md`), and
  the seed has no field for the operating system.
