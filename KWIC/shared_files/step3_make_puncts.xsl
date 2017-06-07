<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output exclude-result-prefixes="#all" indent="yes" method="xml" omit-xml-declaration="yes"/>

    <xsl:param name="version">foo</xsl:param>

    <xsl:template match="@* | tei:* | processing-instruction() | comment()">
        <xsl:choose>
            
            <xsl:when test="self::tei:pc">
                <xsl:choose>
                    <xsl:when test="$version = 'critical'">
                        <xsl:choose>
                            <!-- don't reproduce the semi-dip punctuation -->
                            <xsl:when test="@rend and contains('123456789', @rend)">
                                <!-- do nothing -->
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates
                                    select="tei:* | text() | processing-instruction() | comment()"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$version = 'semi-diplomatic'">
                        <xsl:choose>
                            <!-- 00B7 = middle dot -->
                            <xsl:when test="@rend = '1'">&#x00B7;</xsl:when>
                            <!-- 061B = arabic semicolon -->
                            <xsl:when test="@rend = '2'">&#x061B;</xsl:when>
                            <!-- 003F = question mark -->
                            <xsl:when test="@rend = '3'">&#x003F;</xsl:when>
                            <xsl:when test="@rend = '4'">%</xsl:when>
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>

            <xsl:when test="self::tei:seg[@type = 'make_uppercase']">
                <xsl:value-of select="upper-case(.)"/>
            </xsl:when>

            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates
                        select="@* | tei:* | text() | processing-instruction() | comment()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


</xsl:stylesheet>
