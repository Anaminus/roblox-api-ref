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

	The file is in [Markdown][markdown] format. The contents consist of
	sections delimited by level-1 headers. The following sections are
	detected (case *in*sensitive):

	- `summary`: A short and simple description of the class. Displayed at the top of the page.
	- `details`: A long, detailed description of the class. Displayed after member lists.
	- `members`: Descriptions for each member of the class.

	The members section is further divided into subsections; one for each
	member of the class. Each subsection is delimited by a level-2 header,
	with the name of the member as the header name (case sensitive).

	Content within a subsection will be included in the member description for
	that particular member.

	All sections and subsections are optional. No content will be displayed
	for a particular section if its description is missing. Only the summary
	and details sections will be included. Only descriptions for members that
	exist in the class will be included. The order of each section or
	subsection does not matter.

	Images may be used by including them in the `img` sub-folder.


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
