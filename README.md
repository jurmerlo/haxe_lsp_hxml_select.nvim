# Neovim Haxe LSP Hxml Select Plugin

This is a Neovim plugin that provides a simple interface to select and switch between different Hxml files for Haxe projects. It leverages the built-in LSP capabilities of Neovim to enhance the development experience when working with Haxe.

## Requirements

- [Haxe](https://haxe.org)
- [Node](https://nodejs.org/)

## Installation

You can install this plugin using your favorite Neovim plugin manager. For example, using `lazy.nvim`:

```lua
{
  "jurmerlo/haxe_lsp_hxml_select",
  opts = { run_on_open = true },
}
```

The Haxe node LSP server is included with this plugin, so no additional installation is required, but you can set your own in the configuration if needed.

## Configuration options

- `run_on_open` (boolean): If set to true, the Hxml selector will automatically open the first time a Haxe file is opened.
- `lsp_path`    (string):  Path to the Haxe language server JavaScript file. Defaults to the included `haxe-language-server`.
- `root_dir`    (string):  If you want to specify a custom root directory for searching Hxml files, you can set it here. Defaults to the current working directory.

## Using the Plugin

This plugin searches the current working directory for `*.hxml` files and allows you to select one to use with the Haxe Language Server.

You can also add a `hxml_select` file to the root of your project and list the paths you want to include in the selector.
For example:

```text
hxml/html5.hxml
hxml/windows.hxml
hxml/linux.hxml
```

If `run_on_open` is enabled, the selector will automatically open the first time you open a `.hx` file.  
If disabled the first option in the list will be selected automatically.  
You can also manually trigger the selector using the command: `SetHxml`. This command gets added after you have opened a `.hx` file.
