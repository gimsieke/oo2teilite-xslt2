<?xml version="1.0" encoding="UTF-8"?>
<!--
 #  The Contents of this file are made available subject to the terms of
 #  the GNU Lesser General Public License Version 2.1

 #  Authors:
 #  Gerrit Imsieke, Ralph Krüger, le-tex publishing services GmbH, Leipzig
 #  http://www.le-tex.de/
 #  Funded by Yanus Verlag GmbH, Hamburg
 #  http://www.yanus.de/

 #  GNU Lesser General Public License Version 2.1
 #  =============================================
 #  Copyright (C) 2009 le-tex publishing services GmbH
 #  
 #  This library is free software; you can redistribute it and/or
 #  modify it under the terms of the GNU Lesser General Public
 #  License as published by the Free Software Foundation; either
 #  version 2.1 of the License, or (at your option) any later version.
 #  
 #  This library is distributed in the hope that it will be useful,
 #  but WITHOUT ANY WARRANTY; without even the implied warranty of
 #  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 #  Lesser General Public License for more details.
 #  
 #  You should have received a copy of the GNU Lesser General Public
 #  License along with this library; if not, write to the Free Software
 #  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
-->

<xsl:stylesheet 
  version="2.0" 
  office:class="text"
  office:version="1.2"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:saxon="http://saxon.sf.net/"
  xmlns:letex="http://www.le-tex.de/namespace"
  xmlns:chart="urn:oasis:names:tc:opendocument:xmlns:chart:1.0"
  xmlns:config="urn:oasis:names:tc:opendocument:xmlns:config:1.0"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:dom="http://www.w3.org/2001/xml-events"
  xmlns:dr3d="urn:oasis:names:tc:opendocument:xmlns:dr3d:1.0"
  xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0"
  xmlns:field="urn:openoffice:names:experimental:ooo-ms-interop:xmlns:field:1.0"
  xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0"
  xmlns:form="urn:oasis:names:tc:opendocument:xmlns:form:1.0"
  xmlns:grddl="http://www.w3.org/2003/g/data-view#"
  xmlns:math="http://www.w3.org/1998/Math/MathML"
  xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0"
  xmlns:number="urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0"
  xmlns:of="urn:oasis:names:tc:opendocument:xmlns:of:1.2"
  xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
  xmlns:ooo="http://openoffice.org/2004/office"
  xmlns:oooc="http://openoffice.org/2004/calc"
  xmlns:ooow="http://openoffice.org/2004/writer"
  xmlns:rdfa="http://docs.oasis-open.org/opendocument/meta/rdfa#"
  xmlns:rpt="http://openoffice.org/2005/report"
  xmlns:script="urn:oasis:names:tc:opendocument:xmlns:script:1.0"
  xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
  xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0"
  xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
  xmlns:xforms="http://www.w3.org/2002/xforms"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsd="http://www.w3.org/2001/XMLSchema"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="chart config dc dom dr3d draw field fo form grddl letex math meta number of office ooo oooc ooow rdfa rpt saxon script style svg table tei text xforms xhtml xlink xsd xsi xsl"
  >


  <xsl:output
    method="xml"
    encoding="UTF-8"
    indent="no"
    doctype-public="-//TEI//DTD TEI Lite 1.0//EN"
    doctype-system="http://www.tei-c.org/release/xml/tei/custom/schema/dtd/teilite.dtd"
    saxon:suppress-indentation="head p"
    />


  <xsl:variable name="identity">
    <xsl:apply-templates select="/" mode="identity"/>
  </xsl:variable>


  <!-- INVOCATION: -->

  <xsl:template match="/">
    <xsl:copy-of select="$identity" />
  </xsl:template>

  <!-- uncomment xsl:copy-of select="$identity" above to get the internal representation (almost) as this stylesheet encounters it: -->
  <xsl:template match="office:document" mode="identity">
    <xsl:copy>
      <xsl:variable name="context" select="." as="node()" />
      <xsl:for-each select="distinct-values(for $n in @* return name($n))">
        <xsl:sort/>
        <node attr="{current()}">
          <xsl:value-of select="$context/@*[name() = current()]"/>
        </node>
      </xsl:for-each>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <!-- if identity export fails, you might want to change name() to local-name below and try to guess which namespace declarations are missing -->
  <xsl:template match="@*" mode="identity" priority="-0.5">
    <xsl:attribute name="{name()}" select="." />
<!--     <xsl:attribute name="{concat(local-name(), '-qualified-name')}" select="name()" /> -->
  </xsl:template>


  <!-- CATCH ALL -->

  <xsl:template match="*" mode="#all" priority="-1">
    <xsl:element name="{name()}">
      <xsl:apply-templates select="@*|*|text()|processing-instruction()|comment()" mode="#current"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="@*" mode="#all" priority="-1">
    <xsl:attribute name="{name()}" select="." />
  </xsl:template>


</xsl:stylesheet>
