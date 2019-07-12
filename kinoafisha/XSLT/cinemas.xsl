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

<xsl:template match="/">
  {
    "city_name":"<xsl:call-template name="tpl_sanitize"><xsl:with-param name="text" select="//span[@class='select' and @id='cities']/span/span"/></xsl:call-template>",
    "cinemas":[
      <xsl:for-each select="//div[@class='js-cont-cinema']/div[@class='item']">
        {
          "name":"<xsl:call-template name="tpl_sanitize"><xsl:with-param name="text" select=".//h3"/></xsl:call-template>",
          "link":"<xsl:call-template name="tpl_prepend_url"><xsl:with-param name="href" select=".//h3/a/@href"/></xsl:call-template>",
          "thumbnail":"<xsl:call-template name="tpl_prepend_url"><xsl:with-param name="href" select=".//a[@class='photo']/img/@src"/></xsl:call-template>",
          "address":"<xsl:call-template name="tpl_choose_by_prefix_regexp"><xsl:with-param name="subtree" select="exsl:node-set(.//p)"/>
          <xsl:with-param name="prefix" select="'^Адрес.*'"/></xsl:call-template>",
          "phone":"<xsl:call-template name="tpl_choose_by_prefix_regexp"><xsl:with-param name="subtree" select="exsl:node-set(.//p)"/>
          <xsl:with-param name="prefix" select="'^Телефон.*'"/></xsl:call-template>",
          <xsl:call-template name="tpl_rating_votes"/>
        }
        <xsl:if test="position()!=last()">,</xsl:if>
      </xsl:for-each>
    ]    
  }
</xsl:template>

<xsl:template name="tpl_choose_by_prefix_regexp">
  <xsl:param name="subtree" />
  <xsl:param name="prefix" />
  <xsl:for-each select="$subtree">
    <xsl:if test="regexp:test(string(.),$prefix,'i')">
      <xsl:call-template name="tpl_sanitize"><xsl:with-param name="text" select="./span"/></xsl:call-template>
    </xsl:if>
  </xsl:for-each>
</xsl:template>

</xsl:stylesheet>