<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" version="2.0">

    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> 22 Nov 2016</xd:p>
            <xd:p><xd:b>Authors:</xd:b> paul caton, geoffroy noel</xd:p>
            <xd:p>This stylesheet takes as input a TVOF transcription file. It outputs a version
                where the first letter of name-type elements is encoded with tei:choice. Everything
                else is left unchanged.</xd:p>
        </xd:desc>
    </xd:doc>

    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="tei:persName//text() | tei:geogName//text() | tei:placeName//text() | tei:name[not(@type=('building'))]//text()">
        <xsl:choose>
            <!-- CDT: first non-empty text anywhere under the <name>   AND   not already encoded with toUpper -->
            <xsl:when test="(. = (ancestor::*[local-name()=('geogName','persName','placeName','name')][1]//text()[string-length(normalize-space(.)) &gt; 0])[1]) and not(ancestor::*[@subtype='toUpper'])">
                <tei:choice xsl:xpath-default-namespace="">
                    <tei:seg type="crit" subtype="toUpper">
                        <xsl:value-of select="substring(., 1, 1)"/>
                    </tei:seg>
                    <tei:seg type="semi-dip">
                        <xsl:value-of select="substring(., 1, 1)"/>
                    </tei:seg>
                </tei:choice>
                <tei:seg type="stripFirstLetter" xmlns:tei="http://www.tei-c.org/ns/1.0"><xsl:value-of select="."/></tei:seg>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy></xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
