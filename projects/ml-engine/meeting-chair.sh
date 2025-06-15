#!/bin/bash
# ccc-meeting-chair.sh - boss1リーダー型会議システム

# 設定
MEETING_LOG="./logs/meeting_$(date +%Y%m%d_%H%M%S).log"
CHAT_HISTORY="./tmp/chat_history.txt"
CURRENT_SPEAKER=""
MEETING_STATUS="waiting"  # waiting, in_progress, qa_session, ended
PARTICIPANTS=("worker1" "worker2" "worker3")
LEADER="boss"
OBSERVER="president"

# ログディレクトリを作成
mkdir -p ./logs ./tmp

# 会議履歴管理
function init_meeting() {
    local topic="$1"
    echo "=== 会議開始: $topic ===" > $CHAT_HISTORY
    echo "リーダー: $LEADER" >> $CHAT_HISTORY
    echo "傍聴者: $OBSERVER" >> $CHAT_HISTORY
    echo "参加者: ${PARTICIPANTS[*]}" >> $CHAT_HISTORY
    echo "開始時刻: $(date)" >> $CHAT_HISTORY
    echo "=" >> $CHAT_HISTORY
    
    MEETING_STATUS="in_progress"
    
    # 全員に会議開始通知
    broadcast_to_all "📋 会議開始: $topic" "$LEADER"
    
    # presidentに傍聴者としての役割説明
    ./agent-send.sh "$OBSERVER" "
📋 会議開始: $topic
あなたは傍聴者として参加しています。
適切なタイミングでアドバイスや質問をお願いします。
"
    
    log_meeting "会議開始: $topic (リーダー: $LEADER)"
}

# 全員にメッセージ配信
function broadcast_to_all() {
    local message="$1"
    local sender="${2:-$LEADER}"
    local timestamp=$(date '+%H:%M:%S')
    
    # worker1-3に送信
    for participant in "${PARTICIPANTS[@]}"; do
        ./agent-send.sh "$participant" "[$timestamp] $sender: $message"
    done
    
    # presidentにも送信
    ./agent-send.sh "$OBSERVER" "[$timestamp] $sender: $message"
}

# 最新チャット履歴を送信
function send_chat_history() {
    local target="$1"
    local context_message="$2"
    
    # 最新の会議履歴を準備
    local history_content=$(tail -20 $CHAT_HISTORY 2>/dev/null || echo "履歴がありません")
    
    # 履歴 + コンテキストメッセージを送信
    ./agent-send.sh "$target" "
📜 最新会議履歴:
$history_content

🎯 $context_message
"
}

# 参加者を指名して発言権を付与
function nominate_speaker() {
    local speaker="$1"
    local question="$2"
    
    # worker1-3 または president の確認
    if [[ " ${PARTICIPANTS[@]} $OBSERVER " =~ " $speaker " ]]; then
        CURRENT_SPEAKER="$speaker"
        
        # 最新履歴と質問を送信
        send_chat_history "$speaker" "あなたに発言権があります。質問: $question"
        
        # 他の参加者には待機状態を通知（指名された人以外全員）
        for participant in "${PARTICIPANTS[@]}"; do
            if [[ "$participant" != "$speaker" ]]; then
                ./agent-send.sh "$participant" "🎤 現在 $speaker さんが発言中です。お待ちください。"
            fi
        done
        
        # presidentにも通知（指名されていない場合）
        if [[ "$speaker" != "$OBSERVER" ]]; then
            ./agent-send.sh "$OBSERVER" "🎤 現在 $speaker さんが発言中です。"
        fi
        
        # boss1用ログ
        ./agent-send.sh "$LEADER" "✅ $speaker を指名しました。質問: $question"
        log_meeting "${LEADER}が${speaker}を指名: $question"
        
        echo "✅ $speaker を指名しました"
    else
        echo "❌ 無効な参加者名: $speaker"
    fi
}

# 発言内容を記録
function record_speech() {
    local speaker="$1"
    local content="$2"
    local timestamp=$(date '+%H:%M:%S')
    
    # チャット履歴に追加
    echo "[$timestamp] $speaker: $content" >> $CHAT_HISTORY
    
    # 会議ログに追加
    log_meeting "$speaker: $content"
    
    # 全員に発言内容を共有
    broadcast_to_all "$speaker: $content" "📝記録"
    
    # 発言権をクリア
    CURRENT_SPEAKER=""
    
    echo "✅ $speaker の発言を記録しました"
}

# 会議ログ記録
function log_meeting() {
    local entry="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $entry" >> $MEETING_LOG
}

# 順次発言セッション
function round_robin_discussion() {
    local topic="$1"
    
    echo "🔄 順次発言セッション開始: $topic"
    broadcast_to_all "順次発言セッション開始: $topic" "$LEADER"
    
    # worker1-3を順次指名
    for i in "${!PARTICIPANTS[@]}"; do
        local participant="${PARTICIPANTS[$i]}"
        local question="$topic について、あなたの意見・進捗・課題を教えてください。（参加者 $((i+1))/${#PARTICIPANTS[@]}）"
        
        echo ""
        echo "👉 $participant さんを指名します..."
        nominate_speaker "$participant" "$question"
        
        # 発言完了待ち（手動確認）
        echo "⏳ $participant さんの発言をお待ちください..."
        echo "発言が完了したら 'y' を入力してください:"
        read -r confirmation
        
        if [[ "$confirmation" == "y" ]]; then
            echo "次の参加者に移ります..."
        fi
    done
    
    echo "✅ worker全員の発言が完了しました"
    
    # presidentに発言機会を提供
    echo ""
    echo "👥 presidentに発言機会を提供しますか？ (y/n):"
    read -r president_turn
    
    if [[ "$president_turn" == "y" ]]; then
        echo "👉 president に発言機会を提供します..."
        nominate_speaker "$OBSERVER" "全体の議論についてアドバイスや質問があれば教えてください"
        
        echo "⏳ president の発言をお待ちください..."
        echo "発言が完了したら 'y' を入力してください:"
        read -r confirmation
    fi
    
    broadcast_to_all "順次発言セッションが完了しました。" "$LEADER"
}

# worker間質疑応答セッション
function qa_session() {
    local topic="${1:-一般的な質疑応答}"
    
    echo "❓ worker間質疑応答セッション開始: $topic"
    MEETING_STATUS="qa_session"
    
    broadcast_to_all "質疑応答セッション開始: $topic" "$LEADER"
    broadcast_to_all "worker1-3は自由に質問・回答してください。終了は'exit'と発言。" "$LEADER"
    
    # 全workerに質疑応答権限を付与
    for participant in "${PARTICIPANTS[@]}"; do
        send_chat_history "$participant" "質疑応答セッション参加中。他のworkerに質問したり、質問に回答してください。"
    done
    
    # presidentには観察者として通知
    ./agent-send.sh "$OBSERVER" "質疑応答セッション開始。適宜コメントをお願いします。"
    
    echo "💬 質疑応答セッション進行中..."
    echo "セッション終了時は 'y' を入力してください:"
    read -r qa_end
    
    if [[ "$qa_end" == "y" ]]; then
        MEETING_STATUS="in_progress"
        broadcast_to_all "質疑応答セッション終了。ありがとうございました。" "$LEADER"
        echo "✅ 質疑応答セッション終了"
    fi
}

# president発言機会の提供
function invite_president() {
    local context="${1:-会議全体について}"
    
    echo "👥 president に発言機会を提供します"
    nominate_speaker "$OBSERVER" "$context についてアドバイス・質問・コメントをお願いします"
    
    echo "⏳ president の発言をお待ちください..."
    echo "発言が完了したら 'y' を入力してください:"
    read -r confirmation
    
    if [[ "$confirmation" == "y" ]]; then
        echo "✅ president の発言完了"
    fi
}

# 会議終了
function end_meeting() {
    MEETING_STATUS="ended"
    local summary_message="会議終了。お疲れさまでした。"
    
    # 最終サマリーを作成
    echo "=== 会議終了 ===" >> $CHAT_HISTORY
    echo "終了時刻: $(date)" >> $CHAT_HISTORY
    
    broadcast_to_all "$summary_message" "$LEADER"
    log_meeting "会議終了"
    
    echo "📊 会議記録: $MEETING_LOG"
    echo "💬 チャット履歴: $CHAT_HISTORY"
}

# 会議状況確認
function show_meeting_status() {
    echo "=== 会議状況 ==="
    echo "ステータス: $MEETING_STATUS"
    echo "現在の発言者: ${CURRENT_SPEAKER:-なし}"
    echo "リーダー: $LEADER"
    echo "傍聴者: $OBSERVER"
    echo "参加者: ${PARTICIPANTS[*]}"
    echo ""
    echo "=== 最新履歴 (最新5件) ==="
    tail -5 "$CHAT_HISTORY" 2>/dev/null || echo "履歴がありません"
}

# メイン実行部
case "$1" in
    "init")
        init_meeting "$2"
        ;;
    "nominate")
        nominate_speaker "$2" "$3"
        ;;
    "record")
        record_speech "$2" "$3"
        ;;
    "round-robin")
        round_robin_discussion "$2"
        ;;
    "qa")
        qa_session "$2"
        ;;
    "invite-president")
        invite_president "$2"
        ;;
    "broadcast")
        broadcast_to_all "$2" "$LEADER"
        ;;
    "end")
        end_meeting
        ;;
    "status")
        show_meeting_status
        ;;
    *)
        echo "CCC boss1リーダー型会議システム"
        echo ""
        echo "使用方法:"
        echo "  $0 init '<会議タイトル>'              # 会議開始"
        echo "  $0 nominate <参加者> '<質問>'         # 参加者指名"
        echo "  $0 record <参加者> '<発言内容>'       # 発言記録"
        echo "  $0 round-robin '<トピック>'           # 順次発言セッション"
        echo "  $0 qa '<トピック>'                   # worker間質疑応答"
        echo "  $0 invite-president '<コンテキスト>'  # president発言機会"
        echo "  $0 broadcast '<メッセージ>'           # 全員にお知らせ"
        echo "  $0 status                            # 会議状況確認"
        echo "  $0 end                               # 会議終了"
        echo ""
        echo "リーダー: $LEADER"
        echo "傍聴者: $OBSERVER"
        echo "参加者: ${PARTICIPANTS[*]}"
        ;;
esac

# プロジェクト固有設定の上書き
PROJECT_CONF="./project.conf"
if [ -f "$PROJECT_CONF" ]; then
    source "$PROJECT_CONF"
    
    # チームサイズに応じてPARTICIPANTS配列を生成
    PARTICIPANTS=()
    for i in $(seq 1 $TEAM_SIZE); do
        PARTICIPANTS+=("worker$i")
    done
fi
