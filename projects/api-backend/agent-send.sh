#!/bin/bash
# プロジェクトapi-backend 固有のagent-send.sh

PROJECT_ID="api-backend"
SESSION_NAME="project-$PROJECT_ID"
TEAM_SIZE=4

function send_to_agent() {
    local agent="$1"
    local message="$2"
    local timestamp=$(date '+%H:%M:%S')
    
    case "$agent" in
        "president")
            tmux send-keys -t "$SESSION_NAME:management.0" "$message" C-m
            ;;
        "boss")
            tmux send-keys -t "$SESSION_NAME:team.0" "$message" C-m
            ;;
        worker*)
            local worker_num=${agent#worker}
            if [[ "$worker_num" =~ ^[0-9]+$ ]] && [ "$worker_num" -le "$TEAM_SIZE" ]; then
                tmux send-keys -t "$SESSION_NAME:team.$worker_num" "$message" C-m
            else
                echo "❌ 無効なworker番号: $worker_num (1-$TEAM_SIZE まで有効)"
                return 1
            fi
            ;;
        *)
            echo "❌ 無効なエージェント名: $agent"
            echo "有効なエージェント: president, boss, worker1-worker$TEAM_SIZE"
            return 1
            ;;
    esac
    
    # ログ記録
    mkdir -p "./logs"
    echo "[$timestamp] $agent <- $message" >> "./logs/agent_send.log"
    echo "✅ メッセージ送信完了: $agent"
}

function list_agents() {
    echo "📋 プロジェクト api-backend のエージェント一覧:"
    echo "  - president"
    echo "  - boss"
    for i in $(seq 1 $TEAM_SIZE); do
        echo "  - worker$i"
    done
}

# メイン実行部
case "$1" in
    "--list")
        list_agents
        ;;
    *)
        if [[ $# -lt 2 ]]; then
            echo "使用方法: $0 <agent> <message>"
            echo "          $0 --list"
            echo ""
            list_agents
            exit 1
        fi
        send_to_agent "$1" "$2"
        ;;
esac
