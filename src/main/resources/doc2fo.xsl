<?xml version="1.0" encoding="utf-8"?>
<!--
   Copyright 2023 Andreas Dangel

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:fox="http://xmlgraphics.apache.org/fop/extensions">
    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="/doc">
        <fo:root xml:lang="en" font-family="serif">
            <fo:layout-master-set>
                <fo:simple-page-master master-name="title"
                                       page-height="29.7cm" page-width="21.0cm" margin="2cm">
                    <fo:region-body region-name="title-region-body"/>
                </fo:simple-page-master>
                <fo:simple-page-master master-name="toc"
                                       page-height="29.7cm" page-width="21.0cm" margin="2cm">
                    <fo:region-body region-name="toc-region-body"/>
                </fo:simple-page-master>
                <fo:simple-page-master master-name="rest"
                                       page-height="29.7cm" page-width="21.0cm" margin="2cm">
                    <fo:region-body region-name="main-region-body"/>
                    <fo:region-after region-name="main-footer"/>
                </fo:simple-page-master>
            </fo:layout-master-set>

            <fo:declarations>
                <x:xmpmeta xmlns:x="adobe:ns:meta/">
                    <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
                        <rdf:Description rdf:about="" xmlns:dc="http://purl.org/dc/elements/1.1/">
                            <dc:title><xsl:value-of select="/doc/title"/></dc:title>
                            <dc:creator><xsl:value-of select="/doc/author"/></dc:creator>
                        </rdf:Description>
                    </rdf:RDF>
                </x:xmpmeta>
            </fo:declarations>

            <fo:bookmark-tree>
                <xsl:for-each select="content/heading">
                    <fo:bookmark internal-destination="{generate-id(.)}">
                        <fo:bookmark-title><xsl:value-of select="."/></fo:bookmark-title>
                    </fo:bookmark>
                </xsl:for-each>
            </fo:bookmark-tree>

            <fo:page-sequence master-reference="title">
                <fo:flow flow-name="title-region-body">
                    <xsl:apply-templates select="title"/>
                    <xsl:apply-templates select="author"/>
                </fo:flow>
            </fo:page-sequence>
            <fo:page-sequence master-reference="toc">
                <fo:flow flow-name="toc-region-body">
                    <fo:block font-size="16pt" font-weight="bold" font-family="sans-serif">Table of contents</fo:block>
                    <fo:table table-layout="fixed" width="100%" border-collapse="separate">
                        <fo:table-column column-width="15cm"/>
                        <fo:table-column column-width="2cm"/>
                        <fo:table-body font-size="12pt" font-family="serif">
                            <xsl:for-each select="content/heading">
                                <fo:table-row line-height="14pt">
                                    <fo:table-cell>
                                        <fo:block text-align="start">
                                            <fo:basic-link color="blue" internal-destination="{generate-id(.)}">
                                                <xsl:value-of select="."/>
                                            </fo:basic-link>
                                        </fo:block>
                                    </fo:table-cell>
                                    <fo:table-cell>
                                        <fo:block text-align="end">
                                            <fo:page-number-citation ref-id="{generate-id(.)}" />
                                        </fo:block>
                                    </fo:table-cell>
                                </fo:table-row>
                            </xsl:for-each>
                        </fo:table-body>
                    </fo:table>
                </fo:flow>
            </fo:page-sequence>
            <fo:page-sequence master-reference="rest" initial-page-number="1">
                <fo:static-content flow-name="main-footer">
                    <fo:block font-family="serif" text-align="center"><fo:page-number/></fo:block>
                </fo:static-content>
                <fo:flow flow-name="main-region-body">
                    <xsl:apply-templates select="content"/>
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
            <fo:external-graphic src="apache-fop-logo.jpg" fox:alt-text="Apache FOP logo on the title page"/>
        </fo:block>
    </xsl:template>

    <xsl:template match="heading">
        <fo:block font-size="16pt" font-weight="bold" font-family="sans-serif" role="H1" margin-top="5mm" margin-bottom="5mm">
            <xsl:attribute name="id"><xsl:value-of select="generate-id(.)"/></xsl:attribute>
            <xsl:value-of select="."/>
        </fo:block>
    </xsl:template>

    <xsl:template match="paragraph">
        <fo:block font-size="12pt" font-family="serif" margin-top="2mm" margin-bottom="2mm" text-align="justify">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

    <xsl:template match="emph">
        <fo:inline font-style="italic">
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>

</xsl:stylesheet>
