<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="../defaults.xsl" />

  <!-- Output method is not needed for Cocoon. -->
  <!--<xsl:output method="xml" />-->


  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> 11 Nov 2016</xd:p>
      <xd:p><xd:b>Author:</xd:b> paulcaton</xd:p>
      <xd:p>This stylesheet tries to match a DIV xml:id value to an xml:id on a
        DIV type="alignment" in TVOF_para_alignment.xml; if successful it then
        gathers relevant corresp values from the AB children of the DIV
        type="alignment". These values are then used to create a corresp
        attribute in the original DIV in the transcription file. Everything else
        is left unchanged.</xd:p>
    </xd:desc>
  </xd:doc>

  <xsl:variable name="alignments">
    <xsl:sequence select="/aggregation/alignments//tei:div[@type = 'alignment']"
     />
  </xsl:variable>

  <xsl:template match="/aggregation/alignments" />

  <xsl:template match="tei:div[@type = '1']">
    <xsl:variable name="id" select="concat('#', @xml:id)" />

    <xsl:variable name="alignment">
      <xsl:sequence
        select="$alignments/*[tei:ab[@type = 'ms_instance'][1]/@corresp = $id]"
       />
    </xsl:variable>

    <xsl:variable name="corresp">
      <xsl:for-each
        select="$alignment//tei:ab[(@type = 'ms_instance')][(position() > 1)]/@corresp">
        <xsl:value-of select="." />
        <xsl:text> </xsl:text>
      </xsl:for-each>
    </xsl:variable>

    <xsl:copy>
      <xsl:sequence select="@*" />
      <xsl:if test="normalize-space($corresp)">
        <xsl:attribute name="corresp" select="normalize-space($corresp)" />
      </xsl:if>
      <xsl:apply-templates select="tei:* | processing-instruction() | comment()"
       />
    </xsl:copy>
  </xsl:template>


  <xsl:template
    match="tei:seg[string(@type) = ('1', '2', '3', '4', '5')][@xml:id]">
    <xsl:variable name="id" select="concat('#', @xml:id)" />

    <xsl:variable name="alignment">
      <xsl:sequence
        select="$alignments/*[tei:ab[@type = 'ms_instance'][position() > 1][contains(@computed-corresp, $id)]]"
       />
    </xsl:variable>

    <xsl:variable name="corresp">
      <xsl:for-each select="$alignment//tei:ab[1]/@corresp">
        <xsl:value-of select="." />
        <xsl:text> </xsl:text>
      </xsl:for-each>
    </xsl:variable>

    <xsl:copy>
      <xsl:sequence select="@*" />
      <xsl:if test="normalize-space($corresp)">
        <xsl:attribute name="corresp">
          <xsl:value-of select="$corresp" />
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="tei:* | processing-instruction() | comment()"
       />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:* | @* | processing-instruction() | comment()">
    <xsl:copy>
      <xsl:apply-templates
        select="* | @* | text() | processing-instruction() | comment()" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
