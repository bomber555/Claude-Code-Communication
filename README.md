# 🤖 Tmux Multi-Agent Communication Demo

Agent同士がやり取りするtmux環境のデモシステム

## 🎯 デモ概要

PRESIDENT → BOSS → Workers の階層型指示システムを体感できます

### 🎤 NEW: boss1リーダー型会議システム
boss1がリーダーシップを取り、presidentが傍聴者として参加する実践的な会議システムも利用可能です！
- **boss1主導**: 会議進行・発言者指名・判断権限
- **president傍聴**: 適切なタイミングでアドバイス・質問
- **worker協調**: 順次発言・質疑応答セッション

### 🚀 NEW: 複数プロジェクト並列稼働システム
複数のプロジェクトを同時に独立して稼働させることができます！
- **完全分離**: プロジェクト間での干渉なし
- **並列実行**: 複数チームが同時に作業
- **スケーラブル**: プロジェクト数の柔軟な調整
- **効率管理**: 統一されたコマンド体系

詳細は [MULTI_PROJECT_GUIDE.md](./MULTI_PROJECT_GUIDE.md) をご参照ください。

### 👥 エージェント構成

```
📊 PRESIDENT セッション (1ペイン)
└── PRESIDENT: プロジェクト統括責任者

📊 multiagent セッション (4ペイン)  
├── boss1: チームリーダー
├── worker1: 実行担当者A
├── worker2: 実行担当者B
└── worker3: 実行担当者C
```

## 🚀 クイックスタート

### 0. リポジトリのクローン

```bash
git clone https://github.com/nishimoto265/Claude-Code-Communication.git
cd Claude-Code-Communication
```

### 1. tmux環境構築

⚠️ **注意**: 既存の `multiagent` と `president` セッションがある場合は自動的に削除されます。

```bash
./setup.sh
```

### 2. セッションアタッチ

```bash
# マルチエージェント確認
tmux attach-session -t multiagent

# プレジデント確認（別ターミナルで）
tmux attach-session -t president
```

### 3. Claude Code起動

**手順1: President認証**
```bash
# まずPRESIDENTで認証を実施
tmux send-keys -t president 'claude' C-m
```
認証プロンプトに従って許可を与えてください。

**手順2: Multiagent一括起動**
```bash
# 認証完了後、multiagentセッションを一括起動
for i in {0..3}; do tmux send-keys -t multiagent:0.$i 'claude' C-m; done
```

### 4. デモ実行

PRESIDENTセッションで直接入力：
```
あなたはpresidentです。指示書に従って
```

## 📜 指示書について

各エージェントの役割別指示書：
- **PRESIDENT**: `instructions/president.md`
- **boss1**: `instructions/boss.md` 
- **worker1,2,3**: `instructions/worker.md`

**Claude Code参照**: `CLAUDE.md` でシステム構造を確認

**要点:**
- **PRESIDENT**: 「あなたはpresidentです。指示書に従って」→ boss1に指示送信
- **boss1**: PRESIDENT指示受信 → workers全員に指示 → 完了報告
- **workers**: Hello World実行 → 完了ファイル作成 → 最後の人が報告

## 🎬 期待される動作フロー

```
1. PRESIDENT → boss1: "あなたはboss1です。Hello World プロジェクト開始指示"
2. boss1 → workers: "あなたはworker[1-3]です。Hello World 作業開始"  
3. workers → ./tmp/ファイル作成 → 最後のworker → boss1: "全員作業完了しました"
4. boss1 → PRESIDENT: "全員完了しました"
```

## 🔧 手動操作

### agent-send.shを使った送信

```bash
# 基本送信
./agent-send.sh [エージェント名] [メッセージ]

# 例
./agent-send.sh boss1 "緊急タスクです"
./agent-send.sh worker1 "作業完了しました"
./agent-send.sh president "最終報告です"

# エージェント一覧確認
./agent-send.sh --list
```

## 🧪 確認・デバッグ

### ログ確認

```bash
# 送信ログ確認
cat logs/send_log.txt

# 特定エージェントのログ
grep "boss1" logs/send_log.txt

# 完了ファイル確認
ls -la ./tmp/worker*_done.txt
```

### セッション状態確認

```bash
# セッション一覧
tmux list-sessions

# ペイン一覧
tmux list-panes -t multiagent
tmux list-panes -t president
```

## 🔄 環境リセット

```bash
# セッション削除
tmux kill-session -t multiagent
tmux kill-session -t president

# 完了ファイル削除
rm -f ./tmp/worker*_done.txt

# 再構築（自動クリア付き）
./setup.sh
```

---

🚀 **Agent Communication を体感してください！** 🤖✨

## 🎤 boss1リーダー型会議システム

### 概要
boss1がリーダーシップを取り、presidentが傍聴者として適切なタイミングで参加する実践的な会議システムです。

### 特徴
- **boss1主導の会議進行**: 実際のチームリーダーが会議を運営
- **president傍聴参加**: 高次視点からの助言・アドバイス
- **worker協調促進**: 順次発言・質疑応答による知識共有
- **最新情報共有**: 発言時に全員に最新の会議履歴を配信

### 使用方法

#### 基本コマンド
```bash
# 会議開始
./ccc-meeting-chair.sh init "デイリースタンドアップ"

# 順次発言セッション（worker1→2→3, その後presidentに発言機会提供可）
./ccc-meeting-chair.sh round-robin "昨日の進捗と今日の予定"

# 個別指名
./ccc-meeting-chair.sh nominate worker2 "API統合の状況は？"

# worker間質疑応答（boss1判断で開始）
./ccc-meeting-chair.sh qa "技術的な課題や相互協力について"

# presidentに発言機会（boss1判断で）
./ccc-meeting-chair.sh invite-president "全体状況についてアドバイス"

# 会議終了
./ccc-meeting-chair.sh end
```

#### 会議フロー例
```
1. boss1: 会議開始・議題提示
2. worker1→2→3: 順次発言（各人に最新履歴送信）
3. president: アドバイス・質問（boss1判断のタイミング）
4. workers: 質疑応答セッション（相互協力・知識共有）
5. boss1: まとめ・次のアクション決定
```

#### 実用シナリオ
- **デイリースタンドアップ**: 進捗共有・課題報告
- **技術判断会議**: 各専門分野からの評価→president戦略助言→worker間議論
- **プロジェクト振り返り**: 成果発表→プロセス改善提案→ベストプラクティス共有

### 利点
- **効率的な会議運営**: boss1による集中した進行管理
- **情報格差解消**: 毎回最新の会議履歴を全員に配信
- **実践的な構造**: 現実のチーム運営構造を反映
- **柔軟な参加**: presidentの適切なタイミングでの貢献

--- 