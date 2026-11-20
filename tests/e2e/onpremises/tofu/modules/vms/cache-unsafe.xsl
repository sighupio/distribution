<?xml version="1.0"?>
<!--
  Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
  Use of this source code is governed by a BSD-style
  license that can be found in the LICENSE file.
-->
<!-- temp for testing -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output omit-xml-declaration="yes" indent="yes"/>

  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/domain/devices/disk[@device='disk']/driver">
    <xsl:copy>
      <xsl:apply-templates select="@*[name()!='cache']"/>
      <xsl:attribute name="cache">unsafe</xsl:attribute>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
