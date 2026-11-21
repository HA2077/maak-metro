# Data sources

Snapshot: `2026-11-21` · Seed version: `1` · Scope: Lines 1 and 2.

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
5 tunnel), Helwan University opened in 2002, and interchanges with Lines 2 and 3.
Line 2 has 20 open stations from Shubra El Kheima to El Mounib (12 tunnel,
6 surface, 2 elevated), no branches, and interchanges with Line 1 at Al Shohadaa
and Sadat. The same pages confirm official line colours and the four fare
brackets.

### Cairo Governorate official portal

- Metro page, English:
  https://www.cairo.gov.eg/en/governorate-services/transportation-services/metro
- Metro page, Arabic:
  https://www.cairo.gov.eg/ar/governorate-services/transportation-services/metro/

`Last updated: 2026` on both pages. Used for the complete ordered Line 1 and
Line 2 station lists and the Arabic spellings, because the operator site
confirms the counts and termini but does not publish station-by-station lists.

## Decisions

### D-4 — open stations only

All 35 Line 1 and all 20 Line 2 stations are open. No station on either line is
under construction. Line 3 data comes in a later task; Line 4 and the monorail
are outside the app scope, so they are not in the seed. The seed never contains a
"coming soon" station; that would be unrouteable in the current format and would
need a separate status field and seed version.

### D-6 — branches on Lines 1 and 2

Neither line has a branch. Line 1 is one `main` run Helwan → New El Marg; Line 2
is one `main` run Shubra El Kheima → El Mounib. Only Line 3 forks after Kit Kat.
This seed therefore has an empty `line_branches` list and all Line 1 and Line 2
rows use `branch: "main"`.

### Station order

- Line 1: `seq` 1 at Helwan, 35 at New El Marg.
- Line 2: `seq` 1 at El Mounib, 20 at Shubra El Kheima.

Both follow the order of the official Cairo Governorate list. That list presents
Line 2 from El Mounib to Shubra, while the operator describes the line in the
opposite direction. The lines are undirected in the router, so direction only
fixes the seed order.

Line 2 sequence: El Mounib, Sakiat Mekki, Om El Masryeen, Giza, Faisal, Cairo
University, El Bohouth, Dokki, Opera, Sadat, Mohamed Naguib, Ataba, Al Shohadaa,
Massara, Rod El Farag, Saint Teresa, Khalafawy, El Mazallat, Faculty of
Agriculture, Shubra El Kheima.

### Arabic names

Arabic strings follow the Cairo Governorate Arabic list, which is the only
official complete list. The operator's Arabic prose uses slightly different
forms for a few stations; the seed keeps the complete-list spelling.

Line 1:

| Station | Chosen (Governorate) | Operator prose |
|---|---|---|
| Ahmed Orabi | أحمد عرابي | احمد عرابي |
| Gamal Abdel Nasser | جمال عبد الناصر | جمال عبدالناصر |
| Sadat | السادات | انور السادات (ميدان التحرير) |
| Al Shohadaa | الشهداء | الشهداء (ميدان رمسيس) |

Line 2:

| Station | Chosen (Governorate) | Note |
|---|---|---|
| Om El Masryeen | أم المصريين | Governorate lists ضواحي الجيزة (أم المصريين); operator uses Om Elmasryeen |
| Ataba | العتبة | Operator uses Attaba |
| El Mounib | المنيب | Operator hyphenates El-Mounib |
| El Mazallat | المظلات | Operator hyphenates El-Mazallat |
| Shubra El Kheima | شبرا الخيمة | Operator hyphenates Shubra El-Kheima |
| Faculty of Agriculture | كلية الزراعة | Operator uses Kolleyyet El-Zeraa |

For Line 1, parenthetical area names such as "(Tahrir)" and "(Ramses)" are not
part of the station name and are not stored in `name_ar` / `name_en`. For Line 2,
**Om El Masryeen** is stored as the station name; "Giza Suburbs" is the
Governorate primary label.

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

Line 2:

| Station | Chosen (Governorate) | Operator / alternate |
|---|---|---|
| Om El Masryeen | Om El Masryeen | Giza Suburbs (Om El Masryeen); operator: Om Elmasryeen |
| Ataba | Ataba | Operator: Attaba |
| El Mounib | El Mounib | Operator: El-Mounib |
| El Mazallat | El Mazallat | Operator: El-Mazallat |
| Shubra El Kheima | Shubra El Kheima | Operator: Shubra El-Kheima |
| Faculty of Agriculture | Faculty of Agriculture | Operator: Kolleyyet El-Zeraa |

`helwan_university` stays **Helwan University**. Some community sources have
renamed the station to Capital University, but both official sources still use
Helwan University in 2026.

### Interchanges

| Station | Lines | Line 1 seq | Line 2 seq | Decision |
|---|---|---:|---:|---|
| Sadat | 1, 2 | 19 | 10 | One `sadat` station row, reused |
| Al Shohadaa | 1, 2 | 22 | 13 | One `al_shohadaa` station row, reused |
| Ataba | 2, 3 | — | 12 | `ataba`; DATA-3 must reuse this id |
| Cairo University | 2, 3 | — | 6 | `cairo_university`; Governorate labels it a Line 3 interchange, but the operator page names only Ataba, so verify in DATA-3 |
| Giza | 2, 4 | — | 4 | Line 4 is under construction and out of scope |

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
