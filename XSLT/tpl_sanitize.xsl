<?xml version="1.0"?>


<xsl:template xmlns:xsl="http://www.w3.org/1999/XSL/Transform" name="tpl_sanitize">
  <xsl:param name="text" />
  <!--first escape all original backslashes-->
  <xsl:param name="text1" select="str:replace($text,'&#92;','\&#92;')"/>

  <!--escape all quote with backslashes-->
  <xsl:param name="text2" select="str:replace($text1,'&quot;','\&quot;')"/>

  <!--finally normalize space-->
  <xsl:param name="text3" select="normalize-space($text2)"/>

  <!--output-->
  <xsl:copy-of select="$text3"/>
</xsl:template>
