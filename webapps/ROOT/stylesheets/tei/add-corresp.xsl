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
      <xd:p><xd:b>Created on:</xd:b>Aug 2018</xd:p>
      <xd:p><xd:b>Author:</xd:b> geoffroy noel</xd:p>
      <xd:p>This stylesheet tries to match a DIV xml:id value to an xml:id on a
        DIV type="alignment" in TVOF_para_alignment.xml; if successful it then
        gathers relevant corresp values from the AB children of the DIV
        type="alignment". These values are then used to create a corresp
        attribute in the original DIV in the transcription file. Everything else
        is left unchanged.</xd:p>
    </xd:desc>
  </xd:doc>

    <!--
        <div type="alignment" xml:id="fr20125_00395">
            <ab corresp="#edfr20125_00395" type="ms_instance" computed-corresp="#edfr20125_00395">
                [...]
            <ab corresp="#edRoyal20D1_00002_01 #edRoyal20D1_00002_07" type="ms_instance" computed-corresp="#edRoyal20D1_00002_01 
                #edRoyal20D1_00002_02 #edRoyal20D1_00002_03 #edRoyal20D1_00002_04 #edRoyal20D1_00002_05 #edRoyal20D1_00002_06 #edRoyal20D1_00002_07">
                <seg type="ms_name">Royal_20_D_1</seg>
                [...]
                
        +

        <div n="89rb" type="1" xml:id="edfr20125_00395">
                
        =>

        <div n="89rb" type="1" xml:id="edfr20125_00395" data-corresp="#edRoyal20D1_00002_01 #edRoyal20D1_00002_07">
        
        OR
        
        <seg xml:id="edRoyal20D1_00002_07">
        
        =>
        
        <seg xml:id="edRoyal20D1_00002_07" data-corresp="#edfr20125_00395">                
        
    -->

    <xsl:key name="ab_from_ref_id" match="/aggregation/alignments//tei:div[@type = 'alignment']/tei:ab[not(contains(@computed-corresp, ../@xml:id))]" use="concat('ed', ../@xml:id)"/>
    <xsl:key name="alignment_from_computed_corresp" match="/aggregation/alignments//tei:div[@type = 'alignment']/tei:ab" use="tokenize(@computed-corresp, ' ')"/>

    <xsl:template match="/aggregation/alignments" />

    <xsl:template match="tei:div">
        <!-- TODO: review the assumption about tei:div only -->
        <xsl:variable name="corresp" select="key('ab_from_ref_id', @xml:id)/@corresp"/>
        <xsl:copy>
            <xsl:if test="$corresp">
                <xsl:attribute name="corresp">
                    <xsl:value-of select="$corresp" />
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>

    <xsl:template match="tei:seg">
        <!-- TODO: review the assumption about tei:seg only -->
        <xsl:variable name="corresp" select="key('alignment_from_computed_corresp', concat('#', @xml:id))"/>
        <xsl:copy>
            <xsl:if test="$corresp">
                <xsl:attribute name="corresp">
                    <xsl:for-each select="$corresp/../@xml:id"><xsl:value-of select="concat('#ed', .)"/></xsl:for-each>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>

    <xsl:template match="tei:* | @* | processing-instruction() | comment()">
      <xsl:copy>
        <xsl:apply-templates
          select="@*|node()" />
      </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
