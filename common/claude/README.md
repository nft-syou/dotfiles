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

> **model / effortLevel は共有しません。** これらはマシン固有として
> `~/.claude/settings.local.json` に置きます（git 管理外・共有 settings.json より優先）。

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

## マシン固有の設定 (共有しないもの)

- `~/.claude/settings.local.json` … 各マシン固有の上書き。共有 `settings.json` より優先。git 管理外。
  - **model / effortLevel** はここに置きます（マシンごとに変えられるように）。
  - 雛形: `settings.local.json.example` をコピーして作成。
- `sessions/`, `projects/`, `cache/`, `history.jsonl` などのランタイム状態は共有しません。

> **注意:** アプリ上で `/model` を実行してモデルを切り替えると、Claude Code は
> ユーザースコープの `settings.json`（＝共有シンボリックリンク）に書き込みます。
> その場合 model が共有ファイルに追記され git 差分として現れるので、`git checkout` で
> 破棄するか、必要なら意図的に共有側へ移してください。

## 反映方法

- macOS: `./mac/install.sh`
- Windows: `pwsh -ExecutionPolicy Bypass -File .\windows\install.ps1`

既存ファイルは `.backup` 拡張子で自動退避されます。
