#!/bin/bash
set -e

echo "🔧 Agregando repositorio de Python 3.10..."
add-apt-repository ppa:deadsnakes/ppa -y >/dev/null 2>&1

echo "📦 Instalando dependencias del sistema..."
apt-get update -qq
apt-get install -qq -y \
    ffmpeg libsndfile1 build-essential \
    python3.10 python3.10-venv python3.10-dev \
    aria2 sox

echo "🐍 Creando entorno virtual con Python 3.10..."
python3.10 -m venv rvc-env
source rvc-env/bin/activate

echo "⬆️ Actualizando pip y setuptools..."
pip install --upgrade pip==23.1.2 "setuptools<=80.6.0" wheel

# 🔥 CORRECCIÓN CLAVE: instalar torch con el índice correcto ANTES de requirements.txt
echo "📦 Instalando PyTorch con CUDA 12.1 desde el índice oficial..."
pip install torch==2.3.1+cu121 torchaudio==2.3.1+cu121 torchvision==0.18.1+cu121 \
    --index-url https://download.pytorch.org/whl/cu121 --quiet

# Ahora instalar el resto SIN torch en requirements.txt
echo "📦 Instalando resto de dependencias..."
# Crear un requirements sin torch
cat > temp-requirements.txt << EOF
fairseq==0.12.2
faiss-cpu==1.7.3
numpy==1.23.5
numba==0.56.4
librosa==0.9.2
praat-parselmouth==0.4.3
pyworld==0.3.4
ffmpeg-python>=0.2.0
scipy==1.10.1
scikit-learn==1.2.2
matplotlib==3.7.0
tensorboard==2.16.2
tqdm==4.66.2
tensorboardX==2.6.2.2
onnxruntime==1.18.0
noisereduce==3.0.0
sox==1.4.1
EOF

pip install -r temp-requirements.txt --quiet
rm temp-requirements.txt

echo "⬇️ Descargando archivos esenciales..."
mkdir -p logs/mute/0_gt_wavs logs/mute/3_feature768 logs/mute/2a_f0 logs/mute/2b-f0nsf

aria2c --console-log-level=error -x 8 -s 8 -k 1M \
    https://huggingface.co/lj1995/VoiceConversionWebUI/resolve/main/hubert_base.pt \
    -d . -o hubert_base.pt

aria2c --console-log-level=error -x 8 -s 8 -k 1M \
    https://huggingface.co/lj1995/VoiceConversionWebUI/resolve/main/rmvpe.pt \
    -d . -o rmvpe.pt

aria2c --console-log-level=error -x 4 -s 4 -k 1M \
    https://huggingface.co/Kit-Lemonfoot/RVC_DidntAsk/resolve/main/mute/0_gt_wavs/mute40k.wav \
    -d logs/mute/0_gt_wavs -o mute40k.wav

aria2c --console-log-level=error -x 4 -s 4 -k 1M \
    https://huggingface.co/Kit-Lemonfoot/RVC_DidntAsk/resolve/main/mute/3_feature768/mute.npy \
    -d logs/mute/3_feature768 -o mute.npy

aria2c --console-log-level=error -x 4 -s 4 -k 1M \
    https://huggingface.co/Kit-Lemonfoot/RVC_DidntAsk/resolve/main/mute/2a_f0/mute.wav.npy \
    -d logs/mute/2a_f0 -o mute.wav.npy

aria2c --console-log-level=error -x 4 -s 4 -k 1M \
    https://huggingface.co/Kit-Lemonfoot/RVC_DidntAsk/resolve/main/mute/2b-f0nsf/mute.wav.npy \
    -d logs/mute/2b-f0nsf -o mute.wav.npy

echo "✅ Configuración completada."
