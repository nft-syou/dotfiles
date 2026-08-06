#Requires -Version 7.0
# PowerShell 7 プロファイル (dotfiles 管理 / install.ps1 が $PROFILE にシンボリックリンクする)
# safe-chain 等のインストーラが自動追記する行は、アンインストーラが認識できるよう原文のまま残すこと。

# safe-chain 未インストールのマシンでも起動エラーにならないよう存在ガード (中の行はインストーラ追記の原文)
if (Test-Path 'C:\Users\user\.safe-chain\scripts\init-pwsh.ps1') {
. "C:\Users\user\.safe-chain\scripts\init-pwsh.ps1" # Safe-chain PowerShell initialization script
}
