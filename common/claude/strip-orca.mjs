#!/usr/bin/env node
// git clean フィルタ: ~/.claude/settings.json から Orca が注入するマシン固有設定だけを剥がして stdin -> stdout。
// 対象: hooks のうち command が .orca/agent-hooks/ を指すグループ、statusLine のうち ORCA_ 環境変数を参照するもの。
// それ以外の hooks(共通化したいもの)はそのまま通す。JSON として読めない入力は無加工で返す(壊さない)。
import { readFileSync } from "node:fs";

const ORCA_HOOK = /[\/]\.orca[\/]agent-hooks[\/]/;
const ORCA_STATUS = /ORCA_/;

const input = readFileSync(0, "utf8");
let obj;
try { obj = JSON.parse(input); } catch { process.stdout.write(input); process.exit(0); }

const isOrcaGroup = (g) => Array.isArray(g?.hooks) && g.hooks.length > 0 && g.hooks.every((h) => ORCA_HOOK.test(String(h?.command ?? "")));

if (obj && typeof obj.hooks === "object" && obj.hooks) {
  for (const ev of Object.keys(obj.hooks)) {
    const kept = (obj.hooks[ev] ?? []).filter((g) => !isOrcaGroup(g));
    if (kept.length) obj.hooks[ev] = kept; else delete obj.hooks[ev];
  }
  if (Object.keys(obj.hooks).length === 0) delete obj.hooks;
}
if (obj?.statusLine && ORCA_STATUS.test(String(obj.statusLine.command ?? ""))) delete obj.statusLine;

const eol = input.includes("\r\n") ? "\r\n" : "\n";
process.stdout.write(JSON.stringify(obj, null, 2).replace(/\n/g, eol) + eol);
