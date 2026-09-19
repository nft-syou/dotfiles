# Claude Code 設定 (OS 共通)

Windows / macOS 共通の Claude Code 設定を管理します。各 OS のセットアップスクリプトが
このディレクトリの内容を `~/.claude/`（Windows は `%USERPROFILE%\.claude\`）へ
シンボリックリンクします。

## 構成

```
common/claude/
├── settings.json                 # 共有設定 (プラグイン/マーケットプレイス宣言)
├── settings.local.json.example   # マシン固有上書きの雛形 (model/effort 等 / git 管理外)
├── CLAUDE.md                     # 全プロジェクト共通のグローバル指示
├── skills/                       # 自作スキル (<name>/SKILL.md)
├── commands/                     # スラッシュコマンド
└── agents/                       # サブエージェント定義
```

> **注意: ユーザーレベルの `~/.claude/settings.local.json` は Claude Code に読まれません。**
> `settings.local.json` が効くのはプロジェクト単位（`<repo>/.claude/settings.local.json`）だけです
> （公式の優先順位: 管理設定 > `--settings` > プロジェクト local > プロジェクト共有 > ユーザー `~/.claude/settings.json`）。
> そのため model / effortLevel も `settings.json` に置いて共有しています。
> マシン固有にしたいものは下記の「git clean フィルタ」で除外します。

## リンク先 (シンボリックリンク)

| リポジトリ | リンク先 |
|---|---|
| `common/claude/settings.json` | `~/.claude/settings.json` |
| `common/claude/CLAUDE.md` | `~/.claude/CLAUDE.md` |
| `common/claude/skills` | `~/.claude/skills` |
| `common/claude/commands` | `~/.claude/commands` |
| `common/claude/agents` | `~/.claude/agents` |

## プラグイン / マーケットプレイスの宣言的管理

`settings.json` にマーケットプレイスと有効プラグインを記述すると、マシンをまたいで再現できます。

```jsonc
{
  "extraKnownMarketplaces": {
    "claude-plugins-official": {
      "source": { "source": "github", "repo": "anthropics/claude-plugins-public" }
    }
  },
  "enabledPlugins": {
    "context7@claude-plugins-official": true
  }
}
```

- `extraKnownMarketplaces`: 追加マーケットプレイスの取得元。
- `enabledPlugins`: `"<プラグイン名>@<マーケットプレイス名>": true` の**オブジェクト形式**（配列ではない点に注意）。
- 新しいマシンでは宣言に基づきプラグインのインストールが促されます。手動で入れる場合:

  ```bash
  claude plugin install context7@claude-plugins-official
  ```

## マシン固有の設定 (共有しないもの) — git clean フィルタ

Orca は起動時に `~/.claude/settings.json`（＝共有シンボリックリンク）へ、そのマシンのフルパスを
直書きした `hooks`（全イベント）と `statusLine` を注入します。これを他 OS に配ると壊れるので、
**git の clean フィルタでコミット時にだけ剥がします**。作業ツリーの実体はそのままなので Orca は動き続けます。

- `.gitattributes` … `common/claude/settings.json filter=claude-settings`
- `strip-orca.mjs` … フィルタ本体。stdin の JSON から次だけを落として stdout へ返す
  - `hooks` のうち command が `.orca/agent-hooks/` を指すグループ
  - `statusLine` のうち command が `ORCA_` 環境変数を参照するもの
  - JSON として読めない入力は無加工で返す（壊さない）
- 登録は各 OS の install スクリプトが行う（`git config filter.claude-settings.clean 'node common/claude/strip-orca.mjs'`）。
  手動なら同コマンドをリポジトリ直下で実行。

**共通化したい hooks はそのまま `settings.json` に書けば通ります**（Orca 由来でなければフィルタは触らない）。
ただし Windows のフルパスは書かず、`~/.claude/hooks/xxx.sh` や `node ~/.claude/hooks/xxx.mjs` のように
ホーム相対で書き、スクリプト本体は `common/claude/hooks/` に置いてリンクしてください。

> `git status` は作業ツリーの mtime 変化で一瞬「変更あり」に見えることがありますが、
> `git diff` はフィルタ後で比較するため差分なしになります。

- `settings.local.json.example` … 旧方式の雛形。ユーザーレベルでは読まれないため、プロジェクト単位
  （`<repo>/.claude/settings.local.json`）で使う場合の参考としてのみ残しています。
- `sessions/`, `projects/`, `cache/`, `history.jsonl` などのランタイム状態は共有しません。
- `cleanupPeriodDays` は 36500 に設定済み（セッション記録を実質無期限で保持）。

## 反映方法

- macOS: `./mac/install.sh`
- Windows: `pwsh -ExecutionPolicy Bypass -File .\windows\install.ps1`

既存ファイルは `.backup` 拡張子で自動退避されます。
