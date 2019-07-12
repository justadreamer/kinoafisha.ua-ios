<?xml version="1.0"?>
<!DOCTYPE xsl:stylesheet [
 <!ENTITY nbsp "&#xa0;">
]>
<xsl:template name="tpl_rating_votes"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:str="http://exslt.org/strings">
  "rating":"<xsl:choose>
              <xsl:when test=".//div[@class='rating']/span[@itemprop='ratingValue']">
                <xsl:value-of select=".//div[@class='rating']/span[@itemprop='ratingValue']"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:for-each select=".//div[@class='rating']/text()[normalize-space()]"><xsl:value-of select="str:replace(normalize-space(.),'&nbsp;','')"/></xsl:for-each>
              </xsl:otherwise>
            </xsl:choose>",
  "votes_count":"<xsl:value-of select="normalize-space(.//div[@class='count-votes'])"/>"
</xsl:template>
