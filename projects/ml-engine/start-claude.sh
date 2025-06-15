#!/bin/bash
# プロジェクト ml-engine のClaude Code一括起動スクリプト

PROJECT_ID="ml-engine"
SESSION_NAME="project-$PROJECT_ID"

echo "🚀 プロジェクト $PROJECT_ID でClaude Code起動中..."

# president起動
echo "📊 president起動中..."
tmux send-keys -t "$SESSION_NAME:management.0" 'claude' C-m

sleep 2

# boss起動
echo "👔 boss起動中..."
tmux send-keys -t "$SESSION_NAME:team.0" 'claude' C-m

sleep 1

# workers起動
for i in $(seq 1 3); do
    echo "👷 worker$i 起動中..."
    tmux send-keys -t "$SESSION_NAME:team.$i" 'claude' C-m
    sleep 1
done

echo "✅ プロジェクト $PROJECT_ID の全エージェントでClaude Code起動完了！"
echo ""
echo "📋 次のステップ:"
echo "  - tmux attach-session -t $SESSION_NAME  # セッションに接続"
echo "  - ./meeting-chair.sh init \"会議開始\"      # 会議システム起動"
echo "  - ./agent-send.sh --list               # エージェント一覧確認"
