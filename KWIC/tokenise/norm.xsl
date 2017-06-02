<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:fn="http://www.w3.org/2005/xpath-functions">
  <xsl:output method="xml" indent="yes"/>
  
  <xsl:key name="locations" match="*[@location]" use="@location"/>

  <xsl:template match="node()">
    <xsl:copy>
      <xsl:for-each select="@*">
        <xsl:sort select="name(.)"/>
        <xsl:apply-templates select="."/>
      </xsl:for-each>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@following">
      <xsl:if test="count(key('locations', concat(replace(../@location, '\d\d$', ''), format-number(number(substring(../@location, fn:string-length(../@location) - 1)) + 1, '00')))/@location) != 0">
	      <xsl:attribute name="following"><xsl:value-of select="fn:replace(fn:replace(concat(' ', fn:replace(., '^[.,!]', ''), ' '), '^\s*((\S+\s){1,3}).*?$', '$1'), '^\s*(.+?)\s*$', '$1')"/></xsl:attribute>
      </xsl:if>
  </xsl:template>

  <xsl:template match="@preceding">
    <xsl:if test="not(fn:ends-with(../@location, '_01'))">
        <xsl:attribute name="preceding"><xsl:value-of select="fn:replace(fn:replace(concat(' ', ., ' '), '^.*?((\S+\s){1,3})\s*$', '$1'), '^\s*(.+?)\s*$', '$1')"/></xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template match="@n">
  </xsl:template>

  <xsl:template match="@*">
    <xsl:copy></xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>
