<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
 <!ENTITY nbsp "&#xa0;">
]>

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:str="http://exslt.org/strings"
                xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:exsl="http://exslt.org/common"
                xmlns:regexp="http://exslt.org/regular-expressions">

<xsl:output method="text"/>

<xi:include href="tpl_prepend_url.xsl" />
<xi:include href="tpl_sanitize.xsl" />
<xi:include href="tpl_rating_votes.xsl" />
<xi:include href="tpl_attributes_v2.xsl" />

<xsl:template match="/">
    [
      <xsl:for-each select="//div[@id='jsc-afisha']//li[@class='movie__block']">
        {
          "title":"<xsl:call-template name="tpl_sanitize"><xsl:with-param name="text" select=".//a[@class='movie__title']"/></xsl:call-template>",
          "subtitle":"<xsl:call-template name="tpl_sanitize"><xsl:with-param name="text" select=".//p[@class='countries']"/></xsl:call-template>",
          <xsl:variable name="datasrcset">
              <xsl:value-of select=".//div[@class='photo__block']//img/@data-src" />
          </xsl:variable>

          <xsl:variable name="imgsrc">
            <xsl:choose>
              <xsl:when test="string-length($datasrcset) = 0">
                  <xsl:value-of select=".//div[@class='photo__block']//img/@src" />
              </xsl:when>
              <xsl:otherwise>
                  <xsl:value-of select="$datasrcset" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <xsl:variable name="thumbnail">
            <xsl:call-template name="tpl_prepend_url">
              <xsl:with-param name="href" select="regexp:replace(string($imgsrc), ' .*$', 'g','')"/>
            </xsl:call-template>
          </xsl:variable>

          <xsl:if test="string-length($thumbnail) > 0">
              "thumbnail":"<xsl:value-of select="$thumbnail" />",
          </xsl:if>

          "detail_parsed_request": {
            "url": "<xsl:call-template name="tpl_prepend_url"><xsl:with-param name="href" select=".//a[@class='movie__title']/@href"/></xsl:call-template>",
            "headers": {
              "Cookie": "<xsl:value-of select="$cookie" />"
            }
          },  
          <xsl:call-template name="tpl_rating_votes"/>,
          <xsl:call-template name="tpl_attributes"/>
        }
        <xsl:if test="position()!=last()">,</xsl:if>
      </xsl:for-each>
    ]
</xsl:template>

</xsl:stylesheet>
