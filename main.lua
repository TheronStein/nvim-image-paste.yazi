--- @sync entry
--- Plugin for yanking images and pasting them into Neovim markdown files
--- When yanking an image, it stores the image path
--- When pasting in Neovim context, it creates a markdown image link

local function is_image(file)
	if not file then return false end
	local ext = file:match("%.([^.]+)$")
	if not ext then return false end
	ext = ext:lower()
	return ext == "png" or ext == "jpg" or ext == "jpeg" or ext == "gif" or
	       ext == "bmp" or ext == "svg" or ext == "webp" or ext == "ico"
end

local function get_relative_path(from, to)
	-- Convert absolute path to relative path
	local from_parts = {}
	local to_parts = {}

	for part in string.gmatch(from, "[^/]+") do
		table.insert(from_parts, part)
	end

	for part in string.gmatch(to, "[^/]+") do
		table.insert(to_parts, part)
	end

	-- Find common prefix
	local common = 0
	for i = 1, math.min(#from_parts, #to_parts) do
		if from_parts[i] == to_parts[i] then
			common = i
		else
			break
		end
	end

	-- Build relative path
	local relative = {}
	for i = common + 1, #from_parts - 1 do -- -1 to exclude the filename
		table.insert(relative, "..")
	end

	for i = common + 1, #to_parts do
		table.insert(relative, to_parts[i])
	end

	if #relative == 0 then
		return to_parts[#to_parts]
	end

	return table.concat(relative, "/")
end

return {
	entry = function(_, args)
		local action = args[1] or "yank"

		if action == "yank" then
			-- Standard yank operation first
			ya.emit("yank", {})

			-- Check if yanked files contain images
			local selected = cx.active.selected
			if #selected == 0 then
				local h = cx.active.current.hovered
				if h and is_image(tostring(h.url)) then
					-- Store image path for later use
					ya.emit("set", { "nvim_image_path", tostring(h.url) })
					ya.notify({
						title = "Image Yanked",
						content = "Image ready to paste in Neovim: " .. h.name,
						timeout = 2,
						level = "info",
					})
				end
			else
				-- Handle multiple selections
				local images = {}
				for _, file in ipairs(selected) do
					if is_image(tostring(file)) then
						table.insert(images, tostring(file))
					end
				end
				if #images > 0 then
					-- Store all image paths
					ya.emit("set", { "nvim_image_paths", table.concat(images, "\n") })
					ya.notify({
						title = "Images Yanked",
						content = #images .. " image(s) ready to paste in Neovim",
						timeout = 2,
						level = "info",
					})
				end
			end

		elseif action == "paste" then
			-- Check if we're in Neovim context
			local nvim_context = os.getenv("NVIM") or os.getenv("NVIM_LISTEN_ADDRESS")

			if nvim_context then
				-- Get stored image path(s)
				local image_path = ya.get("nvim_image_path")
				local image_paths = ya.get("nvim_image_paths")

				if image_path or image_paths then
					-- Get current working directory for relative path calculation
					local cwd = tostring(cx.active.current.cwd)
					local markdown_links = {}

					if image_paths then
						-- Handle multiple images
						for path in string.gmatch(image_paths, "[^\n]+") do
							local name = path:match("([^/]+)$")
							local rel_path = get_relative_path(cwd, path)
							table.insert(markdown_links, string.format("![%s](%s)", name:gsub("%.%w+$", ""), rel_path))
						end
					elseif image_path then
						-- Handle single image
						local name = image_path:match("([^/]+)$")
						local rel_path = get_relative_path(cwd, image_path)
						table.insert(markdown_links, string.format("![%s](%s)", name:gsub("%.%w+$", ""), rel_path))
					end

					if #markdown_links > 0 then
						-- Create a script to paste into Neovim
						local content = table.concat(markdown_links, "\n")
						local cmd = string.format([[nvim --headless --server %s --remote-send '<Esc>i%s<Esc>']],
							nvim_context, content:gsub("'", "'\\''"))

						os.execute(cmd)

						ya.notify({
							title = "Pasted to Neovim",
							content = "Inserted " .. #markdown_links .. " image link(s)",
							timeout = 2,
							level = "info",
						})

						-- Clear stored paths after pasting
						ya.emit("set", { "nvim_image_path", nil })
						ya.emit("set", { "nvim_image_paths", nil })
					end
				else
					-- No images yanked, do normal paste
					ya.emit("paste", {})
				end
			else
				-- Not in Neovim, do normal paste
				local h = cx.active.current.hovered
				if h and h.cha.is_dir then
					ya.emit("enter", {})
					ya.emit("paste", {})
					ya.emit("leave", {})
				else
					ya.emit("paste", {})
				end
			end
		end
	end,
}