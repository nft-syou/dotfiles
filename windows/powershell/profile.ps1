#Requires -Version 7.0
# PowerShell 7 プロファイル本体 (dotfiles 管理・可搬)
#
# $PROFILE 実体はマシンローカルのスタブ (install.ps1 が生成) で、そこから本ファイルが
# dot-source される。safe-chain 等のインストーラによる絶対パスの追記はスタブ側に残るため、
# このファイルには環境依存のパスを書かないこと。
