<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" version="2.0">

    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> 22 Nov 2016</xd:p>
            <xd:p><xd:b>Author:</xd:b> paulcaton</xd:p>
            <xd:p>This stylesheet takes as input a TVOF transcription file with semi-dip AND
                critical version markup present. According to the value of $version, it outputs
                either: --- a version where all content choices are resolved to critical version
                values, or: --- a semi-diplomatic version</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml"/>

    <xsl:param name="version">foo</xsl:param>

    <xsl:template match="tei:* | @* | processing-instruction() | comment()">
        <xsl:choose>
            <xsl:when test="self::tei:cb or self::tei:pb">
                <!-- do nothing -->
            </xsl:when>
            
            <xsl:when test="self::tei:choice">
                <xsl:apply-templates select="tei:* | text() | processing-instruction() | comment()"
                />
            </xsl:when>
            
            <xsl:when test="self::tei:corr">
                <xsl:choose>
                    <xsl:when test="$version = 'critical'">
                        <xsl:apply-templates/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- do nothing -->
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

            <xsl:when test="self::tei:del">
                <!-- PC: 06 Feb 2017: redundant to make both choices do nothing, but keep for the moment until partners are sure they don't want <del> content displaying in any index -->
                <xsl:choose>
                    <xsl:when test="$version = 'critical'">
                        <!-- do nothing -->
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- do nothing -->
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

            <xsl:when test="self::tei:orig">
                <xsl:choose>
                    <xsl:when test="$version = 'critical'">
                        <!-- do nothing -->
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

            <xsl:when test="self::tei:reg">
                <xsl:choose>
                    <xsl:when test="$version = 'critical'">
                        <xsl:apply-templates
                            select="tei:* | text() | processing-instruction() | comment()"/>
                        <xsl:if test="string-to-codepoints(.) = 39">
                            <xsl:text> </xsl:text>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise><!-- do nothing --></xsl:otherwise>
                </xsl:choose>
            </xsl:when>

            <xsl:when test="self::tei:seg[@type = 'semi-dip']">
                <xsl:choose>
                    <xsl:when test="$version = 'critical'">
                        <!-- do nothing -->
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

            <xsl:when test="self::tei:seg[@type = 'crit']">
                <xsl:choose>
                    <xsl:when test="$version = 'critical'">
                        <xsl:choose>
                            <xsl:when test="@subtype = 'toUpper'">
                                <xsl:copy>
                                    <xsl:attribute name="type">make_uppercase</xsl:attribute>
                                    <xsl:apply-templates
                                        select="tei:* | text() | processing-instruction() | comment()"
                                    />
                                </xsl:copy>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates
                                    select="tei:* | text() | processing-instruction() | comment()"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                       <!-- do nothing -->
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

            <xsl:when test="self::tei:seg[@type = 'stripFirstLetter']">
                <xsl:value-of select="substring-after(., substring(., 1, 1))"/>
            </xsl:when>
            
            <xsl:when test="self::tei:sic">
                <xsl:choose>
                    <xsl:when test="$version = 'critical'">
                        <!-- do nothing -->                    
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates/>
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
