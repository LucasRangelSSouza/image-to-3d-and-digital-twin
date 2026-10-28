#!/bin/bash
# Install and run recipe for the image-to-3D tool on a CUDA machine.
# Original harness script, copied unmodified apart from this header. Comments inside may be in Portuguese.
cd /workspace/eco; mkdir -p out/gated /workspace/g; cd /workspace/g
log() { echo "{\"lib\":\"$1\",\"status\":\"$2\",\"note\":\"$3\"}" >> /workspace/eco/out/gated/gated.jsonl; }
export DEBIAN_FRONTEND=noninteractive; apt-get update -qq >/dev/null 2>&1; apt-get install -y -qq git build-essential curl >/dev/null 2>&1
nvidia-smi --query-gpu=name,memory.total --format=csv,noheader; nvcc --version | tail -1
T0=$(date +%s)
pip install -q uv >/dev/null 2>&1
uv venv st310 --python 3.10 -q; . st310/bin/activate
git clone -q --depth 1 https://github.com/Supra-3D/SUPRA-Tex.git st && cd st
export CUDA_HOME=/usr/local/cuda; export PATH=$CUDA_HOME/bin:$PATH
(timeout 2400 python scripts/install_runtime.py > /workspace/eco/out/gated/supra_install.log 2>&1; echo rc=$? >> /workspace/eco/out/gated/supra_install.log)
log supra_tex install "$(tail -2 /workspace/eco/out/gated/supra_install.log | tr '\n' ' ' | cut -c1-200) em $(( $(date +%s)-T0 ))s"
T1=$(date +%s)
(timeout 2400 python scripts/prepare_models.py > /workspace/eco/out/gated/supra_models.log 2>&1; echo rc=$? >> /workspace/eco/out/gated/supra_models.log)
log supra_tex models "$(tail -2 /workspace/eco/out/gated/supra_models.log | tr '\n' ' ' | cut -c1-200) em $(( $(date +%s)-T1 ))s"
python scripts/check_runtime.py > /workspace/eco/out/gated/supra_check.log 2>&1; tail -5 /workspace/eco/out/gated/supra_check.log
S=$(date +%s)
(timeout 2400 python scripts/run_example.py --output outputs/spiny_whelk_shell.glb > /workspace/eco/out/gated/supra_run.log 2>&1; echo rc=$? >> /workspace/eco/out/gated/supra_run.log)
log supra_tex run "$(tail -3 /workspace/eco/out/gated/supra_run.log | tr '\n' ' ' | cut -c1-220) em $(( $(date +%s)-S ))s"
ls -la outputs 2>/dev/null | head; nvidia-smi --query-gpu=memory.used --format=csv,noheader
echo SCRIPT_DONE
