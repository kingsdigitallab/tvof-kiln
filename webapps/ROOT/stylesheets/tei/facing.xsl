<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xmg="http://www.cch.kcl.ac.uk/xmod/global/1.0">

    <xsl:import href="../defaults.xsl" />

    <!-- Defines globals for facing pages and reads parameters from the sitemap. -->
    <xsl:param name="type" />

    <xsl:template match="/aggregation/entity" />

    <xsl:template name="text-view-html-select">
        <xsl:param name="class" required="yes" />
        <xsl:param name="selected" required="yes" />

        <xsl:variable name="title"
            select="/aggregation/entity/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title" />

        <select class="{$class}">
            <xsl:if test="$selected = '*empty*'">
                <option value="">Select a view</option>
            </xsl:if>
            
            <!-- SELECT NEEDS TO BE CHANGED BECAUSE ITS LOOKING FOR STUFF THAT IS CWEWBJ SPECIFIC AND WONT BE IN TVOF  TEI -->
            <xsl:for-each select="/aggregation/entity//tei:div[@type = 'versions']">
                <xsl:for-each select="tei:ab[@type = 'version']">
                    <xsl:variable name="id" select="tei:rs[@type = 'version']/@corresp" />
                    <xsl:variable name="msp-title"
                        select="normalize-space(tei:seg[@type = 'name'][@subtype = 'long'])" />
                    <xsl:variable name="osp-title"
                        select="normalize-space(concat($title, ' ', tei:seg[@type = 'specifier']))" />

                    <option value="{$id}">
                        <xsl:if test="$selected = $id">
                            <xsl:attribute name="selected">selected</xsl:attribute>
                        </xsl:if>
                        <xsl:choose>
                            <xsl:when test="@subtype = 'msp'">
                                <xsl:value-of select="$msp-title" />
                                <xsl:text> (M)</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$osp-title" />
                                <xsl:text> (O)</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </option>

                    <xsl:if test="@subtype = 'msp'">
                        <option value="notes-{$id}">
                            <xsl:if test="starts-with($selected, 'notes-')">
                                <xsl:attribute name="selected">selected</xsl:attribute>
                            </xsl:if>
                            <xsl:text>Notes: </xsl:text>
                            <xsl:value-of select="$msp-title" />
                        </option>
                    </xsl:if>
                </xsl:for-each>
            </xsl:for-each>
            <xsl:if test="/aggregation/entity//tei:div[(@type = 'suppCollation') and (@n='yes')]">
                <option value="expanded-collation">
                    <xsl:if test="$selected='expanded-collation'">
                        <xsl:attribute name="selected">selected</xsl:attribute>
                    </xsl:if>
                    <xsl:text>Full manuscript collation</xsl:text>
                </option>
            </xsl:if>
            <xsl:if test="/aggregation/entity//tei:div[@type = 'images']">
                <xsl:for-each
                    select="/aggregation/entity//tei:div[@type = 'images']/tei:div[@type = 'image_set']">
                    <xsl:variable name="setnum" select="substring-after(@xml:id, '-')" />
                    <option value="images-{$setnum}">
                        <xsl:if test="$selected = concat('images-', $setnum)">
                            <xsl:attribute name="selected">selected</xsl:attribute>
                        </xsl:if>
                        <xsl:text>Images: </xsl:text>
                        <xsl:value-of select="child::tei:ab[@type = 'set_label']" />
                    </option>
                </xsl:for-each>
            </xsl:if>
        </select>
    </xsl:template>

    <xsl:template name="get-text-content">
        <xsl:for-each select="/aggregation/tei:TEI">
            <xsl:variable name="context-node">
                <xsl:sequence
                    select="tei:text/tei:front/preceding::tei:milestone[parent::tei:text][not(preceding-sibling::tei:front)][@unit = 'sig']" />
                <xsl:choose>
                    <xsl:when test="$type = '-empty-'">
                        <xsl:choose>
                            <xsl:when test="tei:text/tei:front">
                                <xsl:sequence select="tei:text/tei:front" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:sequence
                                    select="tei:text/tei:body/tei:div[1]/preceding-sibling::tei:milestone[@unit = 'sig'][1]" />
                                <xsl:sequence select="tei:text/tei:body/tei:div[1]" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence
                            select="tei:text/tei:body/tei:div[@xml:id = $type]/preceding-sibling::tei:milestone[@unit = 'sig'][1]" />
                        <xsl:sequence select="tei:text/tei:body/tei:div[@xml:id = $type]" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <div id="text-toc">
                <xsl:sequence select="/aggregation/text-navigation/node()" />
            </div>
            <div id="text-content">
                <xsl:if test="$context-node/node()[@type = 'act']">
                    <div class="magellan-container" data-magellan-expedition="fixed">
                        <dl class="sub-nav">
                            <dd data-magellan-arrival="{$context-node/node()/@xml:id}">
                                <a href="#{@xml:id}">
                                    <xsl:text>Act </xsl:text>
                                    <xsl:value-of
                                        select="count(tei:text/tei:body/tei:div[@xml:id = $type]/preceding-sibling::tei:div[@type = 'act']) + 1"
                                     />
                                </a>
                            </dd>
                            <xsl:for-each
                                select="$context-node/node()//tei:div[@type = 'scene'][@xml:id]">
                                <dd data-magellan-arrival="{@xml:id}">
                                    <a href="#{@xml:id}">
                                        <xsl:text>Scene </xsl:text>
                                        <xsl:number count="tei:div[@type = 'scene']" format="1" />
                                    </a>
                                </dd>
                            </xsl:for-each>
                        </dl>
                    </div>
                </xsl:if>

                <xsl:apply-templates select="$context-node/node()">
                    <xsl:with-param name="text-type" select="tei:text/@type" tunnel="yes" />
                </xsl:apply-templates>

                <div class="notesSection">
                    <xsl:apply-templates mode="notes" select="$context-node//tei:anchor" />
                    <xsl:apply-templates mode="notes" select="$context-node//tei:note" />
                    <xsl:apply-templates mode="notes"
                        select="$context-node//tei:ref[@type = 'xref']">
                        <xsl:with-param name="tei-id" select="@xml:id" tunnel="yes" />
                        <xsl:with-param as="node()" name="text" select="tei:text" tunnel="yes" />
                    </xsl:apply-templates>
                </div>
            </div>
        </xsl:for-each>
    </xsl:template>

<xsl:template name="transcript-link">
    
    <ul class="button-group buttonseries">
        <xsl:for-each select="/aggregation/entity//tei:div[@type = 'transcriptions']/tei:ab[@type='transcription']">
            <xsl:variable name="transcript_url" select="child::tei:rs[@type='pdf']/@corresp"/>
            <xsl:variable name="transcript_title" select="child::tei:seg[@type='title']"/>
            <li>
                <a href="{$xmg:base-context-path}/static/pdf/{concat($transcript_url, '.pdf')}"
                class="small button">See also <xsl:value-of select="$transcript_title"/> [PDF]
            </a>
        </li>
        </xsl:for-each>
    </ul>
</xsl:template>

</xsl:stylesheet>
