<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="to-html.xsl" />

  <xsl:template match="tei:TEI">
    <div id="bibliography">
      
      <div><p style="font-size:smaller">(This is a provisional bibliography, a more complete version will be published soon.)</p></div>
      
      <div id="mss">
        <h4>Manuscripts</h4>
        <xsl:for-each select="//tei:bibl[tei:msIdentifier]">
          <xsl:sort select="descendant::tei:settlement"/>
          <p class="tei-bibl" id="{child::tei:msIdentifier/@xml:id}"><xsl:apply-templates/></p>
        </xsl:for-each>
      </div>
      
      <div id="editions">
        <h4>Editions</h4>
        <xsl:for-each select="//tei:bibl[@type='P']">
          <xsl:sort select="tei:editor[1]/tei:surname[1]"/>
          <p class="tei-bibl" id="{@xml:id}"><xsl:apply-templates/></p>
        </xsl:for-each>
      </div>
      
      <div id="secondary">
        <h4>Secondary Works</h4>
        <xsl:for-each select="//tei:bibl[@type='S']">
          <xsl:sort select="tei:author[1]/tei:surname[1]"/>
          <p class="tei-bibl" id="{@xml:id}"><xsl:apply-templates/></p>
        </xsl:for-each>
      </div>
      
      
    </div>
  </xsl:template>

  <xsl:template match="tei:author">
    <xsl:apply-templates />
  </xsl:template>
  
  <xsl:template match="tei:date">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="tei:editor">
    <xsl:apply-templates />
  </xsl:template>
  
  <xsl:template match="tei:idno">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="tei:title[(@level='j') or (@level='m')]">
    <em>
      <xsl:apply-templates />
    </em>
  </xsl:template>

  <xsl:template match="tei:hi[@rend='italic']">
    <em>
      <xsl:apply-templates />
    </em>
  </xsl:template>

  <xsl:template match="tei:hi[@rend='upright']">
    <span class="upright">
      <xsl:apply-templates />
    </span>
  </xsl:template>
  
  <xsl:template match="tei:msIdentifier">
    <xsl:apply-templates />
  </xsl:template>
  
  <xsl:template match="tei:repository">
    <xsl:apply-templates /><xsl:text>, </xsl:text>
  </xsl:template>
  
  <xsl:template match="tei:settlement">
    <xsl:apply-templates /><xsl:text>, </xsl:text>
  </xsl:template>
  
  <xsl:template match="tei:surname">
    <xsl:apply-templates />
  </xsl:template>
  
</xsl:stylesheet>
