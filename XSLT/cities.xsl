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
  {
    "cities":[
      <xsl:for-each select="//ul[@class='cities-list']/li/a">
        {
          "name":"<xsl:value-of select="."/>",
          "link":"<xsl:call-template name="tpl_prepend_url"><xsl:with-param name="href" select="./@href"></xsl:with-param></xsl:call-template>"
        }
        <xsl:if test="position()!=last()">,</xsl:if>
      </xsl:for-each>
    ]    
  }
</xsl:template>

</xsl:stylesheet>