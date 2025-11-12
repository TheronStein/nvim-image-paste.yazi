# nvim-image-paste.yazi

A Yazi plugin for yanking images and pasting them as markdown image links into Neovim.

## Features

- **Smart Image Detection**: Automatically detects image files (png, jpg, jpeg, gif, bmp, svg, webp, ico)
- **Relative Path Generation**: Creates markdown links with relative paths for portability
- **Multiple Image Support**: Yank and paste multiple images at once
- **Neovim Integration**: Seamless integration when Yazi is opened from within Neovim
- **Fallback Behavior**: Falls back to standard paste behavior when not in Neovim context

## Usage

### Yanking Images

1. Navigate to an image file in Yazi
2. Press `y` to yank the image (or select multiple images and yank)
3. Plugin will notify you that the image is ready to paste in Neovim

### Pasting in Neovim

1. Open a markdown file in Neovim
2. Open Yazi from within Neovim (using yazi.nvim or similar)
3. Navigate back to Neovim
4. The plugin will insert markdown image link(s) at cursor position: `![alt-text](relative/path/to/image.png)`

## Installation

### For Development (Recommended for custom plugins)

1. Clone to Yazi dev directory:
   ```bash
   cd ~/.config/yazi/dev/
   git clone https://github.com/yourusername/nvim-image-paste.yazi.git
   ```

2. Add to `package.toml`:
   ```toml
   [[plugin.deps]]
   use = "yourusername/nvim-image-paste"
   ```

3. Load in `init.lua`:
   ```lua
   require("nvim-image-paste"):setup()
   ```

4. Add keybindings in `keymap.toml`:
   ```toml
   [[manager.prepend_keymap]]
   on = ["y"]
   run = "plugin nvim-image-paste --args='yank'"
   desc = "Yank (with image detection)"

   [[manager.prepend_keymap]]
   on = ["p", "p"]
   run = "plugin nvim-image-paste --args='paste'"
   desc = "Paste (smart Neovim markdown integration)"
   ```

## Requirements

- Yazi file manager
- Neovim (when using paste functionality)
- One of the following for Neovim integration:
  - `neovim-remote` (nvr) - recommended
  - Neovim with `NVIM_LISTEN_ADDRESS` set
  - Clipboard tools (xclip, wl-copy, or pbcopy) as fallback

## How It Works

1. **Yank Phase**:
   - Plugin intercepts yank operation
   - Detects if yanked file(s) are images
   - Stores image paths in Yazi state

2. **Paste Phase**:
   - Checks if currently in Neovim context (via environment variables)
   - If in Neovim and images were yanked:
     - Calculates relative paths from current directory
     - Formats as markdown image links
     - Inserts into Neovim at cursor position
   - Otherwise performs normal paste operation

## Development Workflow

This plugin follows the custom Yazi plugin development workflow:

1. **Development**: Edit in `~/.config/yazi/dev/nvim-image-paste.yazi/`
2. **Version Control**: Git repository for tracking changes
3. **Testing**: Reload Yazi to test changes
4. **Distribution**: Push to GitHub and reference in `package.toml`
5. **Updates**: Use `ya pack -u` to pull latest changes

## License

MIT

## Contributing

PRs welcome! Please ensure code follows existing style and patterns.
