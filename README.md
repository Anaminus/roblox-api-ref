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

- `data`

	Contains user-generated data about classes. To add data for a specific
	class, create a `.md` file with the name of the class.

	The file is in [Markdown][markdown] format. The contents consist of two
	main sections: a summary, and a description. The summary section should be
	a short and simple description of the class. It will be placed a the top
	of the page. The description section can go into as much detail as
	necessary.

	Both sections are indicated by two level-2 markdown headers named
	"Summary" and "Description" (case-insensitive). The summary header is
	optional, but the description header is required in order to indicate the
	description section. Both sections are optional.

	Images may also be used by including them in the `img` sub-folder.

## Generating

1. Install [Lua][lua].
2. Make sure your Lua installation has [LuaFileSystem][lfs], [LuaSockets][sockets] and [LuaZip][zip].
3. Set your working directory to the `generate` folder.
4. Run `lua generate.lua`. Options are the folders to output to. If the first
   option is `-c` or `--clear`, then each folder will be cleared first.
   Calling no options produces a help message.

[lua]: http://www.lua.org/
[lfs]: http://keplerproject.github.io/luafilesystem/
[sockets]: http://w3.impa.br/~diego/software/luasocket/
[zip]: http://www.keplerproject.org/luazip/
[markdown]: http://daringfireball.net/projects/markdown/
