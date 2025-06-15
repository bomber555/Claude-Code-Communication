# 🚀 CCC導入プロンプト (簡潔版)

Claude Codeで以下を実行してください：

```
私のプロジェクトにCCC (Claude Code Communication) マルチエージェント協調システムを導入してください。

## プロジェクト情報
- 名前: [プロジェクト名]
- 言語: [例: React/Python/Go]
- チーム: [例: 3人]

## 導入手順
1. CCCリポジトリをクローン: https://github.com/nishimoto265/Claude-Code-Communication (ブランチ: boss1-leader-meeting-system)
2. プロジェクト内に `ccc/` ディレクトリ作成
3. 以下ファイルを配置:
   - setup.sh (tmux環境構築)
   - agent-send.sh (エージェント通信)  
   - ccc-meeting-chair.sh (会議システム)
   - instructions/ (指示書)
4. README.mdにCCC使用方法追記
5. .gitignoreにCCC関連ファイル追加

## 導入完了後
`./ccc/setup.sh` → 各ペインでClaude起動 → `./ccc/ccc-meeting-chair.sh init "開発会議"` で協調開発開始

プロジェクトに最適化して導入してください。
```

---

## 🎯 コピペ用プロンプト集

### React プロジェクト用
```
私のReactプロジェクトにCCCマルチエージェント協調システムを導入してください。フロントエンド開発に特化した4人チーム構成で、npm scriptsとの連携も含めて最適化してください。

CCCリポジトリ: https://github.com/nishimoto265/Claude-Code-Communication (ブランチ: boss1-leader-meeting-system)
```

### Python/AI プロジェクト用  
```
私のPython AIプロジェクトにCCCマルチエージェント協調システムを導入してください。機械学習開発に特化した3人チーム構成で、Jupyter notebookとの連携も含めて最適化してください。

CCCリポジトリ: https://github.com/nishimoto265/Claude-Code-Communication (ブランチ: boss1-leader-meeting-system)
```

### Go API プロジェクト用
```
私のGo APIプロジェクトにCCCマルチエージェント協調システムを導入してください。バックエンドAPI開発に特化した4人チーム構成で、go modとの連携も含めて最適化してください。

CCCリポジトリ: https://github.com/nishimoto265/Claude-Code-Communication (ブランチ: boss1-leader-meeting-system)
```

### モバイルアプリ用
```
私のモバイルアプリプロジェクトにCCCマルチエージェント協調システムを導入してください。iOS/Android開発に特化した5人チーム構成で、エミュレータ連携も含めて最適化してください。

CCCリポジトリ: https://github.com/nishimoto265/Claude-Code-Communication (ブランチ: boss1-leader-meeting-system)
```
