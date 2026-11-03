# Test Results & Analysis

> Replace the placeholders below with your own measured numbers from `results/<run>/summary.md`
> and the HTML dashboard. Add screenshots to this folder (e.g. `docs/response-times.png`).

## Test environment

| Item | Value |
|------|-------|
| Date | _YYYY-MM-DD_ |
| Target | https://blazedemo.com |
| JMeter version | _5.6.x_ |
| Load generator | _e.g. 8 GB RAM laptop, 50 Mbps connection_ |
| Profile | _load (50 users, 60 s ramp-up, 300 s)_ |

## Summary

| Transaction | Samples | Avg (ms) | P90 | P95 | P99 | Error % | Req/s |
|-------------|--------:|---------:|----:|----:|----:|--------:|------:|
| 01 - Home Page | | | | | | | |
| 02 - Find Flights | | | | | | | |
| 03 - Choose Flight | | | | | | | |
| 04 - Purchase Ticket | | | | | | | |
| TX - Book Flight (end-to-end) | | | | | | | |

## Observations

- _Did response time stay under the 3 s SLA at 50 users? At what user count did it start to degrade?_
- _Which request was slowest, and did it get worse as load increased?_
- _What types of errors occurred (timeouts, assertion failures, HTTP 5xx), and when did they begin?_
- _Did throughput plateau while users kept increasing? That indicates saturation._

## Bottlenecks identified

1. _..._

## Recommendations

1. _..._

## Limitations

- Results depend on network conditions between the load generator and a public demo site.
- Think time and data volume are simplified compared with real production traffic.
