<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" version="2.0">

    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> 22 Nov 2016</xd:p>
            <xd:p><xd:b>Author:</xd:b> paulcaton</xd:p>
            <xd:p>This stylesheet takes as input a TVOF transcription file. It outputs a version
                where the first letter of name-type elements is encoded with tei:choice. Everything
                else is left unchanged.</xd:p>
        </xd:desc>
    </xd:doc>


    <xsl:template match="tei:* | @* | processing-instruction() | comment()">
        <xsl:choose>

            <xsl:when
                test="self::tei:persName or self::tei:placeName or self::tei:geogName or self::tei:name">
                <xsl:variable name="firstLetter" select="substring(., 1, 1)"/>
                <xsl:choose>
                    <xsl:when test="child::tei:choice/position() = 1">
                        <xsl:copy>
                            <xsl:apply-templates
                                select="tei:* | @* | text() | processing-instruction() | comment()"/>
                        </xsl:copy>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy>
                            <tei:choice>
                                <tei:seg type="crit" subtype="toUpper">
                                    <xsl:value-of select="$firstLetter"/>
                                </tei:seg>
                                <tei:seg type="semi-dip">
                                    <xsl:value-of select="$firstLetter"/>
                                </tei:seg>
                            </tei:choice>
                            <xsl:value-of select="substring-after(., $firstLetter)"/>
                        </xsl:copy>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates
                        select="tei:* | @* | text() | processing-instruction() | comment()"/>
                </xsl:copy>
            </xsl:otherwise>

        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
