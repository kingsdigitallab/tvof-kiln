<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" version="2.0">
    
    <xsl:import href="../defaults.xsl"/>
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> 11 Nov 2016</xd:p>
            <xd:p><xd:b>Author:</xd:b> paulcaton</xd:p>
            <xd:p>This stylesheet tries to match a DIV xml:id value to an xml:id on a DIV type="alignment" in TVOF_para_alignment.xml;
                if successful it then gathers relevant corresp values from the AB children of the DIV type="alignment". These values are
                then used to create a corresp attribute in the original DIV in the transcription file.
                Everything else is left unchanged.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output method="xml"/>
    
    <xsl:variable name="alignmentslist" select="document('../../content/xml/tei/alists/TVOF_para_alignment.xml')"/>
     
    <xsl:template match="tei:*|@*|processing-instruction()|comment()">
        <xsl:choose>
            
            <xsl:when test="self::tei:div[@type='1']">
                <xsl:variable name="mystringvalue" select="@xml:id"/>
                <xsl:variable name="corresp_values">
                    <xsl:if test="$alignmentslist//tei:div[(@type='alignment') and (substring-after(tei:ab[@type='ms_instance'][1]/@corresp, '#') = $mystringvalue)]">
                        <!-- Wrapping the values in an element gives us the choice of just using the content or of copying the element into the output as is. -->
                        <tei:ab type="corresp_values">
                            <xsl:for-each select="$alignmentslist//tei:div[(@type='alignment') and (substring-after(tei:ab[@type='ms_instance'][1]/@corresp, '#') = $mystringvalue)]/tei:ab[(@type='ms_instance') and (position() > 1)]/@corresp">
                              <tei:seg><xsl:value-of select="."/><xsl:text> </xsl:text></tei:seg>
                            </xsl:for-each>
                        </tei:ab>
                    </xsl:if>
                </xsl:variable>
                <!-- Here we'll just grab the text content of the convenience tei:ab -->
                <xsl:variable name="string_of_values">
                    <xsl:if test="normalize-space($corresp_values)">
                        <xsl:value-of select="$corresp_values"/>
                    </xsl:if>
                </xsl:variable>
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:if test="normalize-space($string_of_values)"><xsl:attribute name="corresp" select="$string_of_values"/></xsl:if>
                    <xsl:apply-templates select="tei:*|text()|processing-instruction()|comment()"/>
                </xsl:copy>
            </xsl:when>
            
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
                </xsl:copy>
            </xsl:otherwise>
            
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>