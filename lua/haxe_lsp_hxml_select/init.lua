local M = {}

-- Get the path of the current lua script file.
local function script_path()
	local str = debug.getinfo(2, "S").source:sub(2)
	return str:match("(.*/)") or "./"
end

local haxe_lsp_server_path = script_path() .. "../../lsp/haxe_lsp.js"
local current_hxml = nil
local run_on_open = true

-- Get a list of hxml file paths.
-- First look for a .hxml in the current working directory.
-- If not found, search for all .hxml files in the working directory and its subdirectories.
local function get_hxml_path_list()
	local cwd = vim.fn.getcwd()

	-- First check for a .hxml file in the current working directory.
	local path = cwd .. "/.hxml"
	if vim.fn.filereadable(path) == 1 then
		local lines = vim.fn.readfile(path)
		if #lines > 0 then
			return lines
		end
	end

	-- If no .hxml file is found, search for all .hxml files in the directory and its subdirectories.
	local test = vim.fn.expand(cwd .. "/**/*.hxml")
	local paths = {}
	for s in test:gmatch("[^\r\n]+") do
		table.insert(paths, string.sub(s, #cwd + 2))
	end

	if #paths > 0 then
		return paths
	end

	-- Default to build.hxml if no other configuration is found.
	return { "build.hxml" }
end

local function get_first_hxml_path()
	return get_hxml_path_list()[1]
end

--- Show a selection menu to choose an hxml file from the list. When chosen, notify the Haxe LSP of the change.
--- @param client any The LSP client instance.
local function select_hxml_from_list(client)
	local hxml_paths = get_hxml_path_list()
	vim.ui.select(hxml_paths, { prompt = "Select HXML file:", kind = "hxnvim_build" }, function(choice)
		if choice then
			current_hxml = choice
			vim.notify("Selected " .. choice)
			client.notify("haxe/didChangeDisplayArguments", { arguments = { choice } })
		else
			print("No selection made.")
		end
	end)
end

--- Function to run when the Haxe LSP attaches to a buffer.
--- @param client any The LSP client instance.
local function on_attach_haxe_lsp(client)
	vim.api.nvim_create_user_command("SetHxml", function()
		select_hxml_from_list(client)
	end, {})

	if current_hxml == nil and run_on_open then
		select_hxml_from_list(client)
	end
end

function M.setup(opts)
	if opts == nil then
		vim.notify("haxe_lsp_hxml_select: no options provided", vim.log.levels.ERROR)
		return
	end

	if opts.run_on_open == nil then
		vim.notify("haxe_lsp_hxml_select: no 'run_on_open' option provided", vim.log.levels.ERROR)
		return
	end

	run_on_open = opts.run_on_open
	local displayArguments = {}

	-- If we don't run on open, set the displayArguments to the first hxml path.
	if run_on_open == false then
		displayArguments = { get_first_hxml_path() }
	end

	vim.lsp.enable({ "haxe_language_server" })
	vim.lsp.config.haxe_language_server = {
		cmd = { "node", haxe_lsp_server_path },
		filetypes = { "haxe" },
		root_dir = vim.fn.getcwd(),
		init_options = {
			displayArguments = displayArguments,
		},
		settings = {
			haxe = {
				executable = "haxe",
			},
		},
		on_attach = on_attach_haxe_lsp,
	}
end

return M
