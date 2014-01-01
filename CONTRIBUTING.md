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

When creating links, consider that the context of the description will be
inside a generated class page. Here are some ways to link to various
things:

- Class pages: `[text](<class-name>.html)`.
- Members on the same page: `[text](#member<member-name>)`.
- Members on other pages: `[text](<class-name>.html#member<member-name>)`.
- Images in the `img` subfolder: `![text](img/<image-name>)`
