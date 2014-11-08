<?xml version="1.0"?>

<xsl:template xmlns:xsl="http://www.w3.org/1999/XSL/Transform" name="tpl_attributes">

          "attributes":[
          <xsl:for-each select=".//div[@class='text']/p">
            {
              "name":"<xsl:for-each select="./text()[normalize-space()]"><xsl:call-template name="tpl_sanitize"><xsl:with-param name="text" select="."/></xsl:call-template></xsl:for-each>",
              "value":"<xsl:call-template name="tpl_sanitize"><xsl:with-param name="text" select="./span"/></xsl:call-template>"
            }<xsl:if test="position()!=last()">,</xsl:if>
          </xsl:for-each>
          ]
</xsl:template>