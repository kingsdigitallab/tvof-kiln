<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
    xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    
    <xsl:param name="alid">foo</xsl:param>
    
    <xsl:variable name="almnt">
        <xsl:sequence select="/aggregation/alignments//tei:div[(@type='alignment') and @xml:id=$alid]"/>
    </xsl:variable>
    <xsl:variable name="basechunkid" select="substring-after($almnt//tei:ab[(@type='ms_instance') and (@subtype='base')]/@corresp, '#')"/>
    <xsl:variable name="basechunk">
        <xsl:sequence select="/aggregation/basems//tei:*[@xml:id=$basechunkid]"/>
    </xsl:variable>
    
    <xsl:variable name="royalchunkid1">
        <xsl:choose>
            <xsl:when test="contains($almnt//tei:ab[(@type='ms_instance') and (starts-with(@corresp, '#edRoyal'))]/@corresp, ' #')">
                <xsl:value-of select="substring-after(tokenize($almnt//tei:ab[(@type='ms_instance') and (starts-with(@corresp, '#edRoyal'))]/@corresp, '\s')[1], '#')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="substring-after($almnt//tei:ab[(@type='ms_instance') and (starts-with(@corresp, '#edRoyal'))]/@corresp, '#')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="num1" select="substring-after(substring-after($royalchunkid1, '_'), '_')"/>
    
    <xsl:variable name="royalchunkid2">
        <xsl:choose>
            <xsl:when test="contains($almnt//tei:ab[(@type='ms_instance') and (starts-with(@corresp, '#edRoyal'))]/@corresp, ' #')">
                <xsl:value-of select="substring-after(tokenize($almnt//tei:ab[(@type='ms_instance') and (starts-with(@corresp, '#edRoyal'))]/@corresp, '\s')[2], '#')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>knobhead</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="num2" select="substring-after(substring-after($royalchunkid2, '_'), '_')"/>
    
    <xsl:variable name="royalchunk">
        <xsl:sequence
            select="tei:page-content(/aggregation/royalms//tei:seg[@xml:id = $royalchunkid1], /aggregation/royalms//tei:seg[@xml:id = $royalchunkid2], /aggregation/royalms//tei:text)"
        />
    </xsl:variable>
    
    
    <xsl:template match="tei:body" mode="single-alignment">
        
        <table>
            <tr>
                <th>FR20125</th>
                <th>Royal</th>
            </tr>
            <tr><td><xsl:value-of select="$basechunk"/></td>
                <td>
                    <xsl:copy-of select="$royalchunk"/>
                    
                </td>
            </tr>
        </table>
    </xsl:template>
    
    <xsl:function name="tei:page-content" as="node()*">
        <xsl:param name="ms1" as="node()"/>
        <xsl:param name="ms2" as="node()"/>
        <xsl:param name="node" as="node()"/>
        <xsl:choose>
            <xsl:when test="$node[self::*]">
                <!-- $node is an element() -->
                <xsl:choose>
                    <xsl:when test="$node is $ms1 or $node is $ms2">
                        <xsl:copy-of select="$node"/>
                    </xsl:when>
                    <xsl:when
                        test="
                        some $n in $node/descendant::*
                        satisfies ($n is $ms1 or $n is $ms2)">
                        <xsl:element name="{name($node)}">
                            <xsl:sequence
                                select="
                                for $i in ($node/node() | $node/@*)
                                return
                                tei:page-content($ms1, $ms2, $i)"
                            />
                        </xsl:element>
                    </xsl:when>
                    <xsl:when test="($node >> $ms1) and ($node &lt;&lt; $ms2)">
                        <xsl:copy-of select="$node"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- do nothing -->
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$node[count(. | ../@*) = count(../@*)]">
                <!-- $node is an attribute -->
                <xsl:attribute name="{name($node)}">
                    <xsl:sequence select="data($node)"/>
                </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="($node >> $ms1) and ($node &lt;&lt; $ms2)">
                        <xsl:value-of select="$node"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- do nothing -->
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    
    <!--
    
    <xsl:template match="tei:seg">
        <xsl:choose>
            <xsl:when test="@xml:id=$royalchunkid1">
                
                <xsl:value-of select="."/>
                <xsl:for-each select="following-sibling::tei:seg">
                    <xsl:if test="number(substring-after(substring-after(@xml:id, '_'), '_')) &lt; number($num2)"><xsl:value-of select="."/></xsl:if>
                    
                </xsl:for-each>
                <xsl:value-of select="following-sibling::tei:seg[@xml:id=$royalchunkid2]"/>
            </xsl:when>
            <xsl:otherwise><!-\- do nothing -\-></xsl:otherwise>
        </xsl:choose>
    </xsl:template>-->
    
</xsl:stylesheet>
