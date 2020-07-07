<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:key name="div_from_miletone" match="//tei:div[@type='1']"
        use="preceding-sibling::tei:milestone[1]/@n" />

    <!-- Project-specific XSLT for transforming TEI to
       HTML. Customisations here override those in the core
       to-html.xsl (which should not be changed). -->

    <xsl:import href="../../kiln/stylesheets/tei/to-html.xsl"/>

    <!-- GN: we turn milestones into divs which contain all the div type=1 -->
    <xsl:template match="tei:milestone[@unit = 'section']">
        <xsl:variable name="section-number"
            select="@n" />
        <div class="section"
                id="{concat('section-', @n)}"
                data-n="{@n}" data-type="{@type}">
            <xsl:for-each select="key('div_from_miletone', @n)">
                <div class="tei-div paragraph"
                    data-type="1" data-section="{$section-number}">
                    <xsl:apply-templates select="@*"/>
                    <xsl:apply-templates/>
                </div>
            </xsl:for-each>
        </div>
    </xsl:template>

    <xsl:template match="tei:div[@type = '1']">
    </xsl:template>

    <xsl:template match="tei:ab">
        <div class="ab">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <!-- xsl:template match="tei:add">
        <xsl:if test="@hand != 'LH'">
            <span class="add">
                <xsl:apply-templates select="@*" mode="data-tei" />
                <xsl:apply-templates/>
            </span>
        </xsl:if>
    </xsl:template -->

    <!--
            <div subtype="sourceNotes" type="notes" xml:id="edfr20125_sourceNotes">
                <div subtype="source" type="note" xml:id="edfr20125_00935_peach">
                    <head type="noteLabel" />
                    <p xml:id="edfr20125_00935_peach_a">Orosius, Bk 4.13</p>
                </div>
      </div>
    -->

    <xsl:template match="tei:div[@type='note']">
        <span>
            <xsl:attribute name="id"><xsl:value-of select="@xml:id" /></xsl:attribute>
            <xsl:attribute name="class">tei-note tei-type-note tei-subtype-<xsl:value-of select="@subtype" /></xsl:attribute>
            <xsl:attribute name="data-tei-subtype"><xsl:value-of select="@subtype" /></xsl:attribute>
            <span class="note-text">
                <xsl:apply-templates select="tei:p" />
            </span>
        </span>
    </xsl:template>
    <xsl:template match="tei:*[@type='note']/tei:p">
        <xsl:apply-templates />
    </xsl:template>

    <xsl:template match="tei:anchor">
        <xsl:param name="view" tunnel="yes"/>
        <xsl:if test="$view = 'interpretive'">
            <xsl:variable name="corresp" select="substring-after(@corresp, '#')"/>
            <xsl:apply-templates select="//tei:div[@xml:id = $corresp][1]"/>

            <!--
            <xsl:variable name="note-head" select="//tei:div[@xml:id = $corresp][1]/tei:head"/>
            <xsl:variable name="note-type" select="//tei:div[@xml:id = $corresp][1]/@subtype"/>

            <xsl:variable name="note-type-text">
                <xsl:choose>
                    <xsl:when test="$note-type = 'source'">
                        <xsl:text>Sources</xsl:text>
                    </xsl:when>
                    <xsl:when test="$note-type = 'trad'">
                        <xsl:text>Tradition</xsl:text>
                    </xsl:when>
                    <xsl:when test="$note-type = 'gen'">
                        <xsl:text>Note</xsl:text>
                    </xsl:when>
                    <xsl:otherwise><xsl:value-of select="$note-type"/></xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <a data-toggle="{$corresp}">
                <sup class="{concat('note tei-', $note-type)}"> </sup>
            </a>
            <div class="small reveal" id="{$corresp}" data-reveal="" data-overlay="false">
                <h3><xsl:value-of select="$note-type-text"/></h3>
                <div class="body">
                    <xsl:apply-templates select="//tei:div[@xml:id = $corresp][1]/tei:p"/>
                </div>
                <button class="close-button" data-close="" aria-label="Close note" type="button">
                    <span aria-hidden="true">&#215;</span>
                </button>
            </div>
            -->
        </xsl:if>
    </xsl:template>

    <!-- PC 21 MAR 2017 TEST TEST TEST -->
    <xsl:template match="tei:body">
        <xsl:param name="view" tunnel="yes"/>
        <div class="tei body">
            <div id="text-conventions">
                <ul>
                    <li>
                        <span class="notation">
                            <span class="tei-cb">[999ra]</span>
                        </span>
                        <span class="description">Feuillet, recto/verso, colonne</span>
                    </li>
                    <xsl:if test="$view = 'interpretive'">

                        <li>
                            <span class="notation">
                                <span class="tei-corr">abc</span>
                            </span>
                            <span class="description">Texte ajouté ou corrigé par l’éditeur moderne</span>
                        </li>

                        <li>
                            <span class="notation">
                                <span class="tei-l" data-tei-n="001">abc</span>
                            </span>
                            <span class="description">Texte en vers</span>
                        </li>

                        <li>
                            <span class="notation">
                                <div class="tei-note tei-type-note tei-subtype-source" data-tei-subtype="source">
                                    <div class="note-text">abc</div>
                                </div>
                            </span>
                            <span class="description">Note sur les sources</span>
                        </li>

                        <li>
                            <span class="notation">
                                <div class="tei-note tei-type-note tei-subtype-gen" data-tei-subtype="gen">
                                    <div class="note-text">abc</div>
                                </div>
                            </span>
                            <span class="description">Note générale</span>
                        </li>

                    </xsl:if>
                    <xsl:if test="$view = 'semi-diplomatic'">

                        <li>
                            <span class="notation">
                                [abc]
                            </span>
                            <span class="description">Résolutions d’abréviations dans le ms</span>
                        </li>

                        <li>
                            <span class="notation">
                                <span class="tei-add" data-tei-hand="E" data-tei-place="inline">abc</span>
                            </span>
                            <span class="description">Texte ajouté à la transcription par une main médiévale</span>
                        </li>

                        <li>
                            <span class="notation">
                                <span class="tei-del">abc</span>
                            </span>
                            <span class="description">Texte effacé dans le ms</span>
                        </li>

                        <li>
                            <span class="notation">
                                <span class="tei-unclear">[...]</span>
                            </span>
                            <span class="description">Lacune textuelle/Texte gratté</span>
                        </li>

                        <li>
                            <span class="notation">
                                <span class="tei-l" data-tei-n="001">abc</span>
                            </span>
                            <span class="description">Texte en vers</span>
                        </li>

                    </xsl:if>
                </ul>
            </div>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <!-- END TEST -->

    <xsl:template match="tei:c[@rend = 'R']">
        <span class="tei-c red">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="tei:cb">
        <xsl:choose>
            <xsl:when test="(@n != 'a') and (ends-with(preceding::text()[1], ' '))">
                <span class="tei-cb">[<xsl:value-of select="@n"/>] </span>
            </xsl:when>
            <xsl:when test="(@n != 'a') and (not(ends-with(preceding::text()[1], ' ')))">
                <span class="tei-cb split-word">[<xsl:value-of select="@n"/>]</span>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:choice">
        <xsl:param name="view" tunnel="yes"/>
        <xsl:choose>
            <xsl:when test="$view = 'interpretive'">
                <xsl:apply-templates mode="interpretive"/>
            </xsl:when>
            <xsl:when test="$view = 'semi-diplomatic'">
                <xsl:apply-templates mode="semi-diplomatic"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:corr" mode="semi-diplomatic">
        <!-- do nothing -->
    </xsl:template>

    <xsl:template match="tei:del">
        <xsl:param name="view" tunnel="yes"/>
        <xsl:choose>
            <xsl:when test="$view = 'interpretive'">
                <!-- do nothing -->
            </xsl:when>
            <xsl:when test="$view = 'semi-diplomatic'">
                <span class="tei-del">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:div[@type = 'notes']"/>

    <xsl:template match="tei:fw">
        <xsl:param name="view" tunnel="yes"/>
        <xsl:choose>
            <xsl:when test="$view = 'interpretive'">
                <!-- do nothing -->
            </xsl:when>
            <xsl:when test="$view = 'semi-diplomatic'">
                <span class="tei-fw">-[<xsl:if test="@type = 'quire_no'"
                        ><xsl:text>quire number: </xsl:text></xsl:if><xsl:value-of select="."
                    />]-</span>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:head[@type = 'rubric']">
        <h4 class="tei-rubric">
            <xsl:value-of select="number(substring-after(parent::tei:div/@xml:id, '_'))"/>. <xsl:text> </xsl:text>
            <xsl:apply-templates/>
        </h4>
    </xsl:template>

    <xsl:template match="tei:hi">
        <xsl:choose>
            <!-- GN: Shouldn't sup and i be in the base kiln template instead? -->
            <xsl:when test="@rend = 'sup'">
                <sup><xsl:apply-templates/></sup>
            </xsl:when>
            <xsl:when test="@rend = 'i'">
                <em>
                    <xsl:apply-templates/>
                </em>
            </xsl:when>
            <xsl:when test="@rend = 'R'">
                <span class="tei-hi red">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="@rend = 'RH'">
                <span class="tei-hi red-highlight">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="@rend = 'st'">
                <del class="struck-through">
                    <xsl:apply-templates/>
                </del>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:lb">
        <br/>
    </xsl:template>

    <xsl:template match="tei:orig" mode="interpretive">
        <!-- do nothing -->
    </xsl:template>

    <xsl:template match="tei:orig" mode="semi-diplomatic">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:pb">
        <xsl:choose>
            <xsl:when test="ends-with(preceding::text()[1], ' ')">
                <span class="tei-pb">[<xsl:value-of select="@n"/><xsl:if
                        test="following-sibling::tei:cb[1][@n = 'a']"><xsl:value-of
                            select="following-sibling::tei:cb[1]/@n"/></xsl:if>] </span>
            </xsl:when>
            <xsl:otherwise>
                <span class="tei-pb split-word">[<xsl:value-of select="@n"/><xsl:if
                        test="following-sibling::tei:cb[1][@n = 'a']"><xsl:value-of
                            select="following-sibling::tei:cb[1]/@n"/></xsl:if>]</span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:pc">
        <xsl:param name="view" tunnel="yes"/>
        <xsl:choose>
            <xsl:when test="$view = 'interpretive'">
                <xsl:if test="@rend and contains('123456789', @rend)">
                    <xsl:choose>
                        <xsl:when test="@rend = '6'"><span class="tei-pc tei-pc-rend-6">&#160;</span></xsl:when>
                        <xsl:when test="@rend = '7'"><span class="tei-pc tei-pc-rend-7">&#160;</span></xsl:when>
                    </xsl:choose>
                </xsl:if>
            </xsl:when>
            <xsl:when test="$view = 'semi-diplomatic'">
                <xsl:if test="@rend and contains('123456789', @rend)">
                    <span>
                        <xsl:choose>
                            <xsl:when test="@rend = '1'">&#x00B7;</xsl:when>
                            <xsl:when test="@rend = '2'">&#x2E35;</xsl:when>
                            <xsl:when test="@rend = '3'">&#x003F;</xsl:when>
                            <xsl:when test="@rend = '4'">[/]</xsl:when>
                            <xsl:when test="@rend = '5'">[&#x2205;]</xsl:when>
                            <xsl:when test="@rend = '6'"><span class="tei-pc tei-pc-rend-6">&#x002F;&#x002F;</span></xsl:when>
                            <xsl:when test="@rend = '7'">&#x00B6;</xsl:when>
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

    <xsl:template match="tei:ref[@type = 'bibliography']">
        <a href="{@corresp}" class="bibliography">
            <xsl:apply-templates/>
        </a>
    </xsl:template>

    <xsl:template match="tei:reg" mode="interpretive">
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
    <xsl:template match="tei:seg[@type = 'crit']" mode="interpretive">
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

    <xsl:template match="tei:seg[@type = 'semi-dip']" mode="interpretive">
        <!-- do nothing -->
    </xsl:template>
    <!-- ********************************* -->
    <!-- end -->
    <!-- ********************************* -->

    <xsl:template match="tei:seg[@type = 'stripFirstLetter']" mode="#all">
        <xsl:value-of select="translate(substring-after(., substring(., 1, 1)), '[]', '')"/>
    </xsl:template>

    <xsl:template match="tei:seg[@type = 'rubric' and @xml:id]">
        <span class="tei-rubric">
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="tei:seg[substring(@type, 1, 1) = ('1', '2', '3', '4', '5', '6')]">
        <span>
            <xsl:apply-templates select="@*"/>
            <!-- PC 01 Mar 2017 : I'm checking on this because I don't think it's relevant any more -->
            <xsl:attribute name="class">
                <xsl:text>tei-seg </xsl:text>
                <xsl:if test="(starts-with(@xml:id, 'edfr20125')) and (not(@rend = 'NR'))">first-letter-red</xsl:if>
                <xsl:if test="not(starts-with(@xml:id, 'edfr20125')) and (@rend = 'R')">first-letter-red</xsl:if>
                <xsl:if test="./tei:pc[@rend='6']"> pc-rend-6</xsl:if>
            </xsl:attribute>
            <span class="tei-seg-num">
                <xsl:value-of select="number(substring-after(substring-after(@xml:id, '_'), '_'))"/><xsl:text>. </xsl:text>
            </span>
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

    <xsl:template match="tei:sic" mode="interpretive">
        <!-- do nothing -->
    </xsl:template>

    <xsl:template match="tei:sic" mode="semi-diplomatic">
        <xsl:text> </xsl:text>
        <!-- GN: see TVOF 146, mode must be provided here, otherwise
        reg is shown in the sic within the reveal; we want of orig
        Make sure you understand XSLT spec 5.7 and 5.8 about Modes!
        -->
        <xsl:apply-templates mode="semi-diplomatic" />
    </xsl:template>

    <xsl:template match="@corresp">
        <xsl:attribute name="data-corresp">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="text()[not(ancestor::tei:div[@type = 'note'])]">
        <xsl:param name="view" tunnel="yes"/>
        <xsl:choose>
            <xsl:when test="$view = 'interpretive'">
                <xsl:value-of select="translate(., '[]', '')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Lines -->
    <xsl:template match="tei:seg[@type='explicit']">
        <xsl:call-template name="lossless-span"/>
    </xsl:template>

    <xsl:template match="tei:unclear">
        <xsl:call-template name="lossless-span"/>
    </xsl:template>

    <xsl:template match="tei:quote">
        <xsl:call-template name="lossless-span"/>
    </xsl:template>

    <xsl:template match="tei:add">
        <!-- Override the template defined in to-html-amenment.xsl -->
        <xsl:call-template name="lossless-span"/>
    </xsl:template>

    <xsl:template match="tei:corr" mode="interpretive">
        <span>
            <xsl:call-template name="lossless-attributes"/>
            <xsl:attribute name="data-sic">
                <xsl:apply-templates select="preceding-sibling::tei:sic" mode="semi-diplomatic"/>
            </xsl:attribute>
            <xsl:apply-templates />
        </span>
    </xsl:template>

    <xsl:template match="tei:note[@type='gloss']">
        <span>
            <xsl:call-template name="lossless-attributes"/>
            <span class="note-text"><xsl:apply-templates /></span>
        </span>
    </xsl:template>

    <xsl:template match="tei:lg/tei:l">
        <span>
            <xsl:call-template name="lossless-attributes"/>
            <xsl:apply-templates />
            <xsl:if test="(number(@n) mod 4) = 0"><sup class="verse-number"><xsl:value-of select="number(@n)"/></sup></xsl:if>
        </span>
    </xsl:template>

    <xsl:template match="tei:supplied">
        <xsl:call-template name="lossless-span"/>
    </xsl:template>

    <xsl:template match="tei:mod">
        <xsl:call-template name="lossless-span"/>
    </xsl:template>

    <!--
        <figure>
            <graphic url="img.jp2" />
            <head>Figure One:  The View from the Bridge</head>
            <p>a caption</p>
            <figDesc>missing</figDesc>
        </figure>

        =>

        <figure>
            <img src='img.jp2' alt='missing' title="Figure One: ..."/>
            <figcaption>caption</figcaption>
        </figure>
    -->

    <xsl:template match="tei:div//tei:figure">
        <figure>
            <!-- xsl:call-template name="lossless-attributes"/ -->
            <xsl:apply-templates />
        </figure>
    </xsl:template>

    <xsl:template match="tei:figure/tei:head">
    </xsl:template>

    <xsl:template match="tei:figure/tei:p">
        <figcaption>
            <!-- xsl:call-template name="lossless-attributes"/ -->
            <xsl:apply-templates />
        </figcaption>
    </xsl:template>

    <!-- GN: convert graphic into html -->
    <xsl:template match="tei:graphic">
        <img>
            <xsl:choose>
                <xsl:when test="ends-with(@url, '.jp2')">
                    <!-- 1x1 transparent gif b/c browser don't understand jp2 -->
                    <xsl:attribute name="src">data:image/gif;base64,R0lGODlhAQABAIAAAP///wAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==</xsl:attribute>
                    <xsl:attribute name="data-jp2"><xsl:value-of select="@url" /></xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="src"><xsl:value-of select="@url" /></xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:attribute name="alt">
                <xsl:choose>
                    <xsl:when test="../tei:figDesc">
                        <xsl:value-of select="../tei:figDesc" />
                    </xsl:when>
                    <xsl:when test="../tei:head">
                        <xsl:value-of select="../tei:head" />
                    </xsl:when>
                </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="title">
                <xsl:choose>
                    <xsl:when test="../tei:head">
                        <xsl:value-of select="../tei:head" />
                    </xsl:when>
                    <xsl:when test="../tei:figDesc">
                        <xsl:value-of select="../tei:figDesc" />
                    </xsl:when>
                </xsl:choose>
            </xsl:attribute>
        </img>
    </xsl:template>

    <!-- GN: universal TEI -> HTML conversion
    This is a systematic and lossless conversion into HTML.
    Please use this instead of custom conversion.
    The only exception is for TEI elements that have a better match in HTML.
    E.g. <tei:lb/> -> <br>
    -->

    <xsl:template name="lossless-span">
        <span>
            <xsl:call-template name="lossless-attributes"/>
            <xsl:apply-templates />
        </span>
    </xsl:template>

    <xsl:template name="lossless-attributes">
        <xsl:attribute name="class">
            <xsl:value-of select="concat('tei-', local-name())"/>
            <xsl:if test="@type"> tei-type-<xsl:value-of select="@type"/></xsl:if>
        </xsl:attribute>
        <xsl:apply-templates select="@*" mode="data-tei" />
    </xsl:template>

    <xsl:template match="@*" mode="data-tei">
        <xsl:attribute name="{concat('data-tei-', local-name())}"><xsl:value-of select="." /></xsl:attribute>
    </xsl:template>

</xsl:stylesheet>
