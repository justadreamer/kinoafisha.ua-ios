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
<xi:include href="tpl_attributes.xsl" />

<xsl:template match="/">
    [
      <xsl:for-each select="//div[@class='item' and .//h3]">
        {
          "title":"<xsl:call-template name="tpl_sanitize"><xsl:with-param name="text" select=".//h3"/></xsl:call-template>",
          "subtitle":"<xsl:call-template name="tpl_sanitize"><xsl:with-param name="text" select=".//div[@class='countries']"/></xsl:call-template>",
          "thumbnail":"<xsl:call-template name="tpl_prepend_url"><xsl:with-param name="href" select=".//a[contains(@class,'photo')]/img/@src"/></xsl:call-template>",
          "detail_url":"<xsl:call-template name="tpl_prepend_url"><xsl:with-param name="href" select=".//h3//a/@href"/></xsl:call-template>",
          <xsl:call-template name="tpl_rating_votes"/>,
          <xsl:call-template name="tpl_attributes"/>
        }
        <xsl:if test="position()!=last()">,</xsl:if>
      </xsl:for-each>
    ]
</xsl:template>

</xsl:stylesheet>