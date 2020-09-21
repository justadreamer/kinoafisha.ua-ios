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
    <xsl:for-each select="//ul[@class='cities__list']/li">
      <xsl:variable name="cityIdCookie">city_id=<xsl:value-of select="./a/@data-v" /></xsl:variable>
      {
        "name":"<xsl:value-of select="./a"/>",
        "request_cinema": {
          "url": "<xsl:value-of select="$cinemaURL"/>",
          "headers": {
            "Cookie": "<xsl:value-of select="$cityIdCookie" />"
          }
        },
        "request_kinoafisha": { 
          "url": "<xsl:value-of select="$kinoafishaURL"/>",
          "headers": {
            "Cookie": "<xsl:value-of select="$cityIdCookie" />"
          }
        },
        "is_default_selection":<xsl:choose><xsl:when test="./@class='current'">true</xsl:when><xsl:otherwise>false</xsl:otherwise></xsl:choose>
      }
      <xsl:if test="position()!=last()">,</xsl:if>
    </xsl:for-each>
  ]
</xsl:template>

</xsl:stylesheet>