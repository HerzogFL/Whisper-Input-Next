#!/usr/bin/env bash
# ============================================================
# Whisper-Input-Next 一键安装脚本（macOS / Apple Silicon 优先）
# 做的事：建虚拟环境 + 装依赖 + 克隆并编译 whisper.cpp(Metal) +
#         下载 large-v3-turbo 模型 + 生成 .env 并自动填好本地路径。
# 幂等可重跑：已完成的步骤会自动跳过。
# ============================================================
set -euo pipefail
cd "$(dirname "$0")"
ROOT="$(pwd)"

echo "==> [1/4] 创建虚拟环境 + 安装依赖"
if [ ! -d .venv ]; then
  python3 -m venv .venv
fi
# shellcheck disable=SC1091
source .venv/bin/activate
pip install -q --upgrade pip
pip install -q -r requirements.txt

echo "==> [2/4] 编译 whisper.cpp（本地转写，可选但推荐）"
if [ ! -x whisper.cpp/build/bin/whisper-cli ]; then
  if ! command -v cmake >/dev/null 2>&1; then
    echo "!! 需要 cmake。请先安装： brew install cmake  （没有 Homebrew 就先装 brew）"
    echo "!! 装好 cmake 后重新运行 ./setup.sh"
    exit 1
  fi
  [ -d whisper.cpp ] || git clone --depth 1 https://github.com/ggerganov/whisper.cpp.git
  cmake -S whisper.cpp -B whisper.cpp/build -DGGML_METAL=ON -DWHISPER_BUILD_TESTS=OFF
  cmake --build whisper.cpp/build -j --config Release
else
  echo "    已存在 whisper-cli，跳过编译"
fi

echo "==> [3/4] 下载模型 large-v3-turbo（约 1.5GB）"
if [ ! -f whisper.cpp/models/ggml-large-v3-turbo.bin ]; then
  ( cd whisper.cpp && bash ./models/download-ggml-model.sh large-v3-turbo )
else
  echo "    模型已存在，跳过下载"
fi

echo "==> [4/4] 生成 .env 并自动填入本地路径"
if [ ! -f .env ]; then
  cp env.example .env
  CLI="$ROOT/whisper.cpp/build/bin/whisper-cli"
  python3 - "$CLI" <<'PY'
import re, sys
cli = sys.argv[1]
p = ".env"
s = open(p, encoding="utf-8").read()
s = re.sub(r"^WHISPER_CLI_PATH=.*$", f"WHISPER_CLI_PATH={cli}", s, flags=re.M)
s = re.sub(r"^WHISPER_MODEL_PATH=.*$", "WHISPER_MODEL_PATH=models/ggml-large-v3-turbo.bin", s, flags=re.M)
open(p, "w", encoding="utf-8").write(s)
PY
  echo "    已生成 .env（本地路径已自动填好）"
else
  echo "    .env 已存在，未覆盖"
fi

cat <<'DONE'

============================================================
✅ 安装完成！还差两步（这两步必须手动，无法自动）：

  1) 编辑 .env，填入豆包密钥（用 Ctrl+F 实时流式）：
       DOUBAO_APP_KEY=...        # 火山引擎「语音技术」控制台
       DOUBAO_ACCESS_KEY=...
     （只想用本地离线 Ctrl+I 的话，这步可跳过。）

  2) 启动：
       source .venv/bin/activate
       python main.py
     首次运行 macOS 会要求授予「辅助功能」+「麦克风」权限，
     授权后完全退出终端再重开一次即可。

  用法： Ctrl+F = 豆包实时流式   |   Ctrl+I = 本地离线（免费）
============================================================
DONE
