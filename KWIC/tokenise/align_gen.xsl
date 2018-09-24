<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0"
xmlns:xml2="http://www.w3.org/XML/1998/namespace2"
>
    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="/">
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
            <teiHeader>
                <fileDesc>
                    <titleStmt>
                        <title type="main">TVOF paragraph alignment</title>
                    </titleStmt>
                    <publicationStmt>
                        <p>King's Digital Laboratory</p>
                    </publicationStmt>
                    <sourceDesc>
                        <ab/>
                    </sourceDesc>
                </fileDesc>
            </teiHeader>
            <text>
                <body>
                    <div type="alignments">
                        <xsl:apply-templates select="/tei:TEI/tei:text/tei:body/*" />
                    </div>
                </body>
            </text>
        </TEI>
    </xsl:template>

    <xsl:template match="tei:milestone">
        <xsl:copy-of select="." />
    </xsl:template>

    <xsl:template match="tei:div[@type!='notes']">
        <div type="alignment" id="{substring(@xml:id,3)}">
            <ab type="ms_instance" subtype="base" corresp="#{@xml:id}">
                <seg type="ms_name">Royal_20_D_1</seg>
                <seg type="rubric">
                    <xsl:for-each select="tei:head//text()"><xsl:value-of select="." /></xsl:for-each>
                </seg>
                <seg type="location"><xsl:value-of select="@n" /></seg>
                <seg type="note"></seg>
            </ab>
        </div>
    </xsl:template>

    <xsl:template match="*"></xsl:template>

</xsl:stylesheet>