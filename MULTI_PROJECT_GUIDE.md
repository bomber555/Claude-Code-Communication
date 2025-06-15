# 🚀 CCC複数プロジェクト管理 - クイックスタートガイド

## 🎯 概要
CCCプラットフォーム上で複数のプロジェクトを並列稼働させる方法を説明します。

## ⚡ クイックスタート

### 1. 最初のプロジェクト作成
```bash
# Webアプリ開発プロジェクト（4人チーム）を作成
./project-manager.sh create webapp-frontend "フロントエンド開発" 4

# プロジェクトのtmuxセッションに接続
./project-manager.sh attach webapp-frontend

# Claude Code を全エージェントで起動
./projects/webapp-frontend/start-claude.sh

# 会議を開始
./project-manager.sh meeting webapp-frontend init "プロジェクトキックオフ"
```

### 2. 複数プロジェクトの並列稼働
```bash
# 3つのプロジェクトを作成
./project-manager.sh create frontend "フロントエンド" 3
./project-manager.sh create backend "バックエンドAPI" 4  
./project-manager.sh create mobile "モバイルアプリ" 3

# 各プロジェクトで並列に会議を実行
# ターミナル1
./project-manager.sh meeting frontend init "スプリント計画"

# ターミナル2  
./project-manager.sh meeting backend init "アーキテクチャレビュー"

# ターミナル3
./project-manager.sh meeting mobile init "UI設計レビュー"
```

## 🔧 主要コマンド

### プロジェクト管理
```bash
# プロジェクト作成
./project-manager.sh create <project-id> <project-name> [team-size]

# プロジェクト一覧表示
./project-manager.sh list

# ダッシュボード表示
./project-manager.sh dashboard

# プロジェクト停止
./project-manager.sh stop <project-id>

# プロジェクト再起動
./project-manager.sh restart <project-id>
```

### セッション操作
```bash
# プロジェクトセッションにアタッチ
./project-manager.sh attach <project-id>

# Claude Code起動（プロジェクト内で実行）
./start-claude.sh
```

### 会議システム
```bash
# 会議開始
./project-manager.sh meeting <project-id> init "会議タイトル"

# 順次発言セッション
./project-manager.sh meeting <project-id> round-robin "進捗確認"

# worker間質疑応答
./project-manager.sh meeting <project-id> qa "技術的課題"

# president発言機会
./project-manager.sh meeting <project-id> invite-president "戦略アドバイス"
```

## 📁 プロジェクト構造

各プロジェクトは以下の構造で作成されます：

```
projects/
└── project-name/
    ├── project.conf          # プロジェクト設定
    ├── agent-send.sh         # プロジェクト固有通信スクリプト
    ├── meeting-chair.sh      # プロジェクト固有会議システム
    ├── start-claude.sh       # Claude Code一括起動
    ├── logs/                 # ログファイル
    ├── tmp/                  # 一時ファイル
    └── artifacts/            # 成果物
```

## 🎪 実用シナリオ

### シナリオ1: スタートアップの製品開発
```bash
# MVPから開始
./project-manager.sh create mvp "MVP開発" 2

# 成功後、本格チーム立ち上げ
./project-manager.sh create product-web "Webアプリ" 4
./project-manager.sh create product-mobile "モバイルアプリ" 3
./project-manager.sh create infrastructure "インフラ" 2
```

### シナリオ2: 大企業の部門別開発
```bash
# 複数の製品ライン
./project-manager.sh create product-a "主力製品A" 5
./project-manager.sh create product-b "新製品B" 4
./project-manager.sh create research "R&D" 3
./project-manager.sh create platform "共通基盤" 6
```

### シナリオ3: アジャイル開発チーム
```bash
# 機能別チーム構成
./project-manager.sh create feature-auth "認証機能" 3
./project-manager.sh create feature-payment "決済機能" 4
./project-manager.sh create feature-analytics "分析機能" 3
./project-manager.sh create qa-testing "品質保証" 3
```

## 🎯 運用のベストプラクティス

### 1. プロジェクト命名
- 短く分かりやすいID使用
- チーム・機能・製品名を反映
- 例: `webapp-frontend`, `api-v2`, `mobile-ios`

### 2. チームサイズ
- 3-5人程度が効率的
- 大きすぎるチームは分割検討
- プロジェクト性質に応じて調整

### 3. 並列稼働の管理
- 同時実行プロジェクト数の監視
- システムリソースの確認
- 定期的なプロジェクト間情報共有

### 4. セッション管理
- 不要なプロジェクトの適切な停止
- 定期的な環境リセット
- tmuxセッション一覧の定期確認

## 🔍 トラブルシューティング

### セッションが見つからない場合
```bash
# tmuxセッション一覧確認
tmux list-sessions

# プロジェクトを再起動
./project-manager.sh restart <project-id>
```

### ペインレイアウトが崩れた場合
```bash
# プロジェクトセッションにアタッチ
tmux attach-session -t project-<project-id>

# レイアウトを再調整
tmux select-layout -t team tiled
```

### Claude Codeが起動しない場合
```bash
# 個別にエージェントを確認
./projects/<project-id>/agent-send.sh --list

# 手動でClaude起動
tmux send-keys -t project-<project-id>:team.0 'claude' C-m
```

## 📊 監視とログ

### ダッシュボードで全体確認
```bash
./project-manager.sh dashboard
```

### プロジェクト個別ログ確認
```bash
# 会議ログ
tail -f ./projects/<project-id>/logs/meeting_*.log

# エージェント通信ログ
tail -f ./projects/<project-id>/logs/agent_send.log
```

## 🎉 まとめ

CCCの複数プロジェクト管理システムにより、以下が実現できます：

- **完全分離**: プロジェクト間での干渉なし
- **並列稼働**: 複数チームの同時進行
- **スケーラブル**: プロジェクト数の柔軟な調整
- **効率的管理**: 統一されたコマンド体系

このシステムを活用して、効率的なマルチプロジェクト開発を実現してください！🚀
