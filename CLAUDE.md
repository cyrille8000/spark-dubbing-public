# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Spark Dubbing is a video dubbing platform with audio separation capabilities. It uses MVSEP-MDX23 for audio separation (vocals/instruments) and runs on cloud GPU providers (Vast.ai, RunPod).

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Vast.ai / RunPod                        │
│                                                              │
│  onStartupvastai.sh                                          │
│       │                                                      │
│       ▼                                                      │
│  entrypoint.sh ──────► server.py (FastAPI :8185)            │
│                                                              │
│  demucsServe.sh ─────► mvsep/inference_demucs.py            │
│       │                    (audio separation)                │
│       ▼                                                      │
│  Python packages + ML models                                 │
└─────────────────────────────────────────────────────────────┘
```

### Script Chain

1. **onStartupvastai.sh** - Vast.ai startup script, downloads and executes entrypoint.sh
2. **entrypoint.sh** - Downloads server.py/requirements.txt, launches FastAPI server
3. **demucsServe.sh** - Full installation: Python version check, packages, ML models

### Key Components

- **mvsep/** - MVSEP-MDX23 audio separation code (integrated, not cloned)
- **mvsep/inference_demucs.py** - Custom inference script for Demucs
- **server.py** - FastAPI server (port 8185)

## Python Version Support

Supported versions: `39, 310, 311, 312, 313`

If unsupported version detected, `demucsServe.sh` auto-installs Python 3.10.

## External Resources

Models and packages are hosted at:
```
BASE_URL="https://files.dubbingspark.com/b0e526cc7578d1e1986ae652f06fd499e22360f5/d5abd690f1c69f4a889039ddd4aa88d8"
```

Files downloaded:
- `models_part_aa`, `models_part_ab`, `models_part_ac` (ML models)
- `packages_compatibles.zip` (universal Python packages)
- `packages_python{VERSION}.zip` (version-specific wheels)

## Adding New Python Version Support

1. Create wheels package: `packages_python{VERSION}.zip` with structure `temp_packages/python{VERSION}/`
2. Upload to BASE_URL
3. Add version to `SUPPORTED_VERSIONS` in `demucsServe.sh`

Required packages for each Python version:
- numpy, scipy, numba, llvmlite, PyYAML, cffi, charset-normalizer, msgpack, soxr
- onnxruntime-gpu, lameenc (may not be available for newest Python versions)

## Important Paths (on cloud instances)

- `/workspace/spark-dubbing-public/mvsep/` - Main working directory
- `/models-cache/` - ML models cache
- `$HOME/.cache/torch/hub/checkpoints/` - PyTorch model checkpoints
