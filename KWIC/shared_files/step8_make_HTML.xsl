<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet" version="2.0">
    <xsl:output method="html"/>
    
    <xsl:param name="version">foo</xsl:param>

    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="kwiclist">
        <html>
            <head>
                <meta charset="UTF-8"/>
                <title>KWIC list</title>
                <style>
                    span[class = rubric]{
                        background-color: #F9C1C1;
                        text-align: left;
                        width: 20%;
                    }
                    table{
                        width: 100%;
                    }
                    td{
                        padding-left: 3px;
                        padding-right: 3px;
                    }
                    td[class = loc]{
                        text-align: left;
                        width: 20%;
                    }
                    td[class = prec]{
                        text-align: right;
                        width: 32%;
                    }
                    td[class = instance]{
                        color: red;
                        text-align: left;
                        padding-left: 50px;
                        width: 16%;
                    }
                    td[class = foll]{
                        text-align: left;
                        width: 32%;
                    }
                    th{
                        padding-left: 3px;
                        padding-right: 3px;
                    }</style>
            </head>

            <body>
                <div>
                    <xsl:for-each select="sublist">
                        <h2>
                            <xsl:value-of select="@key"/>
                        </h2>
                        <table>
                            <xsl:for-each select="item">

                                <xsl:sort select="lower-case(string)"/>
                                <tr>
                                    <xsl:choose>
                                        <xsl:when test="@type = 'rubric_item'">
                                            <td class="loc">
                                                <span class="rubric"><xsl:value-of
                                                  select="@location"/> (r)</span>
                                            </td>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <td class="loc">
                                                <xsl:value-of select="@location"/>
                                            </td>
                                        </xsl:otherwise>
                                    </xsl:choose>

                                    <td class="prec">
                                        <xsl:value-of select="@preceding"/>
                                        <xsl:if test="punctuation[@type='init']">
                                            <xsl:value-of select="punctuation[@type='init']"/><xsl:text> </xsl:text>
                                        </xsl:if>
                                    </td>
                                    <td class="instance">
                                        <xsl:value-of select="string"/>
                                    </td>
                                    <td class="foll">
                                        <xsl:if test="punctuation[@type='end']">
                                            <xsl:value-of select="punctuation[@type='end']"/><xsl:text> </xsl:text>
                                        </xsl:if>
                                        <xsl:value-of select="@following"/>
                                    </td>
                                </tr>
                            </xsl:for-each>
                        </table>
                    </xsl:for-each>

                </div>
            </body>
        </html>
    </xsl:template>





</xsl:stylesheet>
