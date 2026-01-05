#!/bin/bash
# Instalar dependencias del sistema
sudo apt-get update -qq
sudo apt-get install -qq -y ffmpeg libsndfile1 build-essential python3.10-venv python3.10-dev aria2

# Crear entorno virtual
python3.10 -m venv rvc-venv
source rvc-venv/bin/activate

# Actualizar pip
pip install --upgrade pip==23.1.2 setuptools<=80.6.0 wheel

# Instalar PyTorch con CUDA 12.1
pip install torch==2.3.1+cu121 torchaudio==2.3.1+cu121 torchvision==0.18.1+cu121 -f https://download.pytorch.org/whl/cu121

# Instalar resto de dependencias
pip install -r requirements.txt

# Descargar archivos críticos
mkdir -p logs/mute
wget -O hubert_base.pt https://huggingface.co/lj1995/VoiceConversionWebUI/resolve/main/hubert_base.pt
wget -O rmvpe.pt https://huggingface.co/lj1995/VoiceConversionWebUI/resolve/main/rmvpe.pt
wget -O logs/mute/0_gt_wavs/mute40k.wav https://huggingface.co/Kit-Lemonfoot/RVC_DidntAsk/resolve/main/mute/0_gt_wavs/mute40k.wav
wget -O logs/mute/3_feature768/mute.npy https://huggingface.co/Kit-Lemonfoot/RVC_DidntAsk/resolve/main/mute/3_feature768/mute.npy
wget -O logs/mute/2a_f0/mute.wav.npy https://huggingface.co/Kit-Lemonfoot/RVC_DidntAsk/resolve/main/mute/2a_f0/mute.wav.npy
wget -O logs/mute/2b-f0nsf/mute.wav.npy https://huggingface.co/Kit-Lemonfoot/RVC_DidntAsk/resolve/main/mute/2b-f0nsf/mute.wav.npy