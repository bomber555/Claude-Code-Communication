#!/bin/bash
# demo-meeting.sh - boss1リーダー型会議システムのデモスクリプト

echo "🎤 boss1リーダー型会議システム デモ"
echo "================================"
echo ""

# tmuxセッションが存在するか確認
if ! tmux has-session -t multiagent 2>/dev/null || ! tmux has-session -t president 2>/dev/null; then
    echo "❌ tmuxセッションが見つかりません。先に setup.sh を実行してください。"
    echo ""
    echo "実行手順:"
    echo "1. ./setup.sh"
    echo "2. 各セッションでClaude Codeを起動"
    echo "3. ./demo-meeting.sh"
    exit 1
fi

echo "🚀 デイリースタンドアップ会議のデモを開始します"
echo ""

# 会議開始
echo "📋 会議を開始しています..."
./ccc-meeting-chair.sh init "デイリースタンドアップ $(date +%Y/%m/%d)"

echo ""
echo "✅ 会議が開始されました。次の手順で進行します："
echo ""
echo "1️⃣ 順次発言セッション（worker1→2→3）を開始"
echo "2️⃣ presidentに発言機会を提供"
echo "3️⃣ worker間質疑応答セッション"
echo "4️⃣ 会議終了"
echo ""

read -p "続行するには Enter を押してください..."

echo ""
echo "🔄 順次発言セッションを開始します..."
./ccc-meeting-chair.sh round-robin "昨日の成果と今日の予定、課題があれば"

echo ""
echo "💬 worker間の質疑応答セッションを開始しますか？"
echo "   技術的な課題の共有や相互協力について自由に議論できます。"
read -p "開始する場合は 'y' を入力: " qa_choice

if [[ "$qa_choice" == "y" ]]; then
    echo ""
    echo "❓ worker間質疑応答セッションを開始..."
    ./ccc-meeting-chair.sh qa "技術的課題の共有・相互協力"
fi

echo ""
echo "📊 会議を終了します..."
./ccc-meeting-chair.sh end

echo ""
echo "🎉 デモ完了！"
echo ""
echo "📁 生成されたファイル:"
echo "   - 会議ログ: logs/meeting_*.log"
echo "   - チャット履歴: tmp/chat_history.txt"
echo ""
echo "🔧 その他の機能:"
echo "   - 個別指名: ./ccc-meeting-chair.sh nominate <参加者> '<質問>'"
echo "   - president招待: ./ccc-meeting-chair.sh invite-president '<コンテキスト>'"
echo "   - 状況確認: ./ccc-meeting-chair.sh status"
echo ""
echo "📖 詳細な使用方法は README.md をご確認ください。"
