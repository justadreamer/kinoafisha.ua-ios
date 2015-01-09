<?xml version="1.0"?>

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
  <xsl:variable name="kinoafishaURL"><xsl:value-of select="$baseURL" /><xsl:value-of select="'/kinoafisha'" /></xsl:variable>
  <xsl:variable name="cinemaURL"><xsl:value-of select="$baseURL" /><xsl:value-of select="'/cinema'" /></xsl:variable>
  [
    <xsl:for-each select="//ul[@class='cities-list']/li">
      <xsl:variable name="city" select="regexp:match(./a/@href,'/[^/]*/$','')"/>
      {
        "name":"<xsl:value-of select="./a"/>",
        "link_cinema":"<xsl:value-of select="$cinemaURL"/><xsl:value-of select="$city"/>",
        "link_kinoafisha":"<xsl:value-of select="$kinoafishaURL"/><xsl:value-of select="$city"/>",
        "is_default_selection":<xsl:choose><xsl:when test="./@class='current'">true</xsl:when><xsl:otherwise>false</xsl:otherwise></xsl:choose>
      }
      <xsl:if test="position()!=last()">,</xsl:if>
    </xsl:for-each>
  ]
</xsl:template>

</xsl:stylesheet>