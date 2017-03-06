<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <!-- Project-specific XSLT for transforming TEI to
       HTML. Customisations here override those in the core
       to-html.xsl (which should not be changed). -->

    <xsl:import href="../../kiln/stylesheets/tei/to-html.xsl"/>

    <xsl:template match="tei:ab">
        <div class="ab">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="tei:add">
        <xsl:if test="@hand != 'LH'">
            <span class="add">
                <xsl:apply-templates/>
            </span>
        </xsl:if>
    </xsl:template>

    <xsl:template match="tei:anchor">
        <xsl:param name="view" tunnel="yes"/>
        <xsl:choose>
            <xsl:when test="$view = 'critical'">
                <xsl:variable name="corresp" select="substring-after(@corresp, '#')"/>
                <xsl:variable name="note-head" select="//tei:div[@xml:id = $corresp]/tei:head"/>
                <xsl:variable name="note-type" select="//tei:div[@xml:id = $corresp]/@subtype"/>
                <xsl:variable name="note-type-text">
                    <xsl:choose>
                        <xsl:when test="$note-type='gen'">General note:</xsl:when>
                        <xsl:when test="$note-type='source'">Source note:</xsl:when>
                        <xsl:when test="$note-type='trad'">Tradition note:</xsl:when>
                    </xsl:choose> 
                </xsl:variable>
                
                <a data-toggle="{$corresp}">
                    <sup class="{concat('note tei-', $note-type)}">
                    </sup>
                </a>
                <div class="small reveal" id="{$corresp}" data-reveal="" data-overlay="false">
                    <xsl:value-of select="$note-type-text"/> <xsl:apply-templates select="//tei:div[@xml:id = $corresp]/tei:p"/>
                    <button class="close-button" data-close="" aria-label="Close note" type="button">
                        <span aria-hidden="true">&#215;</span>
                    </button>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <!-- do nothing -->
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>

    <xsl:template match="tei:c[@rend = 'R']">
        <span class="tei-initial">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="tei:cb">
        <xsl:choose>
            <xsl:when test="(@n != 'a') and (ends-with(preceding::text()[1], ' '))">
                <span class="tei-cb">[<xsl:value-of select="@n"/>] </span>
            </xsl:when>
            <xsl:when test="(@n != 'a') and (not(ends-with(preceding::text()[1], ' ')))">
                <span class="tei-cb" style="color:teal;">-[<xsl:value-of select="@n"/>]-</span>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:choice">
        <xsl:param name="view" tunnel="yes"/>
        <xsl:choose>
            <xsl:when test="$view = 'critical'">
                <xsl:apply-templates mode="critical"/>
            </xsl:when>
            <xsl:when test="$view = 'semi-diplomatic'">
                <xsl:apply-templates mode="semi-diplomatic"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:corr" mode="critical">
        <xsl:variable name="myID" select="generate-id()"/>
        <xsl:apply-templates/><a data-toggle="{$myID}"><sup class="tei-corr"/></a>
        
        <div class="small reveal" id="{$myID}" data-reveal="" data-overlay="false">
            <em>sic</em>: <xsl:apply-templates select="preceding-sibling::tei:sic" mode="semi-diplomatic"/>
            <button class="close-button" data-close="" aria-label="Close note" type="button">
                <span aria-hidden="true">&#215;</span>
            </button>
        </div>
    </xsl:template>

    <xsl:template match="tei:corr" mode="semi-diplomatic">
        <!-- do nothing -->
    </xsl:template>

    <xsl:template match="tei:del">
        <xsl:param name="view" tunnel="yes"/>
        <xsl:choose>
            <xsl:when test="$view = 'critical'">
                <!-- do nothing -->
            </xsl:when>
            <xsl:when test="$view = 'semi-diplomatic'">
                <span class="tei-del">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:div[@type = '1']">
        <div>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="tei:div[@type = 'notes']"/>
    
    <xsl:template match="tei:fw">
        <xsl:param name="view" tunnel="yes"/>
        <xsl:choose>
            <xsl:when test="$view = 'critical'">
                <!-- do nothing -->
            </xsl:when>
            <xsl:when test="$view = 'semi-diplomatic'">
                <span class="tei-fw">-[<xsl:if test="@type='quire_no'"><xsl:text>quire number: </xsl:text></xsl:if><xsl:value-of select="."/>]-</span>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:head[@type = 'rubric']">
        <h4 class="tei-rubric">
                <xsl:value-of select="number(substring-after(parent::tei:div/@xml:id, '_'))"/>.
                <xsl:text> </xsl:text>
            <xsl:apply-templates/>
        </h4>
    </xsl:template>
    
    <xsl:template match="tei:hi">
        <xsl:choose>
            <xsl:when test="@rend = 'i'">
                <em>
                    <xsl:apply-templates/>
                </em>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:l">
        <br/>
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:lb">
        <br/>
    </xsl:template>

    <xsl:template match="tei:orig" mode="critical">
        <!-- do nothing -->
    </xsl:template>

    <xsl:template match="tei:orig" mode="semi-diplomatic">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:pb">
        <xsl:choose>
            <xsl:when test="ends-with(preceding::text()[1], ' ')">
                <span class="tei-pb" style="color:teal;">[<xsl:value-of select="@n"/><xsl:if
                        test="following-sibling::tei:cb[1][@n = 'a']"><xsl:value-of
                            select="following-sibling::tei:cb[1]/@n"/></xsl:if>] </span>
            </xsl:when>
            <xsl:otherwise>
                <span class="tei-pb" style="color:teal;">-[<xsl:value-of select="@n"/><xsl:if
                        test="following-sibling::tei:cb[1][@n = 'a']"><xsl:value-of
                            select="following-sibling::tei:cb[1]/@n"/></xsl:if>]-</span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:pc">
        <xsl:param name="view" tunnel="yes"/>
        <xsl:choose>
            <xsl:when test="$view = 'critical'">
                <xsl:if test="@rend and contains('123456789', @rend)">
                    <!-- do nothing -->
                </xsl:if>
            </xsl:when>
            <xsl:when test="$view = 'semi-diplomatic'">
                <xsl:if test="@rend and contains('123456789', @rend)">
                    <span>
                        <xsl:choose>
                            <xsl:when test="@rend = '1'">&#x00B7;</xsl:when>
                            <xsl:when test="@rend = '2'">&#x061B;</xsl:when>
                            <xsl:when test="@rend = '3'">&#x003F;</xsl:when>
                            <xsl:when test="@rend = '4'">[/]</xsl:when>
                            <xsl:when test="@rend = '5'">[&#x2205;]</xsl:when>
                        </xsl:choose>
                    </span>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise><!-- do nothing --></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:persName">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:q">
        <span>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="tei:ref[@type = 'bibliography']/@corresp">
        <xsl:attribute name="data-biblio-corresp">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="tei:reg" mode="critical">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:reg" mode="semi-diplomatic">
        <!-- do nothing -->
    </xsl:template>

    <xsl:template match="tei:seg[@type = 'ms_name']">
        <span>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
            <xsl:text> </xsl:text>
        </span>
    </xsl:template>

    <xsl:template match="tei:seg[@type = 'location']">
        <span>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
            <xsl:text> </xsl:text>
        </span>
    </xsl:template>

    <!-- ********************************* -->
    <!-- critical / semi-diplomatic segs -->
    <!-- ********************************* -->
    <xsl:template match="tei:seg[@type = 'crit']" mode="critical">
        <span>
            <xsl:if test="@subtype = 'toUpper'">
                <xsl:attribute name="class">tei-critToUpper</xsl:attribute>
            </xsl:if>
            <xsl:if test="@subtype = 'toLower'">
                <xsl:attribute name="class">tei-critToLower</xsl:attribute>
            </xsl:if>
            <xsl:if test="@subtype = 'toSup'">
                <xsl:attribute name="class">tei-critToSup</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="tei:seg[@type = 'crit']" mode="semi-diplomatic">
        <!-- do nothing -->
    </xsl:template>

    <xsl:template match="tei:seg[@type = 'semi-dip']" mode="semi-diplomatic">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:seg[@type = 'semi-dip']" mode="critical">
        <!-- do nothing -->
    </xsl:template>
    <!-- ********************************* -->
    <!-- end -->
    <!-- ********************************* -->

    <xsl:template match="tei:seg[@type = 'stripFirstLetter']">
        <xsl:value-of select="translate(substring-after(., substring(., 1, 1)), '[]', '')"/>
    </xsl:template>

    <xsl:template match="tei:seg[@type = 'rubric' and @xml:id]">
        <span class="tei-rubric">
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="tei:seg[@type = ('1', '2', '3', '4', '5')]">
        <span class="tei-seg-num">
            <xsl:value-of select="number(substring-after(substring-after(@xml:id, '_'), '_'))"/>.
            <xsl:text> </xsl:text>
        </span>
        <span>
            <xsl:apply-templates select="@*"/>
            <!-- PC 01 Mar 2017 : I'm checking on this because I don't think it's relevant any more -->
            <!--<xsl:if test="(starts-with(@xml:id, 'edfr20125')) and (not(@rend = 'NR'))">
                <xsl:attribute name="class">seg1rfl</xsl:attribute>
            </xsl:if>-->
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="tei:seg[@type = 'textual-unit-2']">
        <span>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="tei:seg[@type = 'textual-unit-3-moralisation']">
        <br/>
        <span>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!-- if the seg has no type, do nothing -->
    <xsl:template match="tei:seg">
        <!-- do nothing -->
    </xsl:template>

    <xsl:template match="tei:sic" mode="critical">
        <!-- do nothing -->
    </xsl:template>

    <xsl:template match="tei:sic" mode="semi-diplomatic">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:unclear">
        <xsl:variable name="myID" select="generate-id()"/>
        <xsl:apply-templates/><a data-toggle="{$myID}"><sup class="tei-unclear"/></a>
        
        <div class="small reveal" id="{$myID}" data-reveal="" data-overlay="false">
            text unclear <xsl:if test="@reason">due to  <xsl:value-of select="@reason"/></xsl:if>
            <button class="close-button" data-close="" aria-label="Close note" type="button">
                <span aria-hidden="true">&#215;</span>
            </button>
        </div>
    </xsl:template>

    <xsl:template match="@corresp">
        <xsl:attribute name="data-corresp">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="text()">
        <xsl:param name="view" tunnel="yes"/>
        <xsl:choose>
            <xsl:when test="$view = 'critical'">
                <xsl:value-of select="translate(., '[]', '')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>





</xsl:stylesheet>
