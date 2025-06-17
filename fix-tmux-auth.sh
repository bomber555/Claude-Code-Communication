#!/bin/bash
# tmux用Claude Code環境変数設定スクリプト

# メインターミナルから重要な環境変数を取得
MAIN_ENV_VARS=(
    "CLAUDE_CODE_USE_BEDROCK"
    "ANTHROPIC_MODEL" 
    "CLAUDECODE"
    "CLAUDE_CODE_ENTRYPOINT"
)

# 認証関連の環境変数も含める
AUTH_ENV_VARS=(
    "ANTHROPIC_API_KEY"
    "AWS_PROFILE"
    "AWS_ACCESS_KEY_ID"
    "AWS_SECRET_ACCESS_KEY"
    "HOME"
    "USER"
)

echo "🔧 tmux環境変数同期スクリプト"
echo "=============================="

# 全セッションに環境変数を設定する関数
sync_env_to_session() {
    local session_name=$1
    echo "📡 セッション '$session_name' に環境変数を同期中..."
    
    # Claude Code関連
    for var in "${MAIN_ENV_VARS[@]}"; do
        if [ ! -z "${!var}" ]; then
            tmux set-environment -t "$session_name" "$var" "${!var}"
            echo "  ✅ $var=${!var}"
        fi
    done
    
    # 認証関連
    for var in "${AUTH_ENV_VARS[@]}"; do
        if [ ! -z "${!var}" ]; then
            tmux set-environment -t "$session_name" "$var" "${!var}"
            echo "  🔑 $var=[設定済み]"
        fi
    done
    
    # Claude設定ディレクトリのパス
    tmux set-environment -t "$session_name" "CLAUDE_CONFIG_DIR" "$HOME/.claude"
    echo "  📁 CLAUDE_CONFIG_DIR=$HOME/.claude"
}

# 既存のプロジェクトセッションに適用
SESSIONS=("project-0-test" "project-1-test" "project-president-test")

for session in "${SESSIONS[@]}"; do
    if tmux has-session -t "$session" 2>/dev/null; then
        sync_env_to_session "$session"
    else
        echo "⚠️  セッション '$session' が見つかりません"
    fi
done

echo ""
echo "🎯 完了！各セッションで新しいウィンドウを作成してClaude Codeを再起動してください。"
echo ""
echo "📝 使用方法："
echo "   tmux new-window -t project-0-test -n new-claude"
echo "   tmux send-keys -t project-0-test:new-claude 'claude' Enter"
