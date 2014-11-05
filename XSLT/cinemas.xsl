<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:str="http://exslt.org/strings"
                xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:exsl="http://exslt.org/common"
                xmlns:regexp="http://exslt.org/regular-expressions">

<xsl:output method="text"/>

<xi:include href="tpl_prepend_url.xsl" />
<xi:include href="tpl_sanitize.xsl" />

<xsl:template match="/">
  {
    "cinemas":[
      <xsl:for-each select="//div[@class='list-cinema']/div[@class='item']">
        {
          "name":"<xsl:call-template name="tpl_sanitize"><xsl:with-param name="text" select=".//h3"/></xsl:call-template>",
          "link":"<xsl:call-template name="tpl_prepend_href_with_base_url"><xsl:with-param name="href" select=".//h3/a/@href"/></xsl:call-template>",
          "thumbnail":"<xsl:call-template name="tpl_prepend_href_with_base_url"><xsl:with-param name="href" select=".//a[@class='photo']/img/@src"/></xsl:call-template>",
          "address":"<xsl:call-template name="tpl_choose_by_prefix"><xsl:with-param name="subtree" select="exsl:node-set(.//p)"/>
          <xsl:with-param name="prefix" select="Адрес"/></xsl:call-template>",
          "phone":"",
          "rating":"",
          "votes_count":""
        }
        <xsl:if test="position()!=last()">,</xsl:if>
      </xsl:for-each>
    ]    
  }
</xsl:template>

<xsl:template name="tpl_choose_by_prefix">
  <xsl:param name="subtree" />
  <xsl:param name="prefix" />
  <xsl:for-each select="$subtree">
    <xsl:if test="regexp:test(string(.),'.*','')">
      <xsl:call-template name="tpl_sanitize"><xsl:with-param name="text" select="./span"/></xsl:call-template>
    </xsl:if>
  </xsl:for-each>
</xsl:template>

</xsl:stylesheet>