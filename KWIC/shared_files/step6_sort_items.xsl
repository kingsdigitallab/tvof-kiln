<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:output method="xml"/>
    
    <xsl:param name="version">foo</xsl:param>
    <xsl:param name="use_stoplist">no</xsl:param>

    <xsl:variable name="stopwords">
        <xsl:choose>
            <xsl:when test="$use_stoplist = 'yes'">
                <xsl:sequence select="doc('stopwordslist.xml')"/>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>

    <xsl:template match="/">
        <xsl:message>value of use_stoplist is <xsl:value-of select="$use_stoplist"/></xsl:message>
        <xsl:apply-templates select="kwiclist"/>
    </xsl:template>

    <xsl:template match="kwiclist">
        <xsl:copy>
            <xsl:for-each-group select="item" group-by="substring(lower-case(string), 1, 1)">
                <xsl:sort select="current-grouping-key()"/>
                <sublist key="{current-grouping-key()}">
                    <xsl:for-each select="current-group()">
                        <xsl:sort select="lower-case(string)"/>
                        <xsl:choose>
                            <xsl:when test="($use_stoplist = 'yes') and ($stopwords/list/word = string)"
                                ><!-- do nothing --></xsl:when>
                            <xsl:otherwise>
                                <xsl:copy-of select="."/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </sublist>
            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>



</xsl:stylesheet>
