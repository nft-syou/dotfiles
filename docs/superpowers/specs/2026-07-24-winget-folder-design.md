# Winget フォルダ新設によるインストール系の集約 — 設計

日付: 2026-07-24

## 目的

現在 `windows/volta/install-volta.ps1` に埋め込まれている winget によるインストール処理を、
mac の `mac/brew/`(`install-brew.sh` + `Brewfile`)と同じ構成の `windows/winget/` に集約する。
今後 Windows で使うパッケージは `packages.txt` への追記だけで管理できるようにする。

## 決定事項

- パッケージ一覧の形式: **テキスト一覧 + ループ**(`packages.txt`。winget import 用 JSON や DSC YAML は不採用)
- volta フォルダ: **残して縮小**(`volta install node` の後処理スクリプトとして役割を限定)
- packages.txt の初期内容: **Volta.Volta のみ**(現状の挙動を変えない安全な移行)

## 新しい構成

```
windows/
├── README.md            # 構成図・手順を更新
├── install.ps1          # (変更なし) シンボリックリンク作成
├── winget/
│   ├── install-winget.ps1   # packages.txt を読んで一括インストール
│   └── packages.txt         # winget パッケージ ID 一覧 (Brewfile 相当)
└── volta/
    └── install-volta.ps1    # 縮小: volta install node のみ (Node.js セットアップ)
```

## コンポーネント設計

### winget/packages.txt

- 1行1パッケージ ID(初期内容は `Volta.Volta` のみ)
- `#` 始まりの行と空行は無視(Brewfile 同様にセクション分けコメントを書ける)

### winget/install-winget.ps1

`mac/brew/install-brew.sh` の流れを踏襲する。

1. winget の存在確認。なければ「Microsoft Store から『アプリ インストーラー』を導入してください」
   と案内してエラー終了(既存 install-volta.ps1 のメッセージを流用)
2. `packages.txt` を読み込み(コメント・空行を除去)、各 ID について:
   - `winget list --id <ID> --exact` で導入済みか確認
   - 導入済み → スキップ表示
   - 未導入 → `winget install --id <ID> --exact --accept-source-agreements --accept-package-agreements`
3. 何度実行しても安全な冪等動作とする(`brew bundle` 相当)

スクリプトは既存 PowerShell スクリプトの慣例に合わせる:
`#Requires -Version 5.1`、コメントベースヘルプ(.SYNOPSIS 等)、`$ErrorActionPreference = 'Stop'`、
自身のパスから `packages.txt` を解決。

### volta/install-volta.ps1(縮小)

winget 関連の処理(存在確認・Volta インストール)を削除し、以下のみ残す。

1. PATH のセッション反映(Machine + User の PATH を `$env:Path` に再設定)
2. `volta` コマンド確認。なければ「先に `windows\winget\install-winget.ps1` を実行してください」
   と案内してエラー終了
3. `volta install node`(Node.js LTS + npm)
4. volta / node / npm のバージョン表示

### windows/README.md

- 構成図を新構成に更新
- セットアップ手順を3ステップに更新:
  1. winget でパッケージ一括インストール(`winget/install-winget.ps1`)
  2. Node.js セットアップ(`volta/install-volta.ps1`)
  3. 設定ファイルのリンク(`install.ps1`)
- パッケージ追加方法(`packages.txt` に ID を追記して再実行)を記載

## テスト・検証

開発マシンは macOS のため Windows 実機での実行確認は行わない。検証は以下で代替する。

- PowerShell 構文の静的確認(可能なら `pwsh -NoProfile -Command` によるパースチェック)
- packages.txt のパース仕様(コメント・空行の除去)がスクリプトの実装と一致していることの目視確認
- README の手順・構成図と実ファイルの整合確認

## スコープ外

- Volta 以外のパッケージ追加(使うときに packages.txt へ追記する)
- winget ソースの管理、バージョン固定、アンインストール処理
- mac 側の変更
