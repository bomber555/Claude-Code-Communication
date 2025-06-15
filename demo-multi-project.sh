#!/bin/bash
# demo-multi-project.sh - CCC複数プロジェクト並列稼働デモ

echo "🚀 CCC複数プロジェクト並列稼働アーキテクチャ デモ"
echo "=================================================="
echo ""

# 現在のプロジェクト状況表示
echo "📊 現在のプロジェクト状況:"
./project-manager.sh dashboard
echo ""

# 各プロジェクトで並列に異なる会議を実行
echo "🎪 複数プロジェクトで並列会議開始..."
echo ""

# フロントエンドチーム: スプリント計画会議
echo "💻 フロントエンドチーム: スプリント計画会議"
./project-manager.sh meeting webapp-frontend init "スプリント計画：次期リリースのUI/UX改善" &
FRONTEND_PID=$!

sleep 2

# バックエンドチーム: アーキテクチャレビュー
echo "⚙️  バックエンドチーム: アーキテクチャレビュー" 
./project-manager.sh meeting api-backend init "アーキテクチャレビュー：マイクロサービス分割戦略" &
BACKEND_PID=$!

sleep 2

# MLチーム: モデル評価会議
echo "🧠 機械学習チーム: モデル評価会議"
./project-manager.sh meeting ml-engine init "モデル評価：精度向上とデプロイ戦略" &
ML_PID=$!

echo ""
echo "⏱️  並列会議進行中..."
echo "   - フロントエンドチーム (PID: $FRONTEND_PID)"
echo "   - バックエンドチーム    (PID: $BACKEND_PID)"  
echo "   - 機械学習チーム        (PID: $ML_PID)"
echo ""

# 各プロジェクトで個別のコミュニケーション例
echo "💬 プロジェクト間独立コミュニケーション例："
echo ""

echo "📧 フロントエンドチーム内でのやりとり："
cd ./projects/webapp-frontend
./agent-send.sh boss "UIコンポーネントライブラリの更新が必要です"
./agent-send.sh worker1 "React 18の新機能を検証中です"
./agent-send.sh worker2 "レスポンシブデザインの実装を進めています"
cd ../../

echo ""
echo "📧 バックエンドチーム内でのやりとり："
cd ./projects/api-backend
./agent-send.sh president "API設計のレビューをお願いします"
./agent-send.sh boss "データベース最適化が完了しました"
./agent-send.sh worker1 "認証システムの実装中です"
./agent-send.sh worker2 "ログ機能の改善を検討中です"
cd ../../

echo ""
echo "📧 機械学習チーム内でのやりとり："
cd ./projects/ml-engine
./agent-send.sh president "モデルの精度が95%に達しました"
./agent-send.sh boss "A/Bテストの準備をしています"
./agent-send.sh worker1 "データパイプラインを最適化中です"
cd ../../

sleep 3

echo ""
echo "🔍 プロジェクト別ログ確認："
echo ""

echo "📋 webapp-frontend ログ:"
cat ./projects/webapp-frontend/logs/agent_send.log | tail -5

echo ""
echo "📋 api-backend ログ:"
cat ./projects/api-backend/logs/agent_send.log | tail -5

echo ""
echo "📋 ml-engine ログ:"
cat ./projects/ml-engine/logs/agent_send.log | tail -5

echo ""
echo "🎯 複数プロジェクト並列稼働の利点："
echo "=================================="
echo "✅ 完全独立: プロジェクト間でのコンテキスト混在なし"
echo "✅ 並列実行: 複数チームが同時に独立して作業可能"
echo "✅ 個別管理: プロジェクトごとの開始・停止・設定"
echo "✅ スケーラブル: プロジェクト数に制限なし"
echo "✅ 障害隔離: 一つの問題が他に波及しない"
echo ""

echo "🎪 アタッチ方法："
echo "==============="
echo "各プロジェクトのセッションにアタッチする場合："
echo ""
echo "tmux attach-session -t project-webapp-frontend"
echo "tmux attach-session -t project-api-backend"  
echo "tmux attach-session -t project-ml-engine"
echo ""
echo "または："
echo ""
echo "./project-manager.sh attach webapp-frontend"
echo "./project-manager.sh attach api-backend"
echo "./project-manager.sh attach ml-engine"
echo ""

echo "🎮 操作例："
echo "=========="
echo "# 新しいプロジェクトを作成"
echo "./project-manager.sh create mobile-app \"モバイルアプリ開発\" 5"
echo ""
echo "# 特定プロジェクトを停止"  
echo "./project-manager.sh stop webapp-frontend"
echo ""
echo "# 全体ダッシュボード確認"
echo "./project-manager.sh dashboard"
echo ""

echo "✨ デモ完了！CCC複数プロジェクト並列稼働アーキテクチャが正常に動作しています 🚀"
