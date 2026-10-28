#!/bin/bash
# Library sweep session that also installs the image-to-3D tool and OpenVoice.
# Original harness script, copied unmodified apart from this header. Comments inside may be in Portuguese.
cd /workspace/eco; . /venv/main/bin/activate; mkdir -p out/libs3 /workspace/models
log() { echo "{\"lib\":\"$1\",\"status\":\"$2\",\"note\":\"$3\",\"t\":$(date +%s)}" >> out/libs3/libs3.jsonl; }
# ---- AirLLM: Qwen3.8-27B em offload por camadas
T0=$(date +%s)
pip install -q airllm "transformers>=5.8" accelerate > out/libs3/airllm_install.log 2>&1 && log airllm install_ok "$(( $(date +%s)-T0 ))s" || log airllm install_failed "ver airllm_install.log"
cat > airllm_test.py <<'PY'
import time, json, torch
t0=time.time()
from airllm import AutoModel
m=AutoModel.from_pretrained("Qwen/Qwen3.8-27B", max_seq_len=256)
load=time.time()-t0
tok=m.tokenizer
ids=tok(["Explique em duas frases o que e um indice de banco de dados."],return_tensors="pt")
res={}
for n in (8,32):
    t=time.time()
    out=m.generate(ids["input_ids"].cuda(), max_new_tokens=n, use_cache=True, return_dict_in_generate=True)
    dt=time.time()-t
    res[n]={"s":round(dt,1),"tok_s":round(n/dt,3)}
print(json.dumps({"load_s":round(load,1),"res":res,"vram_gb":round(torch.cuda.max_memory_allocated()/2**30,2)}))
PY
timeout 2400 python airllm_test.py > out/libs3/airllm_result.txt 2>&1; log airllm done "$(tail -1 out/libs3/airllm_result.txt | cut -c1-300)"
# ---- OpenVoice v2
T0=$(date +%s)
pip install -q git+https://github.com/myshell-ai/OpenVoice.git melotts > out/libs3/openvoice_install.log 2>&1 && log openvoice install_ok "$(( $(date +%s)-T0 ))s" || log openvoice install_failed "ver openvoice_install.log"
hf download myshell-ai/OpenVoiceV2 --local-dir /workspace/models/openvoicev2 > out/libs3/openvoice_dl.log 2>&1
cat > openvoice_test.py <<'PY'
import time, json, torch, os, glob
from openvoice import se_extractor
from openvoice.api import ToneColorConverter
d="/workspace/models/openvoicev2"
conv=ToneColorConverter(d+"/converter/config.json", device="cuda"); conv.load_ckpt(d+"/converter/checkpoint.pth")
ref=glob.glob("/workspace/eco/out/libs/tts_medio.wav")+glob.glob("/workspace/eco/out/libs3/ref.wav")
if not ref:
    import subprocess; subprocess.run("ffmpeg -y -f lavfi -i 'sine=frequency=220:duration=8' /workspace/eco/out/libs3/ref.wav",shell=True,capture_output=True); ref=["/workspace/eco/out/libs3/ref.wav"]
t=time.time(); tgt,_=se_extractor.get_se(ref[0],conv,vad=False); t_se=time.time()-t
src=ref[0]; res=[]
for i in range(3):
    t=time.time(); conv.convert(audio_src_path=src,src_se=tgt,tgt_se=tgt,output_path="/workspace/eco/out/libs3/ov_out.wav",message="@x"); dt=time.time()-t
    import soundfile as sf; info=sf.info("/workspace/eco/out/libs3/ov_out.wav"); res.append({"s":round(dt,3),"audio_s":round(info.duration,2),"rtf":round(dt/info.duration,3)})
print(json.dumps({"se_extract_s":round(t_se,2),"runs":res}))
PY
timeout 900 python openvoice_test.py > out/libs3/openvoice_result.txt 2>&1; log openvoice done "$(tail -1 out/libs3/openvoice_result.txt | cut -c1-300)"
# ---- SUPRA-Tex (image-to-3D): tentativa de instalacao com limite de tempo
T0=$(date +%s)
git clone -q https://github.com/Supra-3D/SUPRA-Tex.git /workspace/supra > out/libs3/supra_clone.log 2>&1
cd /workspace/supra && (timeout 1500 python scripts/install_runtime.py > /workspace/eco/out/libs3/supra_install.log 2>&1; echo rc=$? >> /workspace/eco/out/libs3/supra_install.log)
cd /workspace/eco; log supra_tex install_attempt "$(tail -3 out/libs3/supra_install.log | tr '\n' ' ' | cut -c1-250) em $(( $(date +%s)-T0 ))s"
echo SCRIPT_DONE
