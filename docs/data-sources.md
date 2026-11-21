# Data sources

Snapshot: `2026-11-21` · Seed version: `1` · Scope: Line 1 only.

The seed is built from official sources only. No station name, order or fare
was copied from a blog, wiki or route-planner site.

## Sources used

### Cairo Metro (operator)

- Line 1 operations, English:
  https://cairometro.gov.eg/en/operations/1
- Line 1 operations, Arabic:
  https://cairometro.gov.eg/ar/operations/1
- Line 2 operations, English:
  https://cairometro.gov.eg/en/operations/2
- Official network map:
  https://cairometro.gov.eg/en/Maps
  (image: https://www.cairometro.gov.eg/images/new-map8.jpg)
- Ticket prices:
  https://cairometro.gov.eg/en/bookings/4
  (price image: https://www.cairometro.gov.eg/images/1774946614.JPG)

Used for: Line 1 has 35 open stations from Helwan to New El Marg (30 surface,
5 tunnel), Helwan University opened in 2002, interchanges (Sadat and Al Shohadaa
with Line 2, Nasser with Line 3), Line 2 has no branches, official line colours,
and the four fare brackets.

### Cairo Governorate official portal

- Metro page, English:
  https://www.cairo.gov.eg/en/governorate-services/transportation-services/metro
- Metro page, Arabic:
  https://www.cairo.gov.eg/ar/governorate-services/transportation-services/metro/

`Last updated: 2026` on both pages. Used for the complete ordered Line 1 station
list and the Arabic spellings, because the operator site confirms the count and
termini but does not publish a station-by-station list.

## Decisions

### D-4 — open stations only

All 35 Line 1 stations are open. No Line 1 station is under construction. Line 4
is under construction and is outside the app scope, so it is not in the seed.
The seed never contains a "coming soon" station; that would be unrouteable in
the current format and would need a separate status field and seed version.

### D-6 — branches on Lines 1 and 2

Neither line has a branch. Line 1 is one `main` run Helwan → New El Marg; Line 2
is one `main` run Shubra El Kheima → El Mounib. Only Line 3 forks after Kit Kat.
This seed therefore has an empty `line_branches` list and all Line 1 rows use
`branch: "main"`.

### Station order

`seq` starts at 1 at Helwan and ends at 35 at New El Marg, following the order of
the official Cairo Governorate list. The line is undirected in the router, so
this choice only fixes the seed order.

### Arabic names

Arabic strings follow the Cairo Governorate Arabic list, which is the only
official complete list. The operator's Arabic prose uses slightly different
forms for a few stations; the seed keeps the complete-list spelling:

| Station | Chosen (Governorate) | Operator prose |
|---|---|---|
| Ahmed Orabi | أحمد عرابي | احمد عرابي |
| Gamal Abdel Nasser | جمال عبد الناصر | جمال عبدالناصر |
| Sadat | السادات | انور السادات (ميدان التحرير) |
| Al Shohadaa | الشهداء | الشهداء (ميدان رمسيس) |

Parenthetical area names such as "(Tahrir)" and "(Ramses)" are not part of the
station name and are not stored in `name_ar` / `name_en`.

### English names

English display names follow the same complete Governorate list. The operator map
uses different transliterations for several stations. The stations and their
order are identical; only the spelling differs. The seed keeps one spelling
consistently.

| Station | Chosen (Governorate) | Operator map |
|---|---|---|
| Maadi Barracks | Maadi Barracks | Sakanat El-Maadi |
| Kotsika | Kotsika | Kozzika |
| Tora El Asmant | Tora El Asmant | Tura El-Esmant |
| El Maasara | El Maasara | El-Maasara |
| Sayeda Zeinab | Sayeda Zeinab | Al-Sayeda Zeinab |
| El Malek El Saleh | El Malek El Saleh | El-Malek El-Saleh |
| Gamal Abdel Nasser | Gamal Abdel Nasser | Nasser |
| Ahmed Orabi | Ahmed Orabi | Orabi |
| El Matareya | El Matareya | El-Matareyya |
| Hadayek El Zeitoun | Hadayek El Zeitoun | Hadayeq El-Zaitoun |
| Helmiet El Zeitoun | Helmiet El Zeitoun | Helmeyet El-Zaitoun |
| Manshiet El Sadr | Manshiet El Sadr | Manshiet El-Sadr |
| Ezbet El Nakhl | Ezbet El Nakhl | Ezbet El-Nakhl |
| El Marg / New El Marg | El Marg / New El Marg | El-Marg / New Marg |

`helwan_university` stays **Helwan University**. Some community sources have
renamed the station to Capital University, but both official sources still use
Helwan University in 2026.

### Line colours

The official map marks Line 1 blue, Line 2 red and Line 3 green. The operator
does not publish hex codes, so the seed uses the values already fixed in
`docs/PLAN.md` and the test fixtures:

- Line 1 `#1E63B8`
- Line 2 `#D01F2F`
- Line 3 `#3A9E4D`

### Fares

Values are copied from the operator's ticket-price image and match the project
plan:

| Max stations | Price (EGP) |
|---:|---:|
| 9 | 10 |
| 16 | 12 |
| 23 | 15 |
| 39 | 20 |

The fare count includes the boarding station; that rule is in
`docs/PLAN.md` and is applied by `FareCalculator`, not by this file.
