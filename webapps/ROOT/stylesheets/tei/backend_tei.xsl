<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
  xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="../defaults.xsl" />
  <xsl:import href="to-html.xsl" />

  <!-- Comma separated names of the texts being displayed -->
  <xsl:param name="texts" />
  <!-- Comma separated names of the versions being displayed -->
  <xsl:param name="versions" />

  <xsl:template name="export-texts">
    <xsl:variable name="text-names" select="tokenize($texts, ',')" />
    <xsl:variable name="version-names" select="tokenize($versions, ',')" />
    <xsl:variable name="aggregation">
      <xsl:sequence select="/aggregation/*" />
    </xsl:variable>

    <texts>
      <xsl:for-each select="$text-names">
        <xsl:variable name="cur-text-name" select="." />
        <xsl:variable name="position" select="position()" />
        <xsl:variable name="cur-version-name" select="$version-names[$position]" />
        <xsl:variable name="tei">
          <xsl:sequence select="$aggregation/tei:TEI[$position]/*" />
        </xsl:variable>

        <text name="{$cur-text-name}">
          <title>
            <xsl:value-of
              select="$tei/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[1]"
             />
          </title>
          <generated>
            <date>
                <xsl:value-of
                  select="$tei/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date[1]"
                 />
            </date>
          </generated>
          <version>
            <xsl:value-of select="$cur-version-name" />
          </version>
          <manuscripts>
            <xsl:for-each select="$aggregation/files/file">
              <xsl:variable name="manuscript-name" select="@name" />
              <xsl:if test="versions/version[1]">
                  <manuscript name="{$manuscript-name}">
                    <versions>
                      <xsl:for-each select="versions/version">
                        <xsl:variable name="version-name" select="@name" />
    
                        <version name="{$version-name}">
                          <xsl:if test="$manuscript-name = $cur-text-name">
                            <xsl:if test="$version-name = $cur-version-name">
                              <xsl:attribute name="active">
                                <xsl:value-of select="true()" />
                              </xsl:attribute>
                            </xsl:if>
                          </xsl:if>
                        </version>
                      </xsl:for-each>
                    </versions>
                  </manuscript>
                </xsl:if>
            </xsl:for-each>
          </manuscripts>
          <!-- GN: 1 August 2017: commented out, no longer needed as the
               Text Viewer API can produce it from the full HTML
          -->
          <!-- toc>
            <xsl:for-each select="$tei/tei:text/tei:body/tei:div[@type = '1']">
              <item id="{@xml:id}">
                <xsl:apply-templates select="tei:head" />
              </item>
            </xsl:for-each>
          </toc -->
          <content>
            <xsl:apply-templates select="$tei/tei:text/tei:body">
              <xsl:with-param name="view" select="$cur-version-name"
                tunnel="yes" />
            </xsl:apply-templates>
          </content>
        </text>
      </xsl:for-each>
    </texts>
  </xsl:template>
</xsl:stylesheet>
