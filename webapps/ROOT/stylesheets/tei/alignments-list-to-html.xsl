<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
  xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <xsl:template match="alignment" mode="alignments-index">
    <xsl:apply-templates select="tei:TEI" mode="alignments-index"/>
  </xsl:template>
  
  <xsl:template match="tei:TEI" mode="alignments-index">
    <xsl:apply-templates select="//tei:div[@type='alignments']" mode="alignments-index"/>
  </xsl:template>

  <xsl:template match="tei:div[@type='alignments']" mode="alignments-index">
    <table>
      <thead>
        <tr>
          <th></th>
          <th>Base MS</th>
          <th>Add 19669</th>
          <th>Royal</th>
          <th>Vienna</th>
        </tr>
      </thead>
      <tbody>
        <xsl:apply-templates mode="alignments-index" select="tei:div[@type='alignment']" />
      </tbody>
    </table>
  </xsl:template>

  <!--<xsl:template match="files[not(file)]" mode="alignments-index">
    <p>There are no TEI files in webapps/ROOT/content/xml/tei! Put
    some there and this page will become much more interesting.</p>
  </xsl:template>-->

  <xsl:template match="tei:div[@type='alignment']" mode="alignments-index">
    <xsl:for-each select="."><tr>
      <td id="{@xml:id}"><em><a href="{@xml:id}.html"><xsl:value-of select="@xml:id"/></a></em></td>
      <td><xsl:value-of select="substring(tei:ab[contains(tei:seg[@type='ms_name'], '20125')]/tei:seg[@type='rubric'], 1, 30)"/> ...</td>
      <td>
        <xsl:choose>
          <xsl:when test="tei:ab[contains(tei:seg[@type='ms_name'], '19669')]">
            <xsl:value-of select="substring(tei:ab[contains(tei:seg[@type='ms_name'], '19669')]/tei:seg[@type='rubric'], 1, 30)"/> ...
          </xsl:when>
          <xsl:otherwise>n/a</xsl:otherwise>
        </xsl:choose>
      </td>
      <td>
        <xsl:choose>
          <xsl:when test="tei:ab[starts-with(tei:seg[@type='ms_name'], 'Royal_')]">
            <xsl:value-of select="substring(tei:ab[starts-with(tei:seg[@type='ms_name'], 'Royal_')]/tei:seg[@type='rubric'], 1, 30)"/> ...
          </xsl:when>
          <xsl:otherwise>n/a</xsl:otherwise>
        </xsl:choose>
      </td>
      <td>
        <xsl:choose>
          <xsl:when test="tei:ab[starts-with(tei:seg[@type='ms_name'], 'Vienna')]">
            <xsl:value-of select="substring(tei:ab[starts-with(tei:seg[@type='ms_name'], 'Vienna')]/tei:seg[@type='rubric'], 1, 30)"/> ...
          </xsl:when>
          <xsl:otherwise>n/a</xsl:otherwise>
        </xsl:choose>
      </td>
    </tr></xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
