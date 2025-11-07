#!/bin/bash
set -ex
cd "$(dirname "$0")/.."

# Load Open-rag.ai configuration from .env file
if [ -f ".env" ]; then
    echo "Loading Open-rag.ai configuration from .env"
    set -a  # automatically export all variables
    source .env
    set +a
else
    echo "Error: .env file not found!"
    echo "Please copy .env.example to .env and configure your credentials"
    exit 1
fi

# Start the backend with the OpenRAG configuration
uv run uvicorn unmute.main_websocket:app --reload --host 0.0.0.0 --port 8000 --ws-per-message-deflate=false
