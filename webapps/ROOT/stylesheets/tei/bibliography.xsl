<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="to-html.xsl" />

  <xsl:template match="tei:TEI">
    <div id="bibliography">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="tei:text | tei:body">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="tei:div">
    <div>
      <xsl:apply-templates select="@*" />
      <xsl:choose>
        <xsl:when test="contains(@xml:id, 'works')">
          <!-- soon we will want to change this to handle grouping by author -->
          <xsl:apply-templates />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates />
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>

  <xsl:template match="tei:head">
    <h2>
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates />
    </h2>
  </xsl:template>

  <xsl:template match="tei:head[@type='sub']">
    <h4>
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates />
    </h4>
  </xsl:template>

  <xsl:template match="tei:list[@type='gloss']">
    <table>
      <xsl:apply-templates />
    </table>
  </xsl:template>

  <xsl:template match="tei:list[@type='gloss']/tei:item">
    <tr class="biblGlossItem">
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates />
    </tr>
  </xsl:template>

  <xsl:template match="tei:list[@type='gloss']/tei:item/tei:abbr">
    <td>
      <xsl:choose>
        <xsl:when test="@rend='upright'"><!-- do nothing --></xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="class">italic</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates />
    </td>
  </xsl:template>

  <xsl:template match="tei:list[@type='gloss']/tei:item/tei:expan">
    <td class="biblExpan">
      <xsl:choose>
        <xsl:when test="@rend='upright'"><!-- do nothing --></xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="class">italic</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates />
    </td>
  </xsl:template>

  <xsl:template match="tei:bibl">
    <p class="biblEntry">
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates />
    </p>
  </xsl:template>

  <xsl:template match="tei:author">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="tei:title[@level='a']">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="tei:title[(@level='j') or (@level='m')]">
    <span class="italic">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="tei:hi[@rend='italic']">
    <span class="italic">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="tei:hi[@rend='upright']">
    <span class="upright">
      <xsl:apply-templates />
    </span>
  </xsl:template>
</xsl:stylesheet>
