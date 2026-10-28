#!/bin/bash
# Variant that keeps the produced artifacts and the full run log.
# Original harness script, copied unmodified apart from this header. Comments inside may be in Portuguese.
# SUPRA-Tex em GPU Ada (4090) salvando os ARTEFATOS (GLB, entrada, recibo) para evidencia.
cd /workspace/eco
ITEMS="supra" bash /workspace/eco/run_all.sh 2>&1 | grep -v SCRIPT_DONE | tail -3
mkdir -p out/all/supra_art
ST=/workspace/g/st
cp $ST/outputs/*.glb out/all/supra_art/ 2>/dev/null
find $ST/outputs -type f -size -6M \( -name "*.json" -o -name "*.png" -o -name "*.jpg" -o -name "*.txt" -o -name "*.md" \) -exec cp --parents {} out/all/supra_art/ \; 2>/dev/null
find $ST -maxdepth 3 -type f \( -iname "*example*.png" -o -iname "*example*.jpg" -o -iname "spiny*" \) -size -6M -exec cp {} out/all/supra_art/ \; 2>/dev/null
ls -la out/all/supra_art | head -20
nvidia-smi --query-gpu=name,driver_version --format=csv,noheader > out/all/supra_art/gpu.txt
echo SCRIPT_DONE
