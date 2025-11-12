#!/bin/bash

# Script to paste image markdown link to Neovim
# Usage: paste-to-nvim.sh <image_path> <current_dir>

IMAGE_PATH="$1"
CURRENT_DIR="$2"

# Get the image filename without extension for alt text
FILENAME=$(basename "$IMAGE_PATH")
NAME="${FILENAME%.*}"

# Calculate relative path
RELATIVE_PATH=$(realpath --relative-to="$CURRENT_DIR" "$IMAGE_PATH" 2>/dev/null)

# If relative path fails, use absolute path
if [ $? -ne 0 ] || [ -z "$RELATIVE_PATH" ]; then
    RELATIVE_PATH="$IMAGE_PATH"
fi

# Create markdown image link
MARKDOWN_LINK="![$NAME]($RELATIVE_PATH)"

# Check if we're in Neovim
if [ -n "$NVIM" ] || [ -n "$NVIM_LISTEN_ADDRESS" ]; then
    # Send to Neovim using nvr (neovim-remote) if available
    if command -v nvr &> /dev/null; then
        nvr --remote-send "<Esc>i$MARKDOWN_LINK<Esc>"
    elif [ -n "$NVIM_LISTEN_ADDRESS" ]; then
        # Fallback to using nvim --remote-send
        nvim --server "$NVIM_LISTEN_ADDRESS" --remote-send "<Esc>i$MARKDOWN_LINK<Esc>"
    else
        # Last resort: copy to clipboard
        echo -n "$MARKDOWN_LINK" | xclip -selection clipboard 2>/dev/null || \
        echo -n "$MARKDOWN_LINK" | wl-copy 2>/dev/null || \
        echo -n "$MARKDOWN_LINK" | pbcopy 2>/dev/null
        echo "Copied to clipboard: $MARKDOWN_LINK"
    fi
else
    # Not in Neovim, copy to clipboard
    echo -n "$MARKDOWN_LINK" | xclip -selection clipboard 2>/dev/null || \
    echo -n "$MARKDOWN_LINK" | wl-copy 2>/dev/null || \
    echo -n "$MARKDOWN_LINK" | pbcopy 2>/dev/null
    echo "Copied to clipboard: $MARKDOWN_LINK"
fi