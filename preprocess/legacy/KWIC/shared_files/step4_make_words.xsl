<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output exclude-result-prefixes="#all" indent="yes" method="xml" omit-xml-declaration="yes"/>

    <xsl:param name="version">foo</xsl:param>

    <xsl:template match="/">
        <kwiclist>
            <xsl:apply-templates/>
        </kwiclist>
    </xsl:template>

    <xsl:template match="tei:TEI">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:teiHeader"/>

    <xsl:template match="tei:text">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:body">
        <xsl:for-each select="//tei:head[@type = 'rubric']">
            <xsl:variable name="id">
                <xsl:value-of select="parent::tei:div/@xml:id"/>
            </xsl:variable>
            <xsl:variable name="rubrictext" select="translate(normalize-space(.), '[]', '')"/>
            <xsl:analyze-string select="$rubrictext" regex="[\S]+">
                <xsl:matching-substring>
                    <xsl:choose> 
                            <!-- if the substring starts with a period, comma, or single quote mark we need to put that char into its own element -->
                        <xsl:when test="matches(., '^[,\.,‘][^,\.,‘]+$')">
                            <word type="rubric_word" subtype="init_punct" location="{$id}" position="{position()}">
                                <punctuation type="init"><xsl:value-of select="substring(., 1, 1)"/></punctuation>
                                <string><xsl:value-of select="substring(., 2)"/></string>
                            </word>
                        </xsl:when>
                        
                        <!-- if the substring ends with a period, comma, or single quote mark we need to put that char into its own element -->
                        <xsl:when test="matches(., '^[^,\.,‘]+[,\.]$')">
                            <xsl:variable name="allbutlast" select="substring(., 1, string-length(.)-1)"/>
                            <word type="rubric_word" location="{$id}" position="{position()}">
                                <string><xsl:value-of select="$allbutlast"/></string>
                                <punctuation><xsl:value-of select="substring-after(., $allbutlast)"/></punctuation>
                            </word>
                        </xsl:when>
                        
                        <xsl:otherwise>
                            <word type="rubric_word" location="{$id}" position="{position()}">
                                <string><xsl:value-of select="."/></string>
                            </word>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:for-each>
        <xsl:for-each select="//tei:seg[@type = ('1', '2', '3', '4', '5', '6', '7', '8', '9')]">
            <xsl:variable name="id">
                <xsl:value-of select="@xml:id"/>
            </xsl:variable>
            <xsl:variable name="segtext" select="translate(normalize-space(.), '[]', '')"/>
            <xsl:analyze-string select="$segtext" regex="[\S]+">
                <xsl:matching-substring>
                    <xsl:choose>
                        
                        <!-- if the substring starts with a period, comma, or single quote mark we need to put that char into its own element -->
                        <xsl:when test="matches(., '^[,\.,‘][^,\.,‘]+$')">
                            <word type="seg_word" subtype="init_punct" location="{$id}" position="{position()}">
                                <punctuation type="init"><xsl:value-of select="substring(., 1, 1)"/></punctuation>
                                <string><xsl:value-of select="substring(., 2)"/></string>
                            </word>
                        </xsl:when>
                         
                        <!-- if the substring ends with a period or comma, we need to put that char into its own element -->
                        <xsl:when test="matches(., '^[^,\.]+[,\.]$')">
                            <xsl:variable name="allbutlast" select="substring(., 1, string-length(.)-1)"/>
                            <word type="seg_word" subtype="end_punct" location="{$id}" position="{position()}">
                                <string><xsl:value-of select="$allbutlast"/></string>
                                <punctuation type="end"><xsl:value-of select="substring-after(., $allbutlast)"/></punctuation>
                            </word>
                        </xsl:when>
                        
                        <xsl:otherwise>
                            <word type="seg_word" location="{$id}" position="{position()}">
                                <string><xsl:value-of select="."/></string>
                            </word>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
