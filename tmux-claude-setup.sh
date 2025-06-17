# tmux + Claude Code 環境変数自動設定

# ~/.tmux.conf に追加推奨設定
set-environment -g CLAUDE_CODE_USE_BEDROCK 0
set-environment -g CLAUDECODE 1

# 新しいプロジェクトセッション作成用ヘルパー関数
# ~/.zshrc または ~/.bashrc に追加

create_claude_project_session() {
    local project_name=$1
    local project_dir=$2
    
    echo "🚀 Claude Codeプロジェクトセッション作成: $project_name"
    
    # tmuxセッション作成
    tmux new-session -d -s "$project_name" -c "$project_dir"
    
    # 環境変数同期
    tmux set-environment -t "$project_name" CLAUDE_CODE_USE_BEDROCK 0
    tmux set-environment -t "$project_name" ANTHROPIC_MODEL "apac.anthropic.claude-sonnet-4-20250514-v1:0"
    tmux set-environment -t "$project_name" CLAUDECODE 1
    tmux set-environment -t "$project_name" CLAUDE_CODE_ENTRYPOINT mcp
    tmux set-environment -t "$project_name" CLAUDE_CONFIG_DIR "$HOME/.claude"
    
    # MCP Server起動
    tmux send-keys -t "$project_name" "claude mcp serve" Enter
    
    # クライアント用ウィンドウ作成
    tmux new-window -t "$project_name" -n "claude-client"
    tmux send-keys -t "$project_name:claude-client" "claude" Enter
    
    echo "✅ セッション '$project_name' 作成完了"
    echo "📝 接続方法: tmux attach-session -t $project_name"
}

# 使用例:
# create_claude_project_session "new-project" "/path/to/project"
