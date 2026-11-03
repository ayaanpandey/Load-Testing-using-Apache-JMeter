#!/usr/bin/env python3
"""Summarise a JMeter CSV results file (.jtl) into a per-request table.

Reports: samples, average, min, max, p90/p95/p99 response time (ms),
error rate (%) and throughput (requests/sec).

Usage:
    python summarize_results.py results.jtl [--markdown summary.md]
"""
import argparse
import csv
import math
from collections import defaultdict


def percentile(sorted_vals, pct):
    if not sorted_vals:
        return 0
    k = max(0, min(len(sorted_vals) - 1, math.ceil(pct / 100 * len(sorted_vals)) - 1))
    return sorted_vals[k]


def summarise(path):
    groups = defaultdict(list)
    errors = defaultdict(int)
    t_min, t_max = None, None

    with open(path, newline="", encoding="utf-8") as f:
        for row in csv.DictReader(f):
            label = row["label"]
            elapsed = int(row["elapsed"])
            ts = int(row["timeStamp"])
            groups[label].append(elapsed)
            if row["success"].strip().lower() != "true":
                errors[label] += 1
            t_min = ts if t_min is None else min(t_min, ts)
            t_max = ts + elapsed if t_max is None else max(t_max, ts + elapsed)

    duration_s = max((t_max - t_min) / 1000, 0.001) if t_min is not None else 0.001
    rows = []
    for label, vals in groups.items():
        vals.sort()
        n = len(vals)
        rows.append({
            "label": label,
            "samples": n,
            "avg": round(sum(vals) / n),
            "min": vals[0],
            "max": vals[-1],
            "p90": percentile(vals, 90),
            "p95": percentile(vals, 95),
            "p99": percentile(vals, 99),
            "error_pct": round(100 * errors[label] / n, 2),
            "tps": round(n / duration_s, 2),
        })
    rows.sort(key=lambda r: r["label"])
    return rows, duration_s


def render(rows, duration_s):
    header = ["Label", "Samples", "Avg (ms)", "Min", "Max", "P90", "P95", "P99", "Error %", "Req/s"]
    lines = [f"Test window: {duration_s:.1f}s", "",
             "| " + " | ".join(header) + " |",
             "|" + "|".join(["---"] * len(header)) + "|"]
    for r in rows:
        lines.append(f"| {r['label']} | {r['samples']} | {r['avg']} | {r['min']} | {r['max']} | "
                     f"{r['p90']} | {r['p95']} | {r['p99']} | {r['error_pct']} | {r['tps']} |")
    return "\n".join(lines)


if __name__ == "__main__":
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("jtl", help="path to results.jtl (CSV)")
    ap.add_argument("--markdown", help="also write the table to this file")
    args = ap.parse_args()

    rows, dur = summarise(args.jtl)
    out = render(rows, dur)
    print(out)
    if args.markdown:
        with open(args.markdown, "w", encoding="utf-8") as fh:
            fh.write(out + "\n")
