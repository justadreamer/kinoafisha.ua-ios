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
<xi:include href="tpl_schedule.xsl" />
<xi:include href="tpl_rating_votes.xsl" />
<xi:include href="tpl_attributes_v2.xsl" />

<xsl:template match="/">
  {
    "title":"<xsl:call-template name="tpl_sanitize"><xsl:with-param name="text" select="//h1" /></xsl:call-template>",
    "thumbnail":"<xsl:call-template name="tpl_prepend_url"><xsl:with-param name="href" select="//div[@class='movie__photo']//img/@src"/></xsl:call-template>",
    <xsl:call-template name="tpl_rating_votes"/>,
    <xsl:call-template name="tpl_attributes"/>,
    "description":"<xsl:call-template name="tpl_sanitize"><xsl:with-param name="text" select="//div[@itemprop='description']"/></xsl:call-template>",
    "schedule":<xsl:call-template name="tpl_schedule"><xsl:with-param name="entity-name" select="'cinema'" /></xsl:call-template>
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
