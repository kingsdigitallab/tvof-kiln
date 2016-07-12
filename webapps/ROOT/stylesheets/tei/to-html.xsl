<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Project-specific XSLT for transforming TEI to
       HTML. Customisations here override those in the core
       to-html.xsl (which should not be changed). -->

  <xsl:import href="../../kiln/stylesheets/tei/to-html.xsl" />

  <xsl:template match="tei:ab">
    <div class="ab">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="tei:add">
    <xsl:if test="@hand != 'LH'">
      <span class="add">
        <xsl:apply-templates />
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:c[@rend = 'R']">
    <span class="redletter">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="tei:cb">
    <xsl:choose>
      <xsl:when test="@n != 'a'">
        <span class="cb">/<xsl:value-of select="@n" />/</span>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:del">
    <span class="del">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="tei:div[@type = '1']">
    <div class="type1">
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="tei:head[@type = 'rubric']">
    <h4 class="rubric">
      <xsl:apply-templates />
    </h4>
  </xsl:template>

  <xsl:template match="tei:l">
    <br />
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="tei:lb">
    <br />
  </xsl:template>

  <xsl:template match="tei:pb">
    <br />
    <span class="pb">//<xsl:value-of select="@n" /><xsl:if
        test="following-sibling::tei:cb[1][@n = 'a']"><xsl:text>/</xsl:text><xsl:value-of
          select="following-sibling::tei:cb[1]/@n" /></xsl:if>//</span>
    <br />
  </xsl:template>

  <xsl:template match="tei:pc">
    <xsl:if test="@rend and contains('123', @rend)">
      <span class="pc">
        <xsl:choose>
          <xsl:when test="@rend = '1'">&#x00B7;</xsl:when>
          <xsl:when test="@rend = '2'">&#x061B;</xsl:when>
          <xsl:when test="@rend = '3'">&#x003F;</xsl:when>
        </xsl:choose>
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:q">
    <span class="quoted">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="tei:seg[@type = 'ms_name']">
    <span class="ms-name">
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates />
      <xsl:text> </xsl:text>
    </span>
  </xsl:template>

  <xsl:template match="tei:seg[@type = 'location']">
    <span class="ms-name">
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates />
      <xsl:text> </xsl:text>
    </span>
  </xsl:template>

  <xsl:template match="tei:seg[@type = 'rubric' and @xml:id]">
    <span class="rubric">
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="tei:seg[@type = '1']">
    <xsl:choose>
      <xsl:when test="(starts-with(@xml:id, 'edfr20125')) and (not(@rend = 'NR'))">
        <span class="seg1rfl">
          <xsl:apply-templates select="@*" />
          <xsl:apply-templates />
        </span>
      </xsl:when>
      <xsl:otherwise>
        <span class="seg1">
          <xsl:apply-templates select="@*" />
          <xsl:apply-templates />
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:seg[@type = 'textual-unit-2']">
    <span class="t-u-2">
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="tei:seg[@type = 'textual-unit-3-moralisation']">
    <br />
    <span class="t-u-3">
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="tei:unclear">
    <span class="unclear">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="@corresp">
    <xsl:attribute name="data-corresp">
      <xsl:value-of select="." />
    </xsl:attribute>
  </xsl:template>
</xsl:stylesheet>
