<?xml version="1.0"?>

<xsl:template name="tpl_attributes"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:regexp="http://exslt.org/regular-expressions">

          "attributes":[
          <xsl:for-each select=".//div[@class='movie__details']/p[not(@class = 'countries')]">
            {
              "name":"<xsl:value-of select="regexp:match(./text(),'[^:]*:','')[1]" />",
              "value":"<xsl:choose>
                <xsl:when test="./span">
                  <xsl:call-template name="tpl_sanitize"><xsl:with-param name="text" select="./span"/></xsl:call-template>
                </xsl:when>
                <xsl:when test="./a">
                  <xsl:for-each select="./a">
                    <xsl:call-template name="tpl_sanitize"><xsl:with-param name="text" select="."/></xsl:call-template>
                    <xsl:if test="position()!=last()">, </xsl:if>
                  </xsl:for-each>
                </xsl:when>
              </xsl:choose>"
            }<xsl:if test="position()!=last()">,</xsl:if>
          </xsl:for-each>
          ]
</xsl:template>