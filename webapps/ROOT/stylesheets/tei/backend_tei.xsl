<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
  xmlns:dir="http://apache.org/cocoon/directory/2.0"
  xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="../defaults.xsl" />
  <xsl:import href="to-html.xsl" />

  <!-- Comma separated names of the texts being displayed -->
  <xsl:param name="texts" />

  <xsl:template name="export-texts">
    <xsl:variable name="text-names" select="tokenize($texts, ',')" />
    <xsl:variable name="aggregation">
      <xsl:sequence select="/aggregation/*" />
    </xsl:variable>

    <texts>
      <xsl:for-each select="$text-names">
        <xsl:variable name="position" select="position()" />
        <xsl:variable name="cur-text-name" select="." />
        <xsl:variable name="tei">
          <xsl:sequence select="$aggregation/tei:TEI[$position]/*" />
        </xsl:variable>

        <text name="{$cur-text-name}">
          <title>
            <xsl:value-of
              select="$tei/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[1]"
             />
          </title>
          <versions>
            <xsl:for-each select="$aggregation//dir:directory/dir:file">
              <xsl:variable name="name" select="substring-before(@name, '.xml')" />
              <xsl:if test="$name != $cur-text-name">
                <version name="{$name}" />
              </xsl:if>
            </xsl:for-each>
          </versions>
          <content>
            <xsl:apply-templates select="$tei/tei:text/tei:body" />
          </content>
        </text>
      </xsl:for-each>
    </texts>
  </xsl:template>
</xsl:stylesheet>
