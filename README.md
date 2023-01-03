# java-xml2pdf-example

Example of how to use [Apache FOP](https://xmlgraphics.apache.org/fop/) to create a PDF document
in a simple Java application. The application converts a self-defined XML format using
a XSL stylesheet into [XML-FO](https://www.w3.org/TR/xsl11/#fo-section) and then into PDF.

**Features:**

* Title page with embedded image
* Table of contents
* Bookmarks in PDF
* Embedded open type fonts
* Self-contained as an executable jar

## Building and running

```shell
./mvnw clean verify
java -jar target/javaxml2pdf-1.0-SNAPSHOT-jar-with-dependencies.jar example/bigdoc.xml
open example/bigdoc.pdf
```

## Examples

* Simple minimal document:
  * XML: [example/mydoc.xml](example/mydoc.xml)
  * PDF: [example/mydoc.pdf](example/mydoc.pdf)
* Bigger document:
  * XML: [example/bigdoc.xml](example/bigdoc.xml)
  * PDF: [example/bigdoc.pdf](example/bigdoc.pdf)

## References

* <https://en.wikipedia.org/wiki/XSLT>
* <https://en.wikipedia.org/wiki/XSL_Formatting_Objects>
* <https://www.w3.org/TR/xsl11/>
* <https://xmlgraphics.apache.org/fop/>
* <http://savannah.gnu.org/projects/freefont/>
* <https://loremipsum.io>

## License

Apache License, Version 2.0
