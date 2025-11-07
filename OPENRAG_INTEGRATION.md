# Open-rag.ai Integration Guide

This guide explains how to use Unmute with an Open-rag.ai RAG partition instead of a local LLM.

## What is Open-rag.ai?

Open-rag.ai is a RAG (Retrieval-Augmented Generation) solution that exposes AI models with access to custom knowledge bases through an OpenAI-compatible API. Each "partition" represents a specific knowledge base configuration.

## Configuration

### Setup Environment Variables

1. **Copy the example configuration file:**
```bash
cp .env.example .env
```

2. **Edit `.env` with your credentials:**
```bash
KYUTAI_LLM_URL="https://demo.open-rag.ai/v1"
KYUTAI_LLM_MODEL="your-partition-name"
KYUTAI_LLM_API_KEY="your-api-key"
```

The `.env` file is already in `.gitignore` to prevent accidentally committing your credentials.

### Option 1: Docker Compose (Recommended)

Use the provided override file to run Unmute with Open-rag.ai:

```bash
# Make sure HUGGING_FACE_HUB_TOKEN is set for STT/TTS models
export HUGGING_FACE_HUB_TOKEN=hf_...

# Start all services with OpenRAG configuration
docker compose -f docker-compose.yml -f docker-compose.openrag.yml up --build
```

This configuration:
- Configures the backend to use Open-rag.ai instead of local VLLM
- Disables the local LLM service (saves GPU memory)
- Still runs STT and TTS services locally

### Option 2: Dockerless Deployment

If you're running services manually without Docker:

1. **Ensure `.env` is configured** (see Setup Environment Variables above)

2. Start the STT and TTS services as usual:
```bash
./dockerless/start_frontend.sh   # Terminal 1
./dockerless/start_stt.sh        # Terminal 2 - Needs 2.5GB VRAM
./dockerless/start_tts.sh        # Terminal 3 - Needs 5.3GB VRAM
```

3. Start the backend with OpenRAG configuration:
```bash
./dockerless/start_backend_openrag.sh   # Terminal 4
```

The script will automatically load the configuration from `.env`.

**Note**: You do NOT need to run `start_llm.sh` since we're using the external Open-rag.ai API.

## Voice Character

A new voice character "OpenRAG Assistant" has been added to `voices.yaml`. This character:
- Uses a system prompt optimized for RAG-based responses
- Encourages concise, context-aware answers
- Is configured to work well with knowledge base retrieval

You can customize the system prompt in `voices.yaml` to better match your specific RAG partition's capabilities and knowledge domain.

## Benefits of Using Open-rag.ai

1. **No Local LLM GPU Required**: Frees up ~6GB of VRAM since you don't need to run VLLM locally
2. **RAG Capabilities**: Access to custom knowledge bases configured in your Open-rag.ai partition
3. **Scalability**: External API can handle multiple concurrent users without local resource constraints
4. **Updated Knowledge**: Your RAG partition can be updated independently without redeploying Unmute

## Hardware Requirements (with OpenRAG)

Since you're not running the LLM locally:
- **Minimum**: 1 GPU with 8GB VRAM (for STT + TTS combined)
- **Recommended**: 2 GPUs (separate STT and TTS for better latency)
- Significantly lower requirements compared to full local deployment

## Testing the Integration

1. Start the services using one of the methods above
2. Open `http://localhost` (Docker Compose) or `http://localhost:3000` (Dockerless)
3. Select the "OpenRAG Assistant" voice character
4. Start a conversation and verify:
   - Responses are generated correctly
   - The assistant demonstrates knowledge from your RAG partition
   - Latency is acceptable for your use case

## Troubleshooting

### "Connection refused" or API errors
- Verify your credentials in `.env` are correct
- Check that the base URL is accessible: `https://demo.open-rag.ai/v1`
- Ensure your partition name matches your Open-rag.ai configuration
- Make sure the `.env` file exists and is readable

### Backend can't connect to STT/TTS
- Make sure the STT and TTS services are running
- In Docker: services should auto-discover each other
- In Dockerless: check that STT (port 8080) and TTS (port 8080) are accessible

### Slow responses
- This is typically network latency to the Open-rag.ai API
- Consider using a closer deployment region if available
- Check your internet connection speed

## Customization

### Changing Partitions

To use a different Open-rag.ai partition, simply edit the `.env` file:

```bash
KYUTAI_LLM_MODEL="your-partition-name"
```

Then restart the backend service.

### Adjusting System Prompts

Edit `voices.yaml` to create characters optimized for your specific RAG knowledge domain:

```yaml
- name: My Custom RAG Assistant
  good: true
  instructions:
    type: constant
    text: Your custom system prompt here. Mention specific knowledge areas covered by your partition.
  source:
    source_type: file
    path_on_server: unmute-prod-website/your-voice-file.wav
```

## Next Steps

- Experiment with different system prompts to optimize RAG retrieval
- Monitor API usage and latency from Open-rag.ai
- Create multiple voice characters for different knowledge domains
- Consider caching strategies if needed for frequently asked questions
