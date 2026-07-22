#!/usr/bin/env bash
# 把一个 JSON 数据文件发布到 GitHub Pages 站点仓库。
# 用法: publish.sh <站点仓库目录> <源json路径> <目标文件名>
# 例:   publish.sh /path/to/dashboard-site /tmp/nav.json nav.json
#
# token 已预存在该仓库的 remote URL 里（见 SETUP.md），本脚本不接触明文 token。
set -euo pipefail

SITE="${1:?缺少站点仓库目录}"
SRC="${2:?缺少源json路径}"
DEST="${3:?缺少目标文件名}"

if [ ! -d "$SITE/.git" ]; then
  echo "❌ $SITE 不是 git 仓库，请先按 SETUP.md 完成克隆与配置" >&2
  exit 1
fi

cp "$SRC" "$SITE/$DEST"
cd "$SITE"

# 先同步远端，避免另一个任务刚推送造成冲突
git pull --rebase --autostash origin main 2>/dev/null || git pull --rebase --autostash origin master 2>/dev/null || true

git add "$DEST"
if git diff --cached --quiet; then
  echo "ℹ️ $DEST 无变化，跳过提交"
  exit 0
fi

git -c user.name="cowork-bot" -c user.email="cowork-bot@local" \
    commit -m "update $DEST @ $(date +'%F %T')"

git push origin HEAD 2>&1 | tail -3
echo "✅ 已发布 $DEST"
