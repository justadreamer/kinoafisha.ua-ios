<?xml version="1.0"?>

<xsl:template xmlns:xsl="http://www.w3.org/1999/XSL/Transform" name="tpl_schedule">
  <xsl:param name="entity-name" />
  [
        <xsl:for-each select="//table/tbody/tr[./td/@class='cinema' and contains(./td[@class='cinema'],'{{') = 0]">
            {
              <xsl:choose>
                <xsl:when test="count(./td)=1">
                  "type":"<xsl:value-of select="$entity-name"/>",
                  "title":"<xsl:call-template name="tpl_sanitize"><xsl:with-param name="text" select="./td[@class='cinema']" /></xsl:call-template>",
                  "detail_parsed_request": {
                    "url": "<xsl:call-template name="tpl_prepend_url"><xsl:with-param name="href" select="./td//a/@href"/></xsl:call-template>",
                    "headers": {
                      "Cookie": "<xsl:value-of select="$cookie" />"
                    }
                  }
                </xsl:when>
                <xsl:when test="count(./td)>1">
                  "type":"cinema_room",
                  "title":"<xsl:call-template name="tpl_sanitize"><xsl:with-param name="text" select="./td[@class='cinema']" /></xsl:call-template>",
                  "show_times":[
                    <xsl:for-each select="./td[@class='sessions']/*">
                      "<xsl:value-of select="."/>"<xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>
                  ]
                </xsl:when>
              </xsl:choose>
            }<xsl:if test="position()!=last()">,</xsl:if>
        </xsl:for-each>
      ]
</xsl:template>