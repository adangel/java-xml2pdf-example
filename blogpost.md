# Using XSL-FO and Apache FOP to create PDF"

(Blog Post original published at: <https://adangel.org/2023/02/19/create-pdf-with-xsl-fo/>)

The goal is to create a PDF document with a title page, a table of contents and some pages. The title
page should include a image of a logo. The pages should have a footer with the page number on it.
And all of this should be possible to be integrated into a existing standalone java program without
calling an external process.

As the title already suggests, the solution is Apache FOP, which can also be used as a library.

## XSL and XSL-FO

But let's start at the beginning. A long time ago, in 1999, the standard XSLT (Extensible Stylesheet Language
Transformations) has been published by W3C. It is used to transform one XML format into another XML format.
XSLT was defined in a project called XSL (Extensible Stylesheet Language) which also developed XPath, a query
language for XML documents, that is used in XSLT stylesheets. And it developed XSL-FO (XSL Formatting Objects).

With XSL-FO, one can convert a XML document into e.g. PDF by using a so-called FO formatter. XSL-FO itself is a
XML format, the describes how a document should be rendered on a page. The last version of XSL-FO is 1.1 which
was released in 2006. It is considered to be feature complete and is not developed any further.

The standard can be retrieved at <https://www.w3.org/TR/xsl11/>.

## Apache FOP

As mentioned above, one needs a formatting objects formatter, to generate a PDF document out of a XML document.
And that's what [Apache FOP](https://xmlgraphics.apache.org/fop/) is. It actually supports other output formats
than PDF as well.

The general approach here is to have a XML document ("source"), then a XSL stylesheet, that transforms the source
into XML-FO, and that is rendered into PDF.

The project also provides some examples, like
[simple.fo](https://github.com/apache/xmlgraphics-fop/blob/trunk/fop/examples/fo/basic/simple.fo).
These examples are also included in the binary distribution of Apache FOP. You can execute these examples
by running `./fop examples/fo/basic/simple.fo simple.pdf`.

The project web page also provides various guides, e.g. on
[Embedding FOP into Java applications](https://xmlgraphics.apache.org/fop/2.8/embedding.html).

## Structure of XSL-FO

When we want to transform our (yet to be defined XML format) into XSL-FO, we should first figure out, how
a formatting objects document is structured. It's for sure XML. And as always in XML, the basic structure
is a tree. It is a tree of formatting objects. The root element is `fo:root`. It must contain the element
`fo:layout-master-set` - this defines the page size on which the objects are rendered.
Then it also must contain one or more `fo:page-sequence`. This element contains exactly one `fo:flow`, which
contain the actual objects like `fo:block`. All the objects in a flow a rendered one after another on as
many pages as needed.

The minimal "Hello world" example looks like this:

```xml
<?xml version="1.0" encoding="utf-8"?>
<fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">
    <fo:layout-master-set>
        <fo:simple-page-master master-name="A4-portrait"
                page-height="29.7cm" page-width="21.0cm" margin="2cm">
            <fo:region-body/>
        </fo:simple-page-master>
    </fo:layout-master-set>
    <fo:page-sequence master-reference="A4-portrait">
        <fo:flow flow-name="xsl-region-body">
            <fo:block>
                Hello, World!
            </fo:block>
        </fo:flow>
    </fo:page-sequence>
</fo:root>
```

## Some styling

Let's see how we can achieve the basic styling effects.

### Headings

Headings use usually bigger font sizes, maybe even different fonts. Let's use a sans-serif font for the heading,
18pt size:

```xml
<fo:block font-family="sans-serif" font-size="18pt" font-weight="bold" padding-bottom="5pt">This is a heading</fo:block>
```

### Inline styles like italic, bold, underline

If we don't want to have the complete block in italic but e.g. a single word, this is done by `fo:inline`:

```xml
<fo:block font-family="serif" font-size="12pt">This word is in
    <fo:inline font-style="italic">italic</fo:inline> and others are
    <fo:inline font-weight="bold">bold</fo:inline>.
    You can also <fo:inline text-decoration="underline">underline</fo:inline> some text.
</fo:block>
```

You can even use colors:

```xml
<fo:block>This is <fo:inline color="red">red</fo:inline>.</fo:block>
```

### Lists

Lists are directly supported, but more verbose compared to HTML:

```xml
<fo:list-block>
    <fo:list-item>
        <fo:list-item-label start-indent="5mm" end-indent="label-end()">
            <fo:block>1.</fo:block>
        </fo:list-item-label>
        <fo:list-item-body start-indent="body-start() + 2mm">
            <fo:block>This is the first item.</fo:block>
        </fo:list-item-body>
    </fo:list-item>

    <fo:list-item>
        <fo:list-item-label start-indent="5mm" end-indent="label-end()">
            <fo:block>•</fo:block>
        </fo:list-item-label>
        <fo:list-item-body start-indent="body-start() + 2mm">
            <fo:block>This is the second item using U+2022 as bullet point.</fo:block>
        </fo:list-item-body>
    </fo:list-item>
</fo:list-block>
```

As you see, you can also use simple expressions (`+ 2mm`).

### Including images

Images can be included with `fo:external-graphic`:

```xml
<fo:block>
    <fo:external-graphic src="apache-fop-logo.jpg"/>
</fo:block>
```

Note: The sample image is from <https://xmlgraphics.apache.org/images/apache-fop-logo.jpg>.



## The document

So far, so good. Now let's define the XML document, that we want to process into a PDF.

```xml
<?xml version="1.0" encoding="utf-8"?>
<doc>
    <title>This is the title for the title page</title>
    <author>Jon Doe</author>
    <content>
        <heading>This is a heading</heading>
        <paragraph>
            This is a text block. It might contain <emph>some</emph> styles.
        </paragraph>
        <paragraph>
            Second paragraph.
        </paragraph>
        <heading>Another heading</heading>
        <paragraph>
            Lorem ipsum.
        </paragraph>
    </content>
</doc>
```

Pretty simple.

## The XSL stylesheet

The task now is to create a stylesheet, that produces out of this document a XML-FO document,
that Apache FOP can render into a PDF document.

Let's start simple:

<details>
    <summary>The initial XSL stylesheet - expand...</summary>
    <pre><code class="language-xml">{{ '<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
      xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
      xmlns:fo="http://www.w3.org/1999/XSL/Format">
    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="/">
        <fo:root>
            <fo:layout-master-set>
                <fo:simple-page-master master-name="A4-portrait"
                    page-height="29.7cm" page-width="21.0cm" margin="2cm">
                    <fo:region-body/>
                </fo:simple-page-master>
            </fo:layout-master-set>
            <fo:page-sequence master-reference="A4-portrait">
                <fo:flow flow-name="xsl-region-body">
                    <xsl:apply-templates/>
                </fo:flow>
            </fo:page-sequence>
        </fo:root>
    </xsl:template>


    <xsl:template match="title">
        <fo:block font-size="20pt" font-weight="bold" font-family="sans-serif" text-align="center">
            <xsl:value-of select="."/>
        </fo:block>
    </xsl:template>

    <xsl:template match="author">
        <fo:block font-size="12pt" font-family="serif" text-align="center">
            <xsl:value-of select="."/>
        </fo:block>
        <fo:block text-align="center">
            <fo:external-graphic src="apache-fop-logo.jpg"/>
        </fo:block>
    </xsl:template>

    <xsl:template match="heading">
        <fo:block font-size="16pt" font-weight="bold" font-family="sans-serif">
            <xsl:value-of select="."/>
        </fo:block>
    </xsl:template>

    <xsl:template match="paragraph">
        <fo:block font-size="12pt" font-family="serif">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

    <xsl:template match="emph">
        <fo:inline font-style="italic">
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
</xsl:stylesheet>' | escape }}
</code></pre>
</details>

<p>&nbsp;</p>

This solution is missing a few features:

* No separate title page
* No footer
* No table of contents

### The title page

The `fo:layout-master-set` can be more complicated, as described in the example
[Making the first page special](https://xmlgraphics.apache.org/fop/fo.html#fo-first-page):

This would define two simple page masters and use them in a page-sequence-master
with repeatable-page-master-alternatives. But we can also make it simpler. We
just use two `fo:page-sequence` instances one after another:

```xml
        <fo:root>
            <fo:layout-master-set>
                <fo:simple-page-master master-name="first"
                    page-height="29.7cm" page-width="21.0cm" margin="2cm">
                    <fo:region-body region-name="title-region-body"/>
                </fo:simple-page-master>
                <fo:simple-page-master master-name="rest"
                    page-height="29.7cm" page-width="21.0cm" margin="2cm">
                    <fo:region-body region-name="main-region-body"/>
                </fo:simple-page-master>
            </fo:layout-master-set>
            <fo:page-sequence master-reference="first">
                <fo:flow flow-name="title-region-body">
                    <xsl:apply-templates select="title"/>
                    <xsl:apply-templates select="author"/>
                </fo:flow>
            </fo:page-sequence>
            <fo:page-sequence master-reference="rest">
                <fo:flow flow-name="main-region-body">
                    <xsl:apply-templates select="content"/>
                </fo:flow>
            </fo:page-sequence>
        </fo:root>
```

### The footer

Footers are added via a `fo:region-after` region and `fo:static-content`. The static content is repeated
on every page.

```xml
                <fo:simple-page-master master-name="rest"
                    page-height="29.7cm" page-width="21.0cm" margin="2cm">
                    <fo:region-body region-name="main-region-body"/>
                    <fo:region-after region-name="main-footer"/>
                </fo:simple-page-master>
```

This defines an area "main-footer". Which can be used for the static content:

```xml
            <fo:page-sequence master-reference="rest">
                <fo:static-content flow-name="main-footer">
                    <fo:block text-align="center"><fo:page-number/></fo:block>
                </fo:static-content>
...
```

Note the element `fo:page-number`- this returns the current page number.

### Table of contents

Now the tricky part: Generating a table of contents of the headers. One example is given in
[pdfoutline.fo](https://github.com/apache/xmlgraphics-fop/blob/trunk/fop/examples/fo/basic/pdfoutline.fo).

For PDF documents, a TOC is created using `fo:bookmark-tree`. But we also need a "real" page with a TOC.
In the example "pdfoutline.fo", this TOC is created at the very end of the document. It uses `fo:page-number-citation`
to get the page number for a specific section.

## Embedding into a java application

Well, I don't have a java application, so I'll create one. Standard way is [Apache Maven](https://maven.apache.org).
There we can declare the dependency to Apache FOP:

```xml
<dependency>
    <groupId>org.apache.xmlgraphics</groupId>
    <artifactId>fop-core</artifactId>
    <version>2.8</version>
</dependency>
```

And we can use the example
[ExampleXML2PDF.java](https://github.com/apache/xmlgraphics-fop/blob/trunk/fop/examples/embedding/java/embedding/ExampleXML2PDF.java)
as a starting point.

Using the [Maven Assembly Plugin](https://maven.apache.org/plugins/maven-assembly-plugin/index.html) in order to create
a executable all-in-one jar file. There are some caveats, however. FOP uses the ServiceLoader facility of Java
extensively. The default "jar-with-dependencies" assembly descriptor doesn't deal with the files in `META-INF/services`,
e.g. when there are multiple dependencies contributing to the services, then the last one wins. Luckily, there
is a solution: [Merging META-INF/services files with Maven Assembly plugin](https://stackoverflow.com/questions/47310215/merging-meta-inf-services-files-with-maven-assembly-plugin)
is a stackoverflow question. But the solution is also official documented: 
[Using Container Descriptor Handlers](https://maven.apache.org/plugins/maven-assembly-plugin/examples/single/using-container-descriptor-handlers.html#built-in-container-descriptor-handlers).

In order to create a standard PDF/A-1a document, fonts need to be embedded into the PDF document. This requires to
provide a fonts configuration for FOP, which is documented here: [Fonts](https://xmlgraphics.apache.org/fop/2.8/fonts.html).

I've chosen to use the [Free UCS Outline Fonts](http://savannah.gnu.org/projects/freefont/) from the GNU project.
These are open type fonts, that can be directly used in FOP.

However, now we have additionally to the images more resources - our fonts. So that FOP can find these files,
the simple way is to create a temporary directory and place the files there. But it also works to keep them
on the classpath. When configuring FOP, you need to provide a base URL. This base URL is used to resolve all
relative paths. And we can simply provide a base URL to a resource on the classpath. Doing this correctly
makes it working when running the application from the jar file or from the IDE (when the classpath is
still expanded on disk on several files).

The application also has a slightly enhanced XSL file: E.g. it uses `fo:declarations` to define the title
and author of the document. This goes into the metadata of the PDF document. It also uses basic accessibility
features, e.g. for the heading.

## Final result

The final application can be seen on github: <https://github.com/adangel/java-xml2pdf-example>.

You can download the repo also here: [java-xml2pdf-example-main.zip](/assets/2023-02-19-create-pdf-with-xsl-fo/java-xml2pdf-example-main.zip),
to have the source code not only on github.

Here are some screenshots of the generated pdf:

<div class="images">
{% include image.html name="mydoc-page-1.jpg" width="200px" %}
{% include image.html name="mydoc-page-2.jpg" width="200px" %}
{% include image.html name="mydoc-page-3.jpg" width="200px" %}
</div>

## References

* <https://en.wikipedia.org/wiki/XSLT>
* <https://en.wikipedia.org/wiki/XSL_Formatting_Objects>
* <https://www.w3.org/TR/xsl11/>
* <https://xmlgraphics.apache.org/fop/>
* <http://savannah.gnu.org/projects/freefont/>
* <https://loremipsum.io>

