# Roblox API Reference

Generates reference pages for the Roblox API.

## Files and folders

- `generate`

	Contains the generator script and resources.

- `generate.lua`

	Does all the generating.

- `lua`

	Contains Lua libraries used by generate.lua.

- `resources`

	Contains resource files used in the final output.

	- `css`: CSS files.
	- `images`: Image files.
	- `js`: Javascript files.
	- `templates`: HTML template files. These are parsed by slt2 to generate HTML pages.

## Generating

1. Install [Lua][lua].
2. Make sure your Lua installation has [LuaFileSystem][lfs] and [LuaSockets][sockets].
3. Set your working directory to the `generate` folder.
4. Run `lua generate.lua`. Options are the folders to output to. If the first
   option is `-c` or `--clear`, then each folder will be cleared first.
   Calling no options produces a help message.

[lua]: http://www.lua.org/
[lfs]: http://keplerproject.github.io/luafilesystem/
[sockets]: http://w3.impa.br/~diego/software/luasocket/
