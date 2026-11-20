# Expected routes

Fixture: `fixture_network.dart`. Config: `perStopMinutes = 2.5`, `transferPenaltyMinutes = 7.5`.
Fare: 10 EGP for every route. `null` means `findRoute` returns `null`.

| From → To | Legs (station ids, boarding first) | Stations | Transfers | Minutes |
|---|---|---|---|---|
| s1 → s5 | L1 [s1,s2,x,s4,s5] | 4 | 0 | 10.0 |
| s5 → s1 | L1 [s5,s4,x,s2,s1] | 4 | 0 | 10.0 |
| s1 → t4 | L1 [s1,s2,x]; L2 [x,t4] | 3 | 1 | 15.0 |
| t1 → p2 | L2 [t1,t2,x]; L1 [x,s4]; L3(br_a) [s4,k,p1,p2] | 6 | 2 | 30.0 |
| p2 → q3 | L3(br_a) [p2,p1,k]; L3(br_b) [k,q1,q2,q3] | 5 | 1 | 20.0 |
| m1 → p1 | L3(br_a) [m1,s4,k,p1] | 3 | 0 | 7.5 |
| s1 → s1 | null | | | |
| s1 → zzz | null (unknown station) | | | |
| s1 → iso | null (unreachable) | | | |
