#!/bin/bash
# project-manager.sh - CCC複数プロジェクト管理システム

PROJECT_BASE_DIR="./projects"
GLOBAL_LOG="./logs/global_projects.log"

# デフォルトプロジェクト一覧（通常の配列形式で定義）
DEFAULT_PROJECT_IDS=("webapp-a" "ai-model-b" "mobile-c" "api-platform-d")
DEFAULT_PROJECT_NAMES=("Webアプリケーション開発チーム" "AIモデル研究チーム" "モバイルアプリ開発チーム" "APIプラットフォームチーム")

function get_default_project_name() {
    local project_id="$1"
    case "$project_id" in
        "webapp-a") echo "Webアプリケーション開発チーム" ;;
        "ai-model-b") echo "AIモデル研究チーム" ;;
        "mobile-c") echo "モバイルアプリ開発チーム" ;;
        "api-platform-d") echo "APIプラットフォームチーム" ;;
        *) echo "$project_id" ;;
    esac
}

function create_project() {
    local project_id="$1"
    local project_name="$2"
    local team_size="${3:-3}"  # デフォルト3人
    
    echo "🚀 プロジェクト作成: $project_id ($project_name)"
    
    # プロジェクトディレクトリ作成
    mkdir -p "$PROJECT_BASE_DIR/$project_id"/{logs,tmp,artifacts}
    
    # プロジェクト固有のセッション作成
    echo "📊 tmuxセッション作成: project-$project_id"
    tmux new-session -d -s "project-$project_id"
    
    # president専用ペイン（management ウィンドウ）
    tmux rename-window -t "project-$project_id":0 "management"
    tmux send-keys -t "project-$project_id:management.0" "# president-$project_id workspace" C-m
    
    # チーム用ウィンドウ作成（boss + workers）
    tmux new-window -t "project-$project_id" -n "team"
    
    # 最初のペインはboss用
    tmux send-keys -t "project-$project_id:team.0" "# boss-$project_id workspace" C-m
    
    # worker用ペイン分割
    for i in $(seq 2 $((team_size + 1))); do
        if [ $i -eq 2 ]; then
            tmux split-window -t "project-$project_id:team" -h
        else
            tmux split-window -t "project-$project_id:team" -v
        fi
        tmux send-keys -t "project-$project_id:team.$((i-1))" "# worker-$project_id-$((i-1)) workspace" C-m
    done
    
    # ペインのレイアウトを調整
    tmux select-layout -t "project-$project_id:team" tiled
    
    # プロジェクト設定ファイル作成
    cat > "$PROJECT_BASE_DIR/$project_id/project.conf" << EOF
PROJECT_ID="$project_id"
PROJECT_NAME="$project_name"
TEAM_SIZE=$team_size
SESSION_NAME="project-$project_id"
CREATED_DATE="$(date)"
STATUS="active"
LAST_UPDATED="$(date)"
EOF
    
    # プロジェクト固有のagent-send.sh作成
    create_project_agent_script "$project_id" "$team_size"
    
    # 専用会議システム作成
    create_project_meeting_system "$project_id"
    
    # プロジェクト固有のClaude起動スクリプト作成
    create_claude_startup_script "$project_id" "$team_size"
    
    echo "✅ プロジェクト $project_id 作成完了"
    echo "📍 セッション: project-$project_id"
    echo "📁 ディレクトリ: $PROJECT_BASE_DIR/$project_id"
    echo ""
    echo "🚀 次のステップ:"
    echo "  1. tmux attach-session -t project-$project_id"
    echo "  2. ./projects/$project_id/start-claude.sh"
    echo "  3. ./projects/$project_id/meeting-chair.sh init \"会議開始\""
}

function create_project_agent_script() {
    local project_id="$1"
    local team_size="$2"
    local script_path="$PROJECT_BASE_DIR/$project_id/agent-send.sh"
    
    cat > "$script_path" << EOF
#!/bin/bash
# プロジェクト$project_id 固有のagent-send.sh

PROJECT_ID="$project_id"
SESSION_NAME="project-\$PROJECT_ID"
TEAM_SIZE=$team_size

function send_to_agent() {
    local agent="\$1"
    local message="\$2"
    local timestamp=\$(date '+%H:%M:%S')
    
    case "\$agent" in
        "president")
            tmux send-keys -t "\$SESSION_NAME:management.0" "\$message" C-m
            ;;
        "boss")
            tmux send-keys -t "\$SESSION_NAME:team.0" "\$message" C-m
            ;;
        worker*)
            local worker_num=\${agent#worker}
            if [[ "\$worker_num" =~ ^[0-9]+\$ ]] && [ "\$worker_num" -le "\$TEAM_SIZE" ]; then
                tmux send-keys -t "\$SESSION_NAME:team.\$worker_num" "\$message" C-m
            else
                echo "❌ 無効なworker番号: \$worker_num (1-\$TEAM_SIZE まで有効)"
                return 1
            fi
            ;;
        *)
            echo "❌ 無効なエージェント名: \$agent"
            echo "有効なエージェント: president, boss, worker1-worker\$TEAM_SIZE"
            return 1
            ;;
    esac
    
    # ログ記録
    mkdir -p "./logs"
    echo "[\$timestamp] \$agent <- \$message" >> "./logs/agent_send.log"
    echo "✅ メッセージ送信完了: \$agent"
}

function list_agents() {
    echo "📋 プロジェクト $project_id のエージェント一覧:"
    echo "  - president"
    echo "  - boss"
    for i in \$(seq 1 \$TEAM_SIZE); do
        echo "  - worker\$i"
    done
}

# メイン実行部
case "\$1" in
    "--list")
        list_agents
        ;;
    *)
        if [[ \$# -lt 2 ]]; then
            echo "使用方法: \$0 <agent> <message>"
            echo "          \$0 --list"
            echo ""
            list_agents
            exit 1
        fi
        send_to_agent "\$1" "\$2"
        ;;
esac
EOF
    
    chmod +x "$script_path"
}

function create_project_meeting_system() {
    local project_id="$1"
    local meeting_script="$PROJECT_BASE_DIR/$project_id/meeting-chair.sh"
    
    # ベースの会議システムをコピー
    cp "./ccc-meeting-chair.sh" "$meeting_script"
    
    # プロジェクト固有設定に変更
    sed -i '' "s/LEADER=\"boss1\"/LEADER=\"boss\"/" "$meeting_script"
    sed -i '' "s/OBSERVER=\"president\"/OBSERVER=\"president\"/" "$meeting_script"
    
    # PARTICIPANTS配列をチームサイズに応じて動的生成するよう変更
    cat >> "$meeting_script" << 'EOF'

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
EOF
    
    chmod +x "$meeting_script"
}

function create_claude_startup_script() {
    local project_id="$1"
    local team_size="$2"
    local startup_script="$PROJECT_BASE_DIR/$project_id/start-claude.sh"
    
    cat > "$startup_script" << EOF
#!/bin/bash
# プロジェクト $project_id のClaude Code一括起動スクリプト

PROJECT_ID="$project_id"
SESSION_NAME="project-\$PROJECT_ID"

echo "🚀 プロジェクト \$PROJECT_ID でClaude Code起動中..."

# president起動
echo "📊 president起動中..."
tmux send-keys -t "\$SESSION_NAME:management.0" 'claude' C-m

sleep 2

# boss起動
echo "👔 boss起動中..."
tmux send-keys -t "\$SESSION_NAME:team.0" 'claude' C-m

sleep 1

# workers起動
for i in \$(seq 1 $team_size); do
    echo "👷 worker\$i 起動中..."
    tmux send-keys -t "\$SESSION_NAME:team.\$i" 'claude' C-m
    sleep 1
done

echo "✅ プロジェクト \$PROJECT_ID の全エージェントでClaude Code起動完了！"
echo ""
echo "📋 次のステップ:"
echo "  - tmux attach-session -t \$SESSION_NAME  # セッションに接続"
echo "  - ./meeting-chair.sh init \"会議開始\"      # 会議システム起動"
echo "  - ./agent-send.sh --list               # エージェント一覧確認"
EOF
    
    chmod +x "$startup_script"
}

function start_all_projects() {
    echo "🚀 全プロジェクト開始..."
    
    for project_id in "${DEFAULT_PROJECT_IDS[@]}"; do
        if tmux has-session -t "project-$project_id" 2>/dev/null; then
            echo "✅ プロジェクト $project_id は既に実行中"
        else
            echo "🔄 プロジェクト $project_id を開始..."
            local project_name=$(get_default_project_name "$project_id")
            create_project "$project_id" "$project_name"
        fi
    done
}

function stop_project() {
    local project_id="$1"
    
    if [ -z "$project_id" ]; then
        echo "❌ プロジェクトIDを指定してください"
        return 1
    fi
    
    echo "🛑 プロジェクト停止: $project_id"
    
    if tmux has-session -t "project-$project_id" 2>/dev/null; then
        tmux kill-session -t "project-$project_id"
        echo "✅ tmuxセッション project-$project_id を停止しました"
    else
        echo "⚠️  セッション project-$project_id は既に停止済みです"
    fi
    
    # プロジェクト状態更新
    if [ -f "$PROJECT_BASE_DIR/$project_id/project.conf" ]; then
        sed -i '' 's/STATUS="active"/STATUS="stopped"/' "$PROJECT_BASE_DIR/$project_id/project.conf"
        sed -i '' "s/LAST_UPDATED=.*/LAST_UPDATED=\"$(date)\"/" "$PROJECT_BASE_DIR/$project_id/project.conf"
    fi
    
    echo "✅ プロジェクト $project_id 停止完了"
}

function list_projects() {
    echo "📋 プロジェクト一覧:"
    echo "==================="
    
    if [ ! -d "$PROJECT_BASE_DIR" ]; then
        echo "プロジェクトがまだ作成されていません。"
        echo ""
        echo "デフォルトプロジェクト一覧:"
        for project_id in "${!DEFAULT_PROJECTS[@]}"; do
            echo "  - $project_id: ${DEFAULT_PROJECTS[$project_id]}"
        done
        return
    fi
    
    for project_dir in "$PROJECT_BASE_DIR"/*; do
        if [ -d "$project_dir" ]; then
            local project_id=$(basename "$project_dir")
            local status="❌ 停止中"
            
            if tmux has-session -t "project-$project_id" 2>/dev/null; then
                status="✅ 実行中"
            fi
            
            echo "$status $project_id"
            
            # 詳細情報表示
            if [ -f "$project_dir/project.conf" ]; then
                local project_name=$(grep "PROJECT_NAME" "$project_dir/project.conf" | cut -d'"' -f2)
                local team_size=$(grep "TEAM_SIZE" "$project_dir/project.conf" | cut -d'=' -f2)
                local created_date=$(grep "CREATED_DATE" "$project_dir/project.conf" | cut -d'"' -f2)
                
                echo "   📝 $project_name"
                echo "   👥 チームサイズ: $team_size"
                echo "   📅 作成日: $created_date"
            fi
            echo ""
        fi
    done
}

function project_dashboard() {
    echo "🖥️  CCC複数プロジェクト ダッシュボード"
    echo "======================================"
    echo ""
    
    list_projects
    
    # 統計情報
    local total_projects=0
    local running_count=0
    
    if [ -d "$PROJECT_BASE_DIR" ]; then
        for project_dir in "$PROJECT_BASE_DIR"/*; do
            if [ -d "$project_dir" ]; then
                local project_id=$(basename "$project_dir")
                ((total_projects++))
                
                if tmux has-session -t "project-$project_id" 2>/dev/null; then
                    ((running_count++))
                fi
            fi
        done
    fi
    
    echo "📊 全体統計:"
    echo "-------------"
    echo "総プロジェクト数: $total_projects"
    echo "実行中: $running_count"
    echo "停止中: $((total_projects - running_count))"
    echo ""
    
    echo "🔧 管理コマンド:"
    echo "--------------"
    echo "./project-manager.sh create <project-id> <project-name> [team-size]"
    echo "./project-manager.sh start <project-id>"
    echo "./project-manager.sh stop <project-id>"  
    echo "./project-manager.sh restart <project-id>"
    echo "./project-manager.sh attach <project-id>"
    echo "./project-manager.sh meeting <project-id> <command> [args...]"
}

function attach_to_project() {
    local project_id="$1"
    
    if [ -z "$project_id" ]; then
        echo "❌ プロジェクトIDを指定してください"
        list_projects
        return 1
    fi
    
    if ! tmux has-session -t "project-$project_id" 2>/dev/null; then
        echo "❌ プロジェクト $project_id が見つかりません"
        echo ""
        echo "実行中のプロジェクト一覧:"
        list_projects
        return 1
    fi
    
    echo "📎 プロジェクト $project_id にアタッチします..."
    tmux attach-session -t "project-$project_id"
}

function start_project_meeting() {
    local project_id="$1"
    shift
    local meeting_script="$PROJECT_BASE_DIR/$project_id/meeting-chair.sh"
    
    if [ ! -f "$meeting_script" ]; then
        echo "❌ プロジェクト $project_id の会議システムが見つかりません"
        echo "先に ./project-manager.sh create $project_id を実行してください"
        return 1
    fi
    
    echo "🎤 プロジェクト $project_id の会議システムを起動..."
    cd "$PROJECT_BASE_DIR/$project_id"
    bash "./meeting-chair.sh" "$@"
}

# メイン実行部
case "$1" in
    "create")
        if [ $# -lt 3 ]; then
            echo "使用方法: $0 create <project-id> <project-name> [team-size]"
            echo "例: $0 create webapp-frontend \"フロントエンド開発\" 4"
            exit 1
        fi
        create_project "$2" "$3" "$4"
        ;;
    "start")
        if [ -z "$2" ]; then
            start_all_projects
        else
            if [ ! -d "$PROJECT_BASE_DIR/$2" ]; then
                echo "❌ プロジェクト $2 が存在しません"
                echo "先に create で作成してください"
                exit 1
            fi
            
            if tmux has-session -t "project-$2" 2>/dev/null; then
                echo "⚠️  プロジェクト $2 は既に実行中です"
            else
                # 既存プロジェクトを再起動
                source "$PROJECT_BASE_DIR/$2/project.conf"
                create_project "$PROJECT_ID" "$PROJECT_NAME" "$TEAM_SIZE"
            fi
        fi
        ;;
    "stop")
        stop_project "$2"
        ;;
    "restart")
        if [ -z "$2" ]; then
            echo "❌ プロジェクトIDを指定してください"
            exit 1
        fi
        echo "🔄 プロジェクト $2 を再起動します..."
        stop_project "$2"
        sleep 2
        if [ -f "$PROJECT_BASE_DIR/$2/project.conf" ]; then
            source "$PROJECT_BASE_DIR/$2/project.conf"
            create_project "$PROJECT_ID" "$PROJECT_NAME" "$TEAM_SIZE"
        fi
        ;;
    "list")
        list_projects
        ;;
    "dashboard")
        project_dashboard
        ;;
    "attach")
        attach_to_project "$2"
        ;;
    "meeting")
        if [ -z "$2" ]; then
            echo "❌ プロジェクトIDを指定してください"
            exit 1
        fi
        start_project_meeting "$2" "${@:3}"
        ;;
    *)
        echo "🚀 CCC 複数プロジェクト管理システム"
        echo ""
        echo "使用方法:"
        echo "  $0 create <project-id> <project-name> [team-size]  # 新規プロジェクト作成"
        echo "  $0 start [project-id]                             # プロジェクト開始（全体 or 個別）"
        echo "  $0 stop <project-id>                              # プロジェクト停止"
        echo "  $0 restart <project-id>                           # プロジェクト再起動"
        echo "  $0 list                                           # プロジェクト一覧"
        echo "  $0 dashboard                                      # ダッシュボード表示"
        echo "  $0 attach <project-id>                            # セッションアタッチ"
        echo "  $0 meeting <project-id> <command> [args...]        # 会議システム"
        echo ""
        echo "例:"
        echo "  $0 create webapp-frontend \"フロントエンド開発\" 4   # 4人チームで作成"
        echo "  $0 start webapp-frontend                         # プロジェクト開始"
        echo "  $0 attach webapp-frontend                        # セッションに接続"
        echo "  $0 meeting webapp-frontend init \"デイリースタンドアップ\"  # 会議開始"
        echo ""
        echo "🎯 デフォルトプロジェクト:"
        for project_id in "${DEFAULT_PROJECT_IDS[@]}"; do
            echo "  - $project_id: $(get_default_project_name "$project_id")"
        done
        ;;
esac
