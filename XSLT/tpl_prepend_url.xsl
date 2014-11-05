<?xml version="1.0"?>

<xsl:template xmlns:xsl="http://www.w3.org/1999/XSL/Transform" name="tpl_prepend_href_with_base_url">
  <xsl:param name="href" />
  <xsl:choose>
    <xsl:when test="starts-with($href,'/')">
      <xsl:value-of select="$baseURL"/>
    </xsl:when>
    <xsl:when test="starts-with($href,'http://')"></xsl:when>
    <xsl:otherwise><xsl:value-of select="$URL"/></xsl:otherwise>
  </xsl:choose><xsl:value-of select="$href"/>
</xsl:template>