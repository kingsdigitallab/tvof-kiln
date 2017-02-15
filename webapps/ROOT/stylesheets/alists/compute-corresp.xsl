<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="tei:ab[@type = 'ms_instance'][contains(@corresp, ' ')]"
    priority="1">
    <xsl:variable name="corresps" select="tokenize(@corresp, ' ')" />
    <xsl:variable name="from"
      select="xs:integer(tokenize($corresps[1], '_')[last()])" />
    <xsl:variable name="to"
      select="xs:integer(tokenize($corresps[2], '_')[last()])" />
    <xsl:variable name="base-id"
      select="substring($corresps[1], 1, string-length($corresps[1]) - 3)" />

    <xsl:variable name="computed-corresp">
      <xsl:for-each select="$from to $to">
        <xsl:value-of select="$base-id" />
        <xsl:text>_</xsl:text>
        <xsl:number format="01" value="current()" />
        <xsl:if test="position() != last()">
          <xsl:text> </xsl:text>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:copy>
      <xsl:sequence select="@*" />
      <xsl:attribute name="computed-corresp" select="$computed-corresp" />
      <xsl:apply-templates select="tei:* | processing-instruction() | comment()"
       />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:ab[@type = 'ms_instance'][@corresp]">
    <xsl:copy>
      <xsl:sequence select="@*" />
      <xsl:attribute name="computed-corresp" select="@corresp" />
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
