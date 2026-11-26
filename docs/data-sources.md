# Data sources

Snapshot: `2026-11-21` · Seed version: `3` · Scope: Lines 1, 2 and 3.

Station order and fares come from official sources only. No order or fare was
copied from a blog, wiki or route-planner site. One English display name,
**Rod El Farag Corridor**, follows the common label for the official Arabic
**محور روض الفرج**; official English sources say **Rod El Farag Axis**.

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
brackets. The operator site has no Line 3 operations page; the official network
map is used for the Line 3 branch shape and interchanges.

### Cairo Governorate official portal

- Metro page, English:
  https://www.cairo.gov.eg/en/governorate-services/transportation-services/metro
- Metro page, Arabic:
  https://www.cairo.gov.eg/ar/governorate-services/transportation-services/metro/

`Last updated: 2026` on both pages. Used for the complete ordered Line 1 and
Line 2 station lists, the Line 3 phase breakdown, and the Arabic spellings,
because the operator site confirms the counts and termini but does not publish
station-by-station lists.

### National Authority for Tunnels (NAT)

- Line 3 project page:
  http://www.nat.gov.eg/LocationActivity.aspx?id=85

Used for: Line 3 has 34 open stations and 41.2 km, the branch structure at Kit
Kat, and the Tawfikia branch assignment. If the page is unavailable, the Cairo
Governorate phase lists and the official network map cover the same stations.

## Decisions

### D-3 — Line 3 branches and Tawfikia

The branch names are frozen as `rod_el_farag` and `cairo_uni`. Tawfikia is on
`cairo_uni` at `seq` 1.

- `main`: Adly Mansour `seq` 1 → Kit Kat `seq` 23. Kit Kat is only on `main`.
- `rod_el_farag`: Sudan 1, Imbaba 2, El Bohy 3, El Qawmeya El Arabia 4, Ring
  Road 5, Rod El Farag Corridor 6.
- `cairo_uni`: Tawfikia 1, Wadi El Nile 2, League of Arab States 3, Bolak El
  Dakrour 4, Cairo University 5.

`rod_el_farag_corridor` is a different station from the Line 2 `rod_el_farag`
station. They are not an interchange and are not merged.

### D-4 — open stations only

All 35 Line 1, 20 Line 2 and 34 Line 3 stations are open. The Line 3 branches
opened in 2024. No station on Lines 1–3 is under construction. Line 4 and the
monorail are outside the app scope, so they are not in the seed. The seed never
contains a "coming soon" station; that would be unrouteable in the current format
and would need a separate status field and seed version.

### D-6 — branches

Lines 1 and 2 have no branches; all their rows use `branch: "main"`. Line 3
forks after Kit Kat into `rod_el_farag` and `cairo_uni`, and both
`line_branches` rows use `starts_after: "kit_kat"`.

### Station order

- Line 1: `seq` 1 at Helwan, 35 at New El Marg.
- Line 2: `seq` 1 at El Mounib, 20 at Shubra El Kheima.
- Line 3 `main`: `seq` 1 at Adly Mansour, 23 at Kit Kat.
- Line 3 `rod_el_farag`: `seq` 1 at Sudan, 6 at Rod El Farag Corridor.
- Line 3 `cairo_uni`: `seq` 1 at Tawfikia, 5 at Cairo University.

Line 1 and Line 2 follow the order of the official Cairo Governorate list. That
list presents Line 2 from El Mounib to Shubra, while the operator describes the
line in the opposite direction. The lines are undirected in the router, so
direction only fixes the seed order.

Line 2 sequence: El Mounib, Sakiat Mekki, Om El Masryeen, Giza, Faisal, Cairo
University, El Bohouth, Dokki, Opera, Sadat, Mohamed Naguib, Ataba, Al Shohadaa,
Massara, Rod El Farag, Saint Teresa, Khalafawy, El Mazallat, Faculty of
Agriculture, Shubra El Kheima.

Line 3 main sequence: Adly Mansour, El Haykestep, Omar Ibn El Khattab, Qobaa,
Hesham Barakat, El Nozha, El Shams Club, Alf Maskan, Heliopolis, Haroun, El
Ahram, Girls' College, Stadium, Ard El Maared, Abbassia, Abdo Pasha, El Geish,
Bab El Shaaria, Ataba, Nasser, Maspero, Safaa Hegazy, Kit Kat.

### Termini and directions

`lines.terminus_a_ar/en` and `lines.terminus_b_ar/en` come from the official
line descriptions: Line 1 Helwan ↔ New El-Marg, Line 2 El-Mounib ↔ Shubra
El-Kheima, and Line 3 Adly Mansour ↔ Rod El-Farag Corridor / Cairo University.
`line_branches` carries the two Line 3 branch termini from the same source. The
UI shows these as bidirectional headers and derives the boardable direction per
leg; no direction string is hardcoded in Dart.

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

Line 3:

| Station | Chosen | Note |
|---|---|---|
| Rod El Farag Corridor | محور روض الفرج | Governorate and NAT English: Rod El Farag Axis |
| El Haykestep | الهايكستب | Also written El Haykstep |
| Qobaa | قباء | Also written Qubaa |
| El Shams Club | نادي الشمس | Also written Nadi El-Shams |
| Girls' College | كلية البنات | Also written Koleyet El Banat |
| Ard El Maared | أرض المعارض | Also written Fair Zone |
| El Qawmeya El Arabia | القومية العربية | Also written El Qawmia |
| League of Arab States | جامعة الدول العربية | Also written Gamat El Dowal |
| Bolak El Dakrour | بولاق الدكرور | Also written Boulak El-Dakrour |

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

Line 3:

| Station | Chosen | Alternate |
|---|---|---|
| Rod El Farag Corridor | Rod El Farag Corridor | Governorate/NAT: Rod El Farag Axis |
| El Haykestep | El Haykestep | El Haykstep |
| Qobaa | Qobaa | Qubaa |
| El Shams Club | El Shams Club | Nadi El-Shams |
| Heliopolis | Heliopolis | Heliopolis Square |
| Girls' College | Girls' College | Koleyet El-Banat |
| Ard El Maared | Ard El Maared | Fair Zone |
| Abdo Pasha | Abdo Pasha | Abdou Pasha |
| El Qawmeya El Arabia | El Qawmeya El Arabia | El-Qawmia |
| League of Arab States | League of Arab States | Gamat El Dowal |
| Bolak El Dakrour | Bolak El Dakrour | Boulak El-Dakrour |
| Tawfikia | Tawfikia | Tawfikiya |

`helwan_university` stays **Helwan University**. Some community sources have
renamed the station to Capital University, but both official sources still use
Helwan University in 2026.

### Interchanges

| Station | Lines | Seq | Decision |
|---|---|---|---|
| Sadat | 1, 2 | L1 19; L2 10 | One `sadat` station row, reused |
| Al Shohadaa | 1, 2 | L1 22; L2 13 | One `al_shohadaa` station row, reused |
| Nasser | 1, 3 | L1 20; L3 main 20 | One `nasser` station row, reused |
| Ataba | 2, 3 | L2 12; L3 main 19 | One `ataba` station row, reused |
| Cairo University | 2, 3 | L2 6; L3 cairo_uni 5 | One `cairo_university` station row, reused |
| Giza | 2, 4 | L2 4 | Line 4 is under construction and out of scope |

Line 2 `rod_el_farag` and Line 3 `rod_el_farag_corridor` are different stations,
not an interchange. The LRT at Adly Mansour, the East Nile Monorail at Stadium
and the West Nile Monorail at Wadi El Nile are out of scope.

### Line colours

The official network map (https://www.cairometro.gov.eg/images/new-map8.jpg, read
on 2026-11-24) draws Line 1 blue, Line 2 red and Line 3 green, so the seed keeps
those. Community maps and the English Wikipedia article agree with the blue Line
1; the OpenStreetMap wiki lists Line 1 red and Line 2 orange, which does not
match the operator. The operator does not publish hex codes, so the seed uses the
values already fixed in `docs/PLAN.md` and the test fixtures:

- Line 1 `#1E63B8`
- Line 2 `#D01F2F`
- Line 3 `#3A9E4D`

### Fares

Values are copied from the operator's ticket-price image and match the project
plan:

| Max stations | Price (EGP) | Ticket color |
|---:|---:|---|
| 9 | 10 | yellow |
| 16 | 12 | green |
| 23 | 15 | pink |
| 39 | 20 | lightBrown |

The colors describe the physical ticket tiers commuters buy at the window; they
are seeded in `fares.ticket_color` and never hardcoded in Dart. The fare count
includes the boarding station; that rule is in `docs/PLAN.md` and is applied by
`FareCalculator`, not by this file.

## Verification (2026-11-24)

Re-checked against the operator's network map and the counts on its Line 1 and
Line 2 pages:

- 84 stations and 89 `line_stations` rows: 35 on Line 1, 20 on Line 2 and 34 on
  Line 3 (23 `main`, 6 `rod_el_farag`, 5 `cairo_uni`).
- Termini and order match the map: Helwan → New El Marg, El Mounib → Shubra El
  Kheima, Adly Mansour → Kit Kat, with both branches leaving after Kit Kat.
- The five interchanges reuse one station id each (Sadat, Al Shohadaa, Nasser,
  Ataba, Cairo University); no station id appears twice inside a single line.
- Line colours match the operator's map (see above).
- Fares: four brackets at 9, 16, 23 and 39 stations for 10, 12, 15 and 20 EGP.
- `test/data/seed_validation_test.dart` covers the format and
  `sqlite_network_repository_test.dart` covers the load; the counts above were
  re-counted from the file itself.

