#!/bin/bash

# Toggle if you are using a Claude Max subscription
CLAUDE_MAX=1

# Toggle debugging litellm (values 0,1,2)
DEBUG=0

# Location of litellm config files
# (Update the path to your config.yaml if it is stored elsewhere)
LITELLM_CONFIG_DIR="$HOME/.config/litellm"

LITELLM_CONFIG_FILE="$LITELLM_CONFIG_DIR/config.yaml"
LITELLM_LOG="$LITELLM_CONFIG_DIR/litellm.log"

# 1. Verify your API keys are available and config exists
if [ -z "$OPENROUTER_API_KEY" ]; then
  echo "Error: OPENROUTER_API_KEY environment variable is not set."
  echo "Run 'export OPENROUTER_API_KEY=your_key_here' first."
  exit 1
elif [ -z "$ANTHROPIC_API_KEY" ] && [ $CLAUDE_MAX -ne 1 ]; then
  echo "Error: ANTHROPIC_API_KEY environment variable is not set."
  echo "Run 'export ANTHROPIC_API_KEY=your_key_here' first."
  exit 1
elif [ ! -f "$LITELLM_CONFIG_FILE" ]; then
  echo "Error: Litellm config file not found: $LITELLM_CONFIG_FILE"
  exit 1
fi

echo "Starting LiteLLM proxy..."

# 2. Start LiteLLM in the background and send its output to a log file
if [ $DEBUG -eq 1 ]; then
  litellm --config "$LITELLM_CONFIG_FILE" --port 4000 --debug > "$LITELLM_LOG" 2>&1 &
elif [ $DEBUG -eq 2 ]; then
  litellm --config "$LITELLM_CONFIG_FILE" --port 4000 --detailed_debug > "$LITELLM_LOG" 2>&1 &
else
  litellm --config "$LITELLM_CONFIG_FILE" --port 4000 > "$LITELLM_LOG" 2>&1 &
fi

# 3. Capture the Process ID (PID) of the last background command
LITELLM_PID=$!
echo "LiteLLM running on port 4000 (PID: $LITELLM_PID)"

# 4. Set a trap to kill the proxy automatically whenever this script exits
trap "echo 'Shutting down LiteLLM proxy...'; kill $LITELLM_PID 2>/dev/null" EXIT

# Give the proxy 2 seconds to initialize before Claude tries to connect
sleep 2

# Point Claude to the local proxy
export ANTHROPIC_BASE_URL="http://localhost:4000"

# Use a dummy API key for Claude Max accounts
if [ $CLAUDE_MAX -eq 1 ]; then
  export ANTHROPIC_API_KEY="sk-dummy"
fi

# Run Claude with arguments
#command claude $@
command claude $@

