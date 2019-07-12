<?xml version="1.0"?>

<xsl:template xmlns:xsl="http://www.w3.org/1999/XSL/Transform" name="tpl_attributes">

          "attributes":[
          <xsl:for-each select=".//div[@class='text']/p">
            {
              "name":"<xsl:for-each select="./text()[normalize-space()]"><xsl:call-template name="tpl_sanitize"><xsl:with-param name="text" select="."/></xsl:call-template></xsl:for-each>",
              "value":"<xsl:choose>
                <xsl:when test="./span">
                  <xsl:call-template name="tpl_sanitize"><xsl:with-param name="text" select="./span"/></xsl:call-template>
                </xsl:when>
                <xsl:when test="./a">
                  <xsl:call-template name="tpl_sanitize"><xsl:with-param name="text" select="./a"/></xsl:call-template>
                </xsl:when>
              </xsl:choose>"
            }<xsl:if test="position()!=last()">,</xsl:if>
          </xsl:for-each>
          ]
</xsl:template>