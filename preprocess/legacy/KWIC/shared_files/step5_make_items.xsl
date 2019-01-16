<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output exclude-result-prefixes="#all" indent="yes" method="xml" omit-xml-declaration="yes"/>

    <xsl:param name="version">foo</xsl:param>



    <xsl:template match="/">
        <xsl:apply-templates select="kwiclist"/>
    </xsl:template>

    <xsl:template match="kwiclist">
        <xsl:copy>
            <xsl:variable name="rubricwords">
                <!-- this will just be the sequence of <word> elements -->
                <xsl:sequence select="word[@type = 'rubric_word']"/>
            </xsl:variable>

            <xsl:variable name="segwords">
                <!-- this will just be the sequence of <word> elements -->
                <xsl:sequence select="word[@type = 'seg_word']"/>
            </xsl:variable>

            <xsl:for-each select="$rubricwords/*">
                <!-- For rubric words the preceding and following siblings must only be ones with the same location as the current word -->
                <xsl:variable name="loc" select="@location"/>
                
                <xsl:variable name="prec7">
                    <xsl:value-of select="normalize-space(preceding-sibling::*[7][@location=$loc])"/>
                </xsl:variable>
                
                <xsl:variable name="prec6">
                    <xsl:value-of select="normalize-space(preceding-sibling::*[6][@location=$loc])"/>
                </xsl:variable>
                
                <xsl:variable name="prec5">
                    <xsl:value-of select="normalize-space(preceding-sibling::*[5][@location=$loc])"/>
                </xsl:variable>
                
                <xsl:variable name="prec4">
                    <xsl:value-of select="normalize-space(preceding-sibling::*[4][@location=$loc])"/>
                </xsl:variable>
                
                <xsl:variable name="prec3">
                    <xsl:value-of select="normalize-space(preceding-sibling::*[3][@location=$loc])"/>
                </xsl:variable>
                
                <xsl:variable name="prec2">
                    <xsl:value-of select="normalize-space(preceding-sibling::*[2][@location=$loc])"/>
                </xsl:variable>
                
                <xsl:variable name="prec1">
                    <xsl:value-of select="normalize-space(preceding-sibling::*[1][@location=$loc])"/>
                </xsl:variable>
                
                <xsl:variable name="foll7">
                    <xsl:value-of select="normalize-space(following-sibling::*[7][@location=$loc])"/>
                </xsl:variable>
                
                <xsl:variable name="foll6">
                    <xsl:value-of select="normalize-space(following-sibling::*[6][@location=$loc])"/>
                </xsl:variable>
                
                <xsl:variable name="foll5">
                    <xsl:value-of select="normalize-space(following-sibling::*[5][@location=$loc])"/>
                </xsl:variable>
                
                <xsl:variable name="foll4">
                    <xsl:value-of select="normalize-space(following-sibling::*[4][@location=$loc])"/>
                </xsl:variable>
                
                <xsl:variable name="foll3">
                    <xsl:value-of select="normalize-space(following-sibling::*[3][@location=$loc])"/>
                </xsl:variable>
                
                <xsl:variable name="foll2">
                    <xsl:value-of select="normalize-space(following-sibling::*[2][@location=$loc])"/>
                </xsl:variable>
                
                <xsl:variable name="foll1">
                    <xsl:value-of select="normalize-space(following-sibling::*[1][@location=$loc])"/>
                </xsl:variable>
                
                <item type="rubric_item" location="{$loc}"
                    preceding="{$prec7, $prec6, $prec5, $prec4, $prec3, $prec2, $prec1}"
                    following="{$foll1, $foll2, $foll3, $foll4, $foll5, $foll6, $foll7}">
                    <xsl:if test="@subtype='init_punct'">
                        <xsl:copy-of select="child::punctuation[@type='init']"/>
                    </xsl:if>
                    <xsl:copy-of select="string"/>
                    <xsl:if test="@subtype='end_punct'">
                        <xsl:copy-of select="child::punctuation[@type='end']"/>
                    </xsl:if>
                </item>
            </xsl:for-each>

            <xsl:for-each select="$segwords/*">
                
                <xsl:variable name="prec7">
                    <xsl:value-of select="normalize-space(preceding-sibling::*[7])"/>
                </xsl:variable>
                
                <xsl:variable name="prec6">
                    <xsl:value-of select="normalize-space(preceding-sibling::*[6])"/>
                </xsl:variable>
                
                <xsl:variable name="prec5">
                    <xsl:value-of select="normalize-space(preceding-sibling::*[5])"/>
                </xsl:variable>
                
                <xsl:variable name="prec4">
                    <xsl:value-of select="normalize-space(preceding-sibling::*[4])"/>
                </xsl:variable>
                
                <xsl:variable name="prec3">
                    <xsl:value-of select="normalize-space(preceding-sibling::*[3])"/>
                </xsl:variable>
                
                <xsl:variable name="prec2">
                    <xsl:value-of select="normalize-space(preceding-sibling::*[2])"/>
                </xsl:variable>
                
                <xsl:variable name="prec1">
                    <xsl:value-of select="normalize-space(preceding-sibling::*[1])"/>
                </xsl:variable>
                
                <xsl:variable name="foll7">
                    <xsl:value-of select="normalize-space(following-sibling::*[7])"/>
                </xsl:variable>
                
                <xsl:variable name="foll6">
                    <xsl:value-of select="normalize-space(following-sibling::*[6])"/>
                </xsl:variable>
                
                <xsl:variable name="foll5">
                    <xsl:value-of select="normalize-space(following-sibling::*[5])"/>
                </xsl:variable>
                
                <xsl:variable name="foll4">
                    <xsl:value-of select="normalize-space(following-sibling::*[4])"/>
                </xsl:variable>
                
                <xsl:variable name="foll3">
                    <xsl:value-of select="normalize-space(following-sibling::*[3])"/>
                </xsl:variable>
                
                <xsl:variable name="foll2">
                    <xsl:value-of select="normalize-space(following-sibling::*[2])"/>
                </xsl:variable>
                
                <xsl:variable name="foll1">
                    <xsl:value-of select="normalize-space(following-sibling::*[1])"/>
                </xsl:variable>
                
                <item type="seg_item" location="{@location}"
                    preceding="{$prec7, $prec6, $prec5, $prec4, $prec3, $prec2, $prec1}"
                    following="{$foll1, $foll2, $foll3, $foll4, $foll5, $foll6, $foll7}">
                    <xsl:if test="@subtype='init_punct'">
                        <xsl:copy-of select="child::punctuation[@type='init']"/>
                    </xsl:if>
                    <xsl:copy-of select="string"/>
                    <xsl:if test="@subtype='end_punct'">
                        <xsl:copy-of select="child::punctuation[@type='end']"/>
                    </xsl:if>
                </item>
                
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
