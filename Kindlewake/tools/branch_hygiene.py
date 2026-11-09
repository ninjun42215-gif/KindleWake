#!/usr/bin/env python3
"""Read-only branch hygiene report. Never deletes or rewrites branches."""
from __future__ import annotations
import argparse
import json
import subprocess
from datetime import datetime, timezone
from pathlib import Path

def run(*args, check=True):
    return subprocess.run(["git", *args], text=True, capture_output=True, check=check)

def main():
    p=argparse.ArgumentParser()
    p.add_argument("--base", default="main")
    p.add_argument("--report-dir", type=Path, required=True)
    p.add_argument("--stale-days", type=int, default=60)
    a=p.parse_args()
    base=f"origin/{a.base}"
    if run("rev-parse", "--verify", base, check=False).returncode:
        raise SystemExit(f"Base branch not found: {base}")
    refs=run("for-each-ref", "--format=%(refname:short)|%(objectname)|%(committerdate:iso-strict)|%(committerdate:unix)", "refs/remotes/origin").stdout.splitlines()
    now=datetime.now(timezone.utc).timestamp()
    rows=[]
    for line in refs:
        if not line: continue
        name,sha,date,stamp=line.split("|",3)
        if name in {"origin/HEAD",base}: continue
        merged=run("merge-base","--is-ancestor",name,base,check=False).returncode==0
        age=max(0,int((now-int(stamp))/86400))
        rows.append({"branch":name.removeprefix("origin/"),"sha":sha,"last_commit":date,"age_days":age,"merged_into_base":merged,
                     "recommendation":"candidate for manual deletion after owner review" if merged else ("review whether still needed; not safe to delete automatically" if age>=a.stale_days else "active or recently updated")})
    rows.sort(key=lambda x:(not x["merged_into_base"],-x["age_days"],x["branch"]))
    a.report_dir.mkdir(parents=True,exist_ok=True)
    payload={"base_branch":a.base,"generated_at_utc":datetime.now(timezone.utc).isoformat(),"stale_threshold_days":a.stale_days,"branches":rows,
             "policy":"Read-only report. No branch is deleted, reset, force-pushed or merged."}
    (a.report_dir/"branch-hygiene.json").write_text(json.dumps(payload,indent=2)+"\n",encoding="utf-8")
    lines=["# Kindlewake branch hygiene report","",f"- Base branch: {a.base}",f"- Branches inspected: {len(rows)}",f"- Stale threshold: {a.stale_days} days","",
           "| Branch | Last commit age | Merged into base? | Recommendation |","|---|---:|---|---|"]
    lines += [f"| {r['branch']} | {r['age_days']} days | {'yes' if r['merged_into_base'] else 'no'} | {r['recommendation']} |" for r in rows]
    if not rows: lines.append("| — | — | — | No other remote branches found. |")
    lines += ["","## Safety",payload["policy"]]
    (a.report_dir/"branch-hygiene.md").write_text("\n".join(lines)+"\n",encoding="utf-8")
    print("\n".join(lines))
if __name__=="__main__": main()
