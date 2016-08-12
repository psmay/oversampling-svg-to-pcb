<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/2000/svg" xmlns:svg="http://www.w3.org/2000/svg" version="1.0">
	<xsl:output method="xml" omit-xml-declaration="yes"/>
	<xsl:param name="factor" select="100"/>

	<xsl:template match="/">
		<xsl:apply-templates select="/svg:svg"/>
	</xsl:template>

	<xsl:template match="/svg:svg">
		<svg>
			<xsl:apply-templates select="@*" mode="rootdim"/>
			<g transform="scale({$factor})">
				<xsl:copy-of select="."/>
			</g>
		</svg>
	</xsl:template>

	<xsl:template match="svg:svg/@height | svg:svg/@width | svg:svg/@x | svg:svg/@y" mode="rootdim">
		<xsl:attribute name="{name()}">
			<xsl:call-template name="scale-with-unit">
				<xsl:with-param name="value" select="string(.)"/>
			</xsl:call-template>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="node()|@*" mode="rootdim">
		<!-- omit -->
	</xsl:template>

	<xsl:template match="node()|@*">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template name="scale-with-unit">
		<xsl:param name="value"/>

		<xsl:variable name="_number-length">
			<xsl:call-template name="retrieve-prefix-number">
				<xsl:with-param name="str" select="$value"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="number-length" select="number($_number-length)"/>

		<xsl:choose>
			<xsl:when test="$number-length = 0">
				<xsl:value-of select="concat(string($value),'FAIL')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="sig" select="number(substring($value,1,$number-length))"/>
				<xsl:variable name="unit" select="substring($value,$number-length + 1)"/>
				<xsl:variable name="scaled" select="$sig * $factor"/>
				<xsl:value-of select="concat($scaled, $unit)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!--
		 Tests the given string for the length of the longest prefix that
		 is recognized as a number by this XPath implementation.
		 If no such prefix is found, returns 0.
	-->
	<xsl:template name="retrieve-prefix-number">
		<xsl:param name="str"/>
		<xsl:call-template name="_retrieve-prefix-number-0">
			<!--
				 ensure the parameter is a string, and add a dummy character to the end that will be removed immediately
			 -->
			<xsl:with-param name="str" select="concat(string($str),'X')"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="_retrieve-prefix-number-0">
		<xsl:param name="str"/>
		<xsl:choose>
			<xsl:when test="string($str) = ''">0</xsl:when>
			<xsl:otherwise>
				<!-- Cut the last character -->
				<xsl:variable name="w" select="substring($str,1,string-length($str)-1)"/>
				<xsl:choose>
					<xsl:when test="string(number($w)) = 'NaN'">
						<!-- This is not a number yet. Try again. -->
						<xsl:call-template name="_retrieve-prefix-number-0">
							<xsl:with-param name="str" select="$w"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<!-- Looks like a number! -->
						<xsl:value-of select="string-length($w)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>



</xsl:stylesheet>
