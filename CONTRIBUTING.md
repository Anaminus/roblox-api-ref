It is possible to add documentation for classes and members of the API that will be added to the generated result by editing the Markdown files in the `data` folder. The `data` folder contains a `class` folder in which there is a folder called `img`, which can contain images used in documentation, and many Markdown files. To each class can correspond a Markdown file with the same name as the class, but with the `md` file extension, which contains sections delimited by level 1 headers. Sections with these names are detected (they are not case sensitive):

<dl>
	<dt>summary</dt>
	<dd>A short description of the class which will be displayed at the top of the page</dd>
	<dt>details</dt>
	<dd>A longer description of the class, displayed after the list of members</dd>
	<dt>members</dt>
	<dd>Descriptions for members of the class. Each description of a member is in a section delimited by a level 2 header which contains the names of the class (this is case sensitive).</dd>
</dl>

All sections and subsections are optional, and the order of sections and subsections does not matter. Links will be in the context of the page in which they are displayed. Links to different things can be created in these ways:

- Class pages: `[text](<class-name>.html)`.
- Members on the same page: `[text](#member<member-name>)`.
- Members on other pages: `[text](<class-name>.html#member<member-name>)`.
- Images in the `img` subfolder: `![text](img/<image-name>)`
