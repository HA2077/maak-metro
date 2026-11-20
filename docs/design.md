# Maak Metro — screen design

A reference for the UI as it is actually built, so the same language can be
repeated on a new screen without redesigning it. Every value below comes from
code in this repository: `lib/core/theme/app_theme.dart` for tokens,
`lib/screens/` for layout, `lib/widgets/` for the shared parts. When this file
and the code disagree, the code wins — then fix this file.

Screenshots are not committed. To check a change, run the app at 360dp width in
Arabic and in English, dark and light, and look at the states listed per screen
below (empty, loading, error).

---

## 1. The idea in one paragraph

Maak is a timetable you can read at a glance on a crowded platform. The chrome
is one calm hue (transit blue) on a near-neutral surface. The only saturated
colour that belongs to content is a metro line's own colour, and that comes from
the database, never from Dart. Figures are Arabic-Indic in Arabic and Latin in
English, always tabular so they do not shuffle while they animate. Arabic is the
default language, so every layout is built right-to-left first and mirrored with
directional widgets, never with `left`/`right`.

---

## 2. Foundations

### 2.1 Colour

`ColorScheme.fromSeed(seedColor: 0xFF2563EB)` with explicit overrides. Both
schemes are hand-finished; do not rely on tonal generation for surfaces.

| Role | Light | Dark | Used for |
|---|---|---|---|
| `primary` | `#1D4ED8` | `#9DC0FF` | the one action per screen, links, selected tab icon |
| `onPrimary` | `#FFFFFF` | `#06255C` | text on a filled button |
| `primaryContainer` | `#DCE7FF` | `#1E3A8A` | tab indicator, selected segment |
| `onPrimaryContainer` | `#0B2559` | `#DCE7FF` | selected segment label |
| `secondary` | `#0E7490` | `#5FD3E8` | reserved, unused in chrome |
| `tertiary` | `#9A5B00` | `#F3BE7A` | reserved, unused in chrome |
| scaffold / canvas | `#F6F8FC` (`surfaceContainerLow`) | `#0F1826` (`surface`) | page background, app bar, nav bar |
| card | `#FFFFFF` (`surface`) | `#121C2C` (`surfaceContainerLow`) | cards, sheets, dialogs, chips |
| `onSurface` | `#0F172A` | `#E6EDF7` | primary text |
| `onSurfaceVariant` | `#475569` | `#A6B6CC` | secondary text, icons, hints |
| `outline` | `#94A3B8` | `#52658A` | control borders, drag handle |
| `outlineVariant` | `#DDE5F0` | `#22304A` | card hairline, dividers |
| `surfaceContainerHigh` | `#E9EFF7` | `#1B2A3F` | input fill |
| `surfaceContainerHighest` | `#E2E9F3` | `#22334B` | disabled button fill |
| `error` | `#B3261E` | `#FFB4AB` | error text, destructive action |
| `errorContainer` | `#F9DEDC` | `#93000A` | swipe-to-delete background |

Inverted contrast between canvas and card is deliberate: in light the page is
grey and cards are white; in dark the page is the darkest and cards lift one
step. No elevation, no surface tint, no shadows anywhere. Separation is a 1dp
`outlineVariant` border.

Line colours are content: `parseHexColor(line.colorHex)` reads `#RRGGBB` from the
database, falls back to `#6B7280` on anything unreadable, and `lineTextColor()`
picks black or white by relative luminance so a chip never loses contrast.

### 2.2 Type

Noto Sans Arabic, bundled (`assets/fonts/`, 400/500/600/700), `fontFamily` on the
whole `ThemeData`. Letterspacing is always `0`: Arabic joins letters and any
tracking breaks the joins. Line heights are generous because Arabic ascenders
and descenders sit taller than Latin at the same size.

| Style | Size / line height | Weight | Where |
|---|---|---|---|
| `displaySmall` | 36 / 48 | 700 | unused today, reserved for a big number |
| `headlineMedium` | 30 / 40 | 700 | unused today |
| `headlineSmall` | 26 / 34 | 700 | estimated time, sheet title, app name |
| `titleLarge` | 21 / 30 | 700 | app bar title, planner greeting |
| `titleMedium` | 17 / 26 | 600 | card titles, station names in tiles, stat values |
| `titleSmall` | 15 / 23 | 600 | section labels ("محطات التبديل") |
| `bodyLarge` | 17 / 28 | 400 | body copy, hints, empty states |
| `bodyMedium` | 15 / 25 | 400 | secondary rows, transfer line |
| `bodySmall` | 13 / 21 | 400 | subtitles, metadata |
| `labelLarge` | 15 / 22 | 600 | button text, segmented labels, chip labels |
| `labelMedium` | 13 / 19 | 600 | line chip, from/to labels |
| `labelSmall` | 12 / 17 | 600 | nav bar labels |

Numbers that animate or sit in a column get `AppTheme.numeric()`, which applies
`FontFeature.tabularFigures()`.

### 2.3 Space, radius, layout

Spacing scale (`AppSpace`): 4 · 8 · 12 · 16 · 24 · 32. There is no other value in
the app; a 6 or a 14 is a bug.

Radii (`AppRadius`): field 16 (inputs, buttons), card 20 (cards, snack bar),
sheet 28 (bottom sheets, dialogs).

Layout (`AppLayout`): content is capped at 720dp and centred on anything wider;
the bottom bar becomes a rail at 720dp and an extended rail at 1080dp.

Screen padding is 18dp on the sides for lists and cards, 24dp on the sides for
settings and empty states. Sheets use 16dp.

### 2.4 Icons

Material Icons only, 24dp default. 30dp for the library delete action, 20dp for
summary stats, 18dp for inline transfer rows, 14dp for the small route markers.
Icons are `onSurfaceVariant` unless they carry meaning: `primary` for the
selected/action state, the line colour for line furniture, `error` for
destructive.

---

## 3. Direction, language, figures

- **RTL first.** Every inset is `EdgeInsetsDirectional`, every alignment
  `AlignmentDirectional`, every start/end is logical. Nothing sets `left` or
  `right`. The tab order, the card internals and the sheet buttons mirror on
  their own.
- **Two languages, one ARB pair.** No user-facing string in Dart. `app_ar.arb` is
  the template; `app_en.arb` mirrors it key for key. Arabic plurals need `=0`,
  `=1`, `=2`, `few`, `many`, `other`.
- **Names come in pairs.** The active language is primary; the other language is
  the subtitle (`otherStationName`). Egyptian readers recognise a station by its
  Latin sign as well as its Arabic one, so the pair is never dropped, in either
  direction.
- **Arabic-Indic figures in Arabic, Latin in English.** `localizedDigits(context,
  text)` maps `0-9` to `٠-٩` and `.` to the Arabic decimal separator `٫`. Never
  format a number and print it raw.
- **Dates read day, month, year in the reader's direction.** `DateText` renders
  three separate `Text` runs in a `Row` for the figures style, because
  Arabic-Indic numbers form one right-to-left run and bidi would flip the fields
  inside a single string. No zero padding: `٢٧-٣-٢٠٢٦`, because the Arabic zero
  is a dot and `٠٣` reads as noise.
- **Copy voice.** Egyptian Arabic, second person, short and warm, never
  instructional-corporate: "خطّط مشوارك", "لسه صاحي؟ اختار محطتك بسرعة",
  "يلا نبدأ". English mirrors the same warmth ("Quiet night — where are you off
  to?"). No exclamation marks, no emoji.
- **Greetings rotate.** Four parts of the day (morning 05–11, afternoon 12–16,
  evening 17–21, night 22–04) × four wordings each; one is picked per launch, so
  the planner is not the same sentence every time it opens.
- **Every figure is labelled as an estimate.** The result says "الوقت التقديري",
  never a bare "time".

---

## 4. Motion

One place for durations and curves (`AppMotion`). Entrances decelerate, exits
accelerate, nothing loops except a loader.

| Token | Value | Used for |
|---|---|---|
| `fast` | 120ms | haptic-adjacent micro feedback |
| `base` | 200ms | tab cross-dissolve, button label swap, error line |
| `slow` | 280ms | theme change, count-up default |
| `page` | 320ms | page push |
| `counter` | 800ms | the estimated-minutes count-up |
| `stagger` | 40ms per item, capped at index 5 | list entrances |
| curves | `decelerate` (0.05,0.7,0.1,1) · `accelerate` (0.3,0,0.8,0.15) · `standard` (0.2,0,0,1) | |

Four primitives, and nothing else:

1. **Tab cross-dissolve** (`FadeIndexedStack`) — the leaving and arriving tabs'
   opacities sum to one, so there is never a frame with no content and never the
   old tab sitting still underneath. Children stay alive, so scroll positions
   survive.
2. **List stagger** (`FadeSlideIn`) — fade plus 8dp upward travel, delayed by
   `stagger × index`. A tab change reads as one movement instead of a hard cut.
3. **Page push** (`AppPageTransitionsBuilder`) — fade with 2% upward travel,
   320ms. Cheaper to read than a full-width slide.
4. **Count-up** (`CountUp`) — a number runs from zero to its value over 800ms
   behind a static `Semantics` label, so a screen reader hears the final number
   once instead of every frame.

Reduced motion: `AppMotion.reduced(context)` reads
`MediaQuery.maybeDisableAnimationsOf` and collapses every duration to zero. New
motion must go through `AppMotion.of(context, …)` so it is honoured.

Haptics (`AppHaptics`): `tap()` on selection (tab, row, language), `action()` on
a change with consequence (swap, delete, favourite), `confirm()` when a result
arrives. Fire and forget; never awaited.

---

## 5. Components

Every one of these is a theme default or a widget in `lib/widgets/`. Use them;
do not re-style a control locally.

| Component | Specification |
|---|---|
| **Card** | radius 20, `outlineVariant` 1dp border, no elevation, no margin, colour = card role. Content padding 18 all round. |
| **Filled button** | height 52 min, radius 16, `primary`; disabled = `surfaceContainerHighest` fill + `onSurfaceVariant` label. One per screen. |
| **Outlined button** | height 52 min, radius 16, `outline` border, transparent fill. Sits beside a filled one when a screen has two equal choices. |
| **Text button** | dialogs only; destructive one uses `foregroundColor: error`. |
| **Segmented button** | height 48, selected = `primaryContainer` + `onPrimaryContainer`, unselected transparent, 1dp `outline` border, no selection tick. Two or three options, never four. |
| **Chip / ActionChip** | stadium, card fill, `outlineVariant` border, label `labelLarge`, padding 16/11. |
| **Line chip** | stadium on the line's own colour, `labelMedium` 600, text colour by luminance, hairline border at 35% `outline`. |
| **Input** | filled `surfaceContainerHigh`, radius 16, transparent border that becomes `primary` 1.6dp on focus, content padding 18/16, hint `bodyLarge` in `onSurfaceVariant`. |
| **List tile** | 18dp horizontal padding, 16dp min vertical, icon in `onSurfaceVariant`. |
| **Divider** | 1dp `outlineVariant`, zero space. |
| **Bottom sheet** | card colour, drag handle in `outline`, top radius 28, max width 720, `useSafeArea`, content padded 16 and above the keyboard inset. |
| **Dialog** | radius 28, card colour, title padding 24/24/24/8, actions 12/0/12/10. |
| **App bar** | canvas colour, no elevation, no scrolled-under tint, title `titleLarge` 700, title on the start side (`centerTitle: false`). |
| **Bottom bar** | height 76, canvas colour, indicator `primaryContainer`, labels always shown, selected label 700. |
| **Rail** | same colours; extended from 1080dp with labels beside the icons. |
| **Snack bar** | floating, `inverseSurface`, body text in `onInverseSurface`, radius 16. |
| **Empty state** | 40dp icon in `onSurfaceVariant`, `bodyLarge` line, optional `FilledButton.tonal` action. |
| **Summary stat** | 20dp icon, 6dp gap, value in `titleMedium` 700 tabular. |

---

## 6. Screens

### 6.1 First run (`onboarding_screen.dart`)

Shown once, gated by `SettingsProvider.onboarded`. Everything the rest of the app
depends on — language and appearance — is chosen before the tabs appear.

Order, centred, max 420dp wide, scrollable, 24dp padding: logo 120dp → title
`headlineSmall` → body `bodyLarge` in `onSurfaceVariant` → language segmented
(العربية | English) → appearance segmented (حسب النظام | فاتح | غامق) → filled
"يلا نبدأ" which sets `onboarded` and hands over to the shell.

Both choices apply immediately, so the screen itself flips to English / light as
you tap. No "skip", no second page.

### 6.2 Shell (`home_shell.dart`)

Four tabs: Planner 0, Lines 1, Library 2, Settings 3 — `alt_route`,
`subway(_outlined)`, `bookmark(_border)`, `settings(_outlined)`.

Phone: `NavigationBar` 76dp. ≥720dp: `NavigationRail` with labels. ≥1080dp:
extended rail. Content is `FadeIndexedStack` inside a 720dp centred column, so
tab state and scroll offset survive a switch. A failed seed load replaces the
tabs with an icon, one line of copy and a retry button — never a blank screen.

Tapping the tab you are already on does nothing today (scroll-to-top is still
open).

### 6.3 Planner (`planner_screen.dart`)

The default screen, and the only one with a greeting.

From the top, in a list padded 18 / 8 / 18 / 24:

1. Greeting — `titleLarge` 700, one of the sixteen wordings for the hour.
2. Hint — `bodyLarge` `onSurfaceVariant`, 20dp below.
3. **Trip card** — a card holding two station rows and a swap button. On the
   leading edge, a 10dp hollow dot, a 2dp `outlineVariant` connector 30dp long,
   and a 10dp filled dot, both dots in `primary`. Each row is a full-width tap
   target with 16dp vertical padding: a `labelSmall` "من"/"إلى" over the station
   name in `titleMedium` (or "اختر محطة" in `onSurfaceVariant`), and an
   `expand_more` 20dp chevron on the trailing edge. A changed value cross-fades in
   over 200ms. The swap button is a tonal circular icon button
   (`primaryContainer`) with `swap_vert`, vertically centred; it turns 180° per
   swap. The whole card is one surface, not two fields.
4. Primary button "أعرض المسار" — disabled until both stations are set. While
   calculating, the label cross-fades to a 20dp spinner without the button
   changing size.
5. Error line — `bodyMedium` in `error` with a 18dp `error_outline`, inside an
   `AnimatedSize` so the list does not jump when it appears. Two cases: same
   station, no route.
6. **Quick picks** — `titleSmall` "محطات التبديل" then a `Wrap` of up to four
   `ActionChip`s: the last three history entries if there are any, otherwise
   interchange stations from the data (a station served by more than one line,
   alphabetical). Tapping fills from, then to, then from again.

The card is the only place in the app that draws the two-station motif; the
library tiles repeat it in a flatter form.

### 6.4 Station picker (`widgets/station_picker.dart`)

A 90%-height modal sheet, max 720 wide, returning the chosen `Station` or null.

Drag handle → title in `titleLarge` ("من" / "إلى") with a close button → search
field, autofocused, `search` prefix, a clear button once there is text → list.
Each row: active-language name in the default `ListTile` title, the other
language as `bodySmall` subtitle. No results: `search_off` 32dp and one line.

Search is language-aware and forgiving: both names are normalised (case,
diacritics, tatweel, alef/ya/ta-marbuta forms, extra spaces) and ranked exact →
prefix → contains → one edit away, with short queries excluded from the typo
pass. Search text is never translated.

The keyboard inset is added to the sheet's bottom padding, so the field never
sits under the keyboard.

### 6.5 Route result (`route_result_screen.dart`)

Pushed, not a tab. App bar "المسار" with a star action that toggles the current
route as a favourite (`star_border` → filled `star` in `primary`).

1. **Summary card** (18dp padding): the estimated time as a `headlineSmall`
   count-up, tabular, 800ms; then a row of three equal `SummaryStat`s — stations,
   transfers, fare in EGP. Figures are Arabic-Indic in Arabic and the label is
   always "تقديري" / "estimated".
2. **Legs**, one card each, in travel order: a 6dp strip on the leading edge in
   the line colour, the `LineChip`, "من X إلى Y" in `titleMedium`, and an
   `ExpansionTile` reading "N محطات بينية" through an ICU plural (zero, one,
   two, few, many, other) which expands to the intermediate stops as dots
   threaded on a 2dp `outlineVariant` line. Legs animate in with `index * 2`.
3. **Transfer rows** between legs: `alt_route` 18dp in `primary`, the next
   `LineChip`, "غيّر الخط في X" in `bodyMedium`. This is the only place a line chip
   appears outside a card header.

The leg card uses a `Stack` with a positioned strip rather than a stretched
`Row`, because a stretched row needs `IntrinsicHeight`, which cannot measure an
`ExpansionTile` and overflowed at 360dp with large text.

### 6.6 Lines and stations (`lines_screen.dart`)

App bar "الخطوط والمحطات". A list of one card per line, 18dp padding, 12dp
between cards. Each card is an `ExpansionTile` whose leading widget is a 12dp dot
in the line colour, whose title is the line name in `titleMedium`, and whose
subtitle is "N محطة" in `bodySmall` `onSurfaceVariant`.

Expanded, it lists stations in order as `ListTile`s with a 10dp hollow dot
(2dp border in the line colour) and the station name. Line 3 forks after Kit
Kat, so each branch prints under its own label rather than pretending the
network is one straight run. Tapping a station opens the station sheet.

### 6.7 Station sheet (`lines_screen.dart`, `_showStation`)

A content-sized modal sheet: the station name in `headlineSmall` with the other
language under it, a close button, "الخطوط التي تخدمها" in `labelLarge`
`onSurfaceVariant`, the `LineChip`s for every line that serves it, then two equal
buttons — outlined "ابدأ من هنا" and filled "اذهب إلى هنا" — which set from/to and
drop the user on the planner.

### 6.8 Library (`library_screen.dart`)

App bar "المحفوظات" with a 30dp `delete_sweep` action, enabled only when the
history is not empty, guarded by a confirmation dialog whose destructive action
is `error`-coloured. Below it, a two-tab `TabBar`: المفضلة / السجل.

Each entry is a card with two rows — `trip_origin` + from-station,
`place` + to-station, both `titleMedium` with ellipsis — and, on favourites, a
`delete_outline` button. Favourites also swipe horizontally to delete, over an
`errorContainer` background with a delete icon. Empty tab: 40dp icon, one line,
a tonal "ابدأ رحلة" that switches to the planner tab.

Opening an entry recalculates without writing history and pushes the result.

### 6.9 Settings (`settings_screen.dart`)

App bar "الإعدادات", list padded 24. Sections are a `titleSmall`/`labelLarge`
muted heading followed by a full-width control, 24dp apart:

1. **اللغة** — segmented العربية | English.
2. **المظهر** — segmented حسب النظام | فاتح | غامق.
3. **تنسيق التاريخ** — segmented رقمي | مكتوب, which flips every `DateText` in
   the app between `٢٧-٣-٢٠٢٦` and `٢٧ مارس ٢٠٢٦`.
4. **عن التطبيق** — a card: logo 104dp, app name `headlineSmall` 700, version in
   `bodySmall` `onSurfaceVariant` with Arabic-Indic figures, then dividers and
   `ListTile`s carrying the data snapshot date and the fare effective date. These
   two dates are how a reader judges whether the offline data can be trusted, so
   they are always visible, never behind an "about" dialog.

---

## 7. Repeating this on a new screen

1. Start from `Scaffold` + `AppBar(title: Text(l10n.…))`; do not restyle the bar.
2. Pick the padding: 18 for content lists, 24 for settings-like pages, 16 inside
   sheets. Use `EdgeInsetsDirectional`.
3. Compose with `Card` + 18dp padding for anything that is a unit of content.
   One primary action per screen, at most one secondary beside it.
4. Numbers: `localizedDigits` + `AppTheme.numeric()`; dates: `DateText`.
5. Any entrance animation: `FadeSlideIn(index: …)` in lists,
   `AppMotion.of(context, …)` for durations.
6. New strings in both ARB files; run `flutter gen-l10n`.
7. Check it in Arabic (RTL), English (LTR), dark, light, 360dp wide and with
   large text before calling it done.

## 8. Known open design work

- Station list under **Lines** draws hollow dots with no connector, while the
  route result threads its stops on a line. The two should match.
- Branch labels under a line print the seed's branch id in Latin ("Cairo Uni",
  "Rod El Farag Axis") even in the Arabic UI. They need Arabic names.
- Re-tapping the current tab should scroll that tab to the top.
- A licence page (Noto Sans Arabic, SIL OFL) is required before release.
- "Reload data" is not in settings yet.
- The schematic network map is built but held out of the UI until the team
  approves it (branch `feature/map-draft`).
- Tablet: the shell already switches to a rail at 720dp, but no screen is tuned
  for a two-pane layout yet.
