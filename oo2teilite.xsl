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
  <!DOCTYPE xsl:stylesheet [
 
      <!-- elements matching this XPath expression are considered to be footnotes -->
      <!ENTITY  footnote "tei:note[@type='footnote']">
      <!ENTITY  note "tei:note">
 
      <!-- TEI elements which are destined for getting a number, i.e. represent a piece of text of reasonable size;
           please note that note-elements and their children are numbered separately (see below) -->
      <!ENTITY  numberedMainTextElements
          "   /tei:TEI/tei:text/tei:front/tei:titlePage/tei:docTitle
            | /tei:TEI/tei:text/tei:front/tei:titlePage/tei:docAuthor
            | /tei:TEI/tei:text/tei:body//tei:div/tei:head[not( ancestor::&note; or . = '')]
            | /tei:TEI/tei:text/tei:body//tei:lg[not( ancestor::&note;)]
            | /tei:TEI/tei:text/tei:body//tei:p/tei:table[not( ancestor::&note;)]
            | /tei:TEI/tei:text/tei:body//tei:p/tei:quote[not( ancestor::&note;)]
            | /tei:TEI/tei:text/tei:body//tei:p[not( ancestor::&note; or ancestor::tei:table or . = '')]
            | /tei:TEI/tei:text/tei:body//tei:table
          "
      >
 
      <!-- TEI elements within footnotes which are destined for getting a number, i.e. represent a piece of text of reasonable size -->
      <!-- We expect all text nodes, which are "decendants" of &footnote;, to be embedded in tei:p (or another parent element listed below). -->
      <!ENTITY  numberedFootnoteDescendant
          " *[   self::tei:p[normalize-space( string-join( .//text(), ''))]
               | self::tei:div/tei:head
               | self::tei:lg
               | self::tei:table
               | self::tei:quote
             ]
          "
      >

      <!-- TEI elements which are not destined for getting a number, i.e.:
             (1) parts of the tree, which never get a number
             (2) all descendants of &numberedMainTextElements; and &footnote;//&numberedFootnoteDescendant; except of <p> (because this may, e.g., contain a <table>/<quote> and so on
             (3) elements which are not covered by rule (2) (e.g. the descendants of <p>, which do not get a number)
      -->
      <!ENTITY  unnumberedElements
          "   (: case (1) :)
              /tei:TEI/tei:teiHeader | /tei:TEI/tei:teiHeader//*	(: in order to be able to use the expression in match-patterns, you must not use the descencdant-or-self-axis here :)
            | *[ancestor::tei:note[@type='internal']]
              (: case (2) :)
            | /tei:TEI/tei:text/tei:front/tei:titlePage/tei:docTitle//*
            | /tei:TEI/tei:text/tei:front/tei:titlePage/tei:docAuthor//*
            | /tei:TEI/tei:text/tei:front/tei:titlePage/tei:docDate
            | /tei:TEI/tei:text/tei:body//tei:div/tei:head//*[not( ancestor-or-self::&footnote;)]
            | /tei:TEI/tei:text/tei:body//tei:table//*
              (: case (2) with restrictions :)
            | /tei:TEI/tei:text/tei:body//tei:lg/tei:l
              (: case (3) :)
            | //tei:hi
          "
      >
 
        <!-- Processing modes where the default transformation will be identity -->
      <!ENTITY  catchAllModes
          "resolve-styles
           group-styles
           clean-group-styles
           exclude
           hierarchize 
           verse
           letter
           main
           join-segs
           anonymous-divs
           add-linear-numbering
           splitParas_reassignRandnummern
           add-subnumbering-for-split-paras"
       >
 
  ]>
 
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
      saxon:suppress-indentation="head p l"
      />
 
    <!-- customize me -->
    <xsl:variable name="heading-markup" select="('Heading 1', 'Heading 2', 'Heading 3', 'Heading 4')"/>
 
    <letex:style-mapping>
      <letex:style att="style-name" attval="Y: Hervorhebung Kursiv" elt="seg" map="hi" />
      <letex:style att="style-name" attval="Emphasis" elt="seg" map="hi" />
      <letex:style att="style-name" attval="Footnote" elt="p" map="" />
      <letex:style att="style-name" attval="Standard" elt="p" map="" />
    </letex:style-mapping>
 
    <!-- /customize me -->

    <xsl:param name="debug" />
 
    <xsl:function name="letex:map-style" as="xsd:string?">
      <xsl:param name="elt" as="xsd:string" />
      <xsl:param name="att" as="xsd:string" />
      <xsl:param name="attval" as="xsd:string" />
      <xsl:value-of 
        select="document('')//letex:style-mapping/letex:style[
                  (@att eq $att)
                  and ($attval = (if ($att eq 'style-name') then letex:quote-style-name($attval) else $attval)) 
                  and (@elt = $elt)
                ]/@map" />
    </xsl:function>
 
    <!-- PROCESSING PIPELINE: -->
 
    <xsl:variable name="resolve-styles">
      <xsl:apply-templates select="/" mode="resolve-styles"/>
    </xsl:variable>
 
    <xsl:variable name="group-styles">
      <xsl:apply-templates select="$resolve-styles" mode="group-styles"/>
    </xsl:variable>
 
    <xsl:variable name="clean-group-styles">
      <xsl:apply-templates select="$group-styles" mode="clean-group-styles"/>
    </xsl:variable>
 
    <xsl:variable name="hierarchize">
      <TEI>
        <teiHeader>
          <fileDesc>
            <titleStmt>
              <title></title>
              <author></author>
            </titleStmt>
            <publicationStmt>
              <distributor>
                <address>
                  <addrLine>
                    <name type="organisation"></name>
                  </addrLine>
                  <addrLine>
                    <name type="place"></name>
                  </addrLine>
                  <addrLine></addrLine>
                </address>
              </distributor>
              <idno type="book"></idno>
              <date></date>
              <pubPlace></pubPlace>
              <publisher></publisher>
            </publicationStmt>
            <sourceDesc>
              <p></p>
            </sourceDesc>
          </fileDesc>
        </teiHeader>
        <text>
          <body>
            <xsl:choose>
              <xsl:when test="$clean-group-styles/office:document/office:body/office:text/text:h/@text:outline-level">
                <xsl:sequence select="letex:hierarchize-by-outline($clean-group-styles/office:document/office:body/office:text/*, min($clean-group-styles/office:document/office:body/office:text/text:h/@text:outline-level))" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:sequence select="letex:hierarchize($clean-group-styles/office:document/office:body/office:text/*, $heading-markup)" />
              </xsl:otherwise>
            </xsl:choose>
          </body>
        </text>
      </TEI>
    </xsl:variable>
 
    <xsl:variable name="verse">
      <xsl:apply-templates select="$hierarchize" mode="verse"/>
    </xsl:variable>
 
    <xsl:variable name="letter">
      <xsl:apply-templates select="$verse" mode="letter"/>
    </xsl:variable>
 
    <xsl:variable name="main">
      <xsl:apply-templates select="$letter" mode="main"/>
    </xsl:variable>
 
<!--     <xsl:variable name="join-segs"> -->
<!--       <xsl:apply-templates select="$main" mode="join-segs"/> -->
<!--     </xsl:variable> -->
 
    <xsl:variable name="anonymous-divs">
      <xsl:apply-templates select="$main" mode="anonymous-divs"/>
    </xsl:variable>
 
    <xsl:variable name="add-linear-numbering">
      <xsl:apply-templates select="$anonymous-divs" mode="add-linear-numbering"/>
    </xsl:variable>
 
    <xsl:variable name="add-subnumbering-for-split-paras">
      <xsl:apply-templates select="$add-linear-numbering" mode="add-subnumbering-for-split-paras"/>
    </xsl:variable>
 
    <!-- Some people dislike this brute-force, sequential processing. For good reasons (waste of memory, 
         lack of elegance, reliance on a default catch-all identity transformation).
         But this separation of concerns (one concern per processing mode) helps you keep the code modular 
         in cases where an external chaining of transformations isn't practicable, where a "closed form" 
         representation of all rules in a single mode is too complex or where an intelligent processing
         of subtrees in adequate modes would be too – ehm – intelligent. 
         Of course it makes sense to process only a subtree for which a certain mode makes sense in that
         mode, in contrast to processing the whole document in that mode. But you must admit that, for 
         debugging purposes, it's nice to be able to export the whole document as it looks before being
         processed in a certain mode. Therefore the brute-force, global-variable, identity-default 
         transformations.
         -->
 
 
    <!-- INVOCATION: -->
 
    <xsl:template match="/">
      <xsl:if test="boolean($debug)">
        <xsl:result-document  href="debug.05.resolve-styles.xml">
          <xsl:sequence  select="$resolve-styles"/>
        </xsl:result-document>
        <xsl:result-document  href="debug.10.clean-group-styles.xml">
          <xsl:sequence  select="$clean-group-styles"/>
        </xsl:result-document>
        <xsl:result-document  href="debug.20.hierarchize.xml">
          <xsl:sequence  select="$hierarchize"/>
        </xsl:result-document>
        <xsl:result-document  href="debug.30.letter.xml">
          <xsl:sequence  select="$letter"/>
        </xsl:result-document>
        <xsl:result-document  href="debug.40.main.xml">
          <xsl:sequence  select="$main"/>
        </xsl:result-document>
        <xsl:result-document  href="debug.50.anonymous-divs.xml">
          <xsl:sequence  select="$anonymous-divs"/>
        </xsl:result-document>
        <xsl:result-document  href="debug.60.add-linear-numbering.xml">
          <xsl:sequence  select="$add-linear-numbering"/>
        </xsl:result-document>
        <xsl:result-document  href="debug.62.add-subnumbering-for-split-paras.xml">
          <xsl:sequence  select="$add-subnumbering-for-split-paras"/>
        </xsl:result-document>
      </xsl:if>
      <xsl:copy-of select="$add-subnumbering-for-split-paras" />
    </xsl:template>


  <!-- HEADING HIERARCHIES -->

  <!-- Case A: No outline levels are specified in the document; headings are plain paragraphs with certain markup: -->

  <xsl:function name="letex:hierarchize" as="node()*">
    <xsl:param name="nodes" as="node()*" />
    <xsl:param name="heading-markup" as="xsd:string*" />
    <xsl:choose>
      <xsl:when test="count($heading-markup) eq 0">
        <xsl:sequence select="$nodes" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="new-heading-markup" select="letex:topmost-heading-markup($nodes, $heading-markup)" />
        <xsl:choose>
          <xsl:when test="count($new-heading-markup) gt 0">
            <xsl:for-each-group select="$nodes" group-starting-with="*[letex:satisfies-heading-markup(., $new-heading-markup[1])]">
              <xsl:choose>
                <xsl:when test="letex:satisfies-heading-markup(current-group()[1], $new-heading-markup[1])">
                  <xsl:text>&#xa;</xsl:text>
                  <div type="{replace($new-heading-markup[1], '\s+', '_')}">
<!--                     <xsl:copy-of select="current-group()[1]/@*" /> -->
                    <head>
                      <xsl:copy-of select="current-group()[1]/node()" />
                    </head>
                    <xsl:sequence select="letex:hierarchize(current-group()[position() gt 1], $new-heading-markup[position() gt 1])" />
                  </div>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:sequence select="letex:hierarchize(current-group(), $new-heading-markup[position() gt 1])" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each-group>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="$nodes" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="letex:quote-style-name" as="xsd:string">
    <xsl:param name="style-name" as="xsd:string" />
    <xsl:sequence select="string-join(
                            for $i in (1 to string-length($style-name)) 
                            return 
                            if (not(matches(substring($style-name, $i, 1), '\w'))) then
                              concat(
                                '_', 
                                replace(
                                  substring(lower-case(string(
                                    saxon:string-to-hexBinary(
                                      substring($style-name, $i, 1),
                                      'UTF16'
                                    ))), 
                                    5
                                  ),
                                  '^0+',
                                  ''
                                ),
                                '_'
                              )
                              else substring($style-name, $i, 1)
                          , '')" />
  </xsl:function>


  <xsl:function name="letex:has-style" as="xsd:boolean">
    <xsl:param name="node" as="node()" />
    <xsl:param name="style-family" as="xsd:string" />
    <xsl:param name="style-name" as="xsd:string" />
    <xsl:sequence select="boolean($node/@text:style-name eq letex:quote-style-name($style-name))" />
  </xsl:function>

  <xsl:function name="letex:satisfies-heading-markup" as="xsd:boolean">
    <xsl:param name="node" as="node()" />
    <xsl:param name="heading-markup" as="xsd:string" />
    <xsl:sequence select="boolean($node/self::text:p[letex:has-style(., 'paragraph', $heading-markup)])" />
  </xsl:function>

  <xsl:function name="letex:topmost-heading-markup" as="xsd:string*">
    <xsl:param name="nodes" as="node()*" />
    <xsl:param name="heading-markup" as="xsd:string*" />
    <xsl:choose>
      <xsl:when test="count($heading-markup) eq 0">
        <xsl:sequence select="()" />
      </xsl:when>
      <xsl:when test="some $n in $nodes satisfies (letex:satisfies-heading-markup($n, $heading-markup[1]))">
        <xsl:sequence select="$heading-markup" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="letex:topmost-heading-markup($nodes, $heading-markup[position() gt 1])" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- We don't need all this stuff if there are proper headings with outline-level attributes. -->

  <!-- Case B: Outline levels are specified with the document's headings: -->

  <xsl:function name="letex:hierarchize-by-outline" as="node()*">
    <xsl:param name="nodes" as="node()*" />
    <xsl:param name="outline-level" as="xsd:double*" />
    <xsl:choose>
      <xsl:when test="empty($outline-level)">
        <xsl:sequence select="$nodes" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each-group select="$nodes" group-starting-with="text:h[@text:outline-level = $outline-level]">
          <xsl:choose>
            <xsl:when test="current-group()[1]/@text:outline-level = $outline-level">
              <xsl:text>&#xa;</xsl:text>
              <div type="Heading_{$outline-level}">
                <head>
                  <xsl:copy-of select="current-group()[1]/node()" />
                </head>
                <xsl:variable name="new-nodes" select="current-group()[position() gt 1]" as="node()*" />
                <xsl:sequence select="letex:hierarchize-by-outline($new-nodes, min($new-nodes/@text:outline-level))" />
              </div>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="letex:hierarchize-by-outline(current-group(), min(current-group()/@text:outline-level))" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each-group>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>


  <!-- RESOLVE STYLES -->

  <!-- collateral unicode normalization (convert to composed forms) -->
  <xsl:template match="text()" mode="resolve-styles">
    <xsl:value-of select="normalize-unicode(.)"/>
  </xsl:template>

  <xsl:template match="@text:style-name" mode="resolve-styles">
    <xsl:choose>
      <xsl:when test=". = /office:document/office:styles/style:style/@style:name">
        <xsl:attribute name="style-name" select="." />
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="/office:document/office:automatic-styles/style:style[@style:name = current()]" mode="resolve-style">
          <xsl:with-param name="context" select=".." />
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<!--   <xsl:template match="@style:style-name" mode="resolve-styles-details"> -->
<!--     <xsl:attribute name="loc" select="'st'" /> -->
<!--     <xsl:apply-templates select="/office:document/office:styles/style:style[@style:name = current()]" mode="resolve-style"/> -->
<!--     <xsl:attribute name="loc" select="'ed'" /> -->
<!--   </xsl:template> -->

<!--   <xsl:function name="resolve-style-absolutely" as="node()"> -->
<!--     <xsl:param name="text-elt" as="node()" /> -->
<!--     <xsl:param name="parent-text-elt" as="node()?" /> -->
<!--     <xsl:variable name="automatic-style" select="/office:document/office:automatic-styles/style:style[@style:name = current()]" /> -->
<!--     <xsl:variable name="parent-style" select="/office:document/office:styles/style:style[@style:name = $automatic-style/@parent-style]" /> -->
<!--     <xsl:variable name="automatic-style" select="/office:document/office:automatic-styles/style:style[@style:name = current()]" /> -->
<!--   </xsl:function> -->



  <!-- please note the subtle difference between mode="resolve-styles" (catch-all) and resolve-style (local transformation) -->

  <!-- Create attributes for *deviating* formatting: -->
  <xsl:template match="office:automatic-styles/style:style" mode="resolve-style" as="attribute(*)*">
    <xsl:param name="context" as="node()?" />

    <xsl:variable name="parent-style" select="/office:document/office:styles/style:style[@style:name = current()/@style:parent-style-name]" />

    <!-- BASE STYLE NAME: -->
    <xsl:if test="@style:parent-style-name">
      <xsl:attribute name="style-name" select="$parent-style/@style:name" />
    </xsl:if>

    <!-- If we are in a span: which paragraph style is in use? 
         Precedence is: most significant: current declaration, then parent declaration, then paragraph style declaration -->
<!--     <xsl:message> -->
<!--       <hurz> -->
<!--         <xsl:apply-templates select="$context/../@text:style-name" mode="resolve-styles" /> -->
<!--         <\!-\- parent para's parent style's settings: -\-> -->
<!--         <xsl:apply-templates select="/office:document/office:styles/style:style[ -->
<!--                                        @style:name = /office:document/office:automatic-styles/style:style[ -->
<!--                                          @style:name = $context/../@text:style-name -->
<!--                                        ]/@style:parent-style-name -->
<!--                                     ]" mode="resolve-styles-details" /> -->
<!--         <xsl:value-of select="count(/office:document/office:styles/style:style[ -->
<!--                                        @style:name = /office:document/office:automatic-styles/style:style[ -->
<!--                                          @style:name = $context/../@text:style-name -->
<!--                                        ]/@style:parent-style-name -->
<!--                                     ])" /> -->
<!--       </hurz> -->
<!--     </xsl:message> -->

    <!-- deviating ALIGNMENT -->
    <xsl:for-each select="style:paragraph-properties/@fo:text-align[. ne 'start']">
      <xsl:attribute name="align" select="." />
    </xsl:for-each>

    <!-- deviating BORDER -->
    <xsl:for-each select="style:paragraph-properties/@*[starts-with(name(), 'fo:border') and . ne 'none']">
      <xsl:attribute name="{replace(name(), 'fo:', '')}" select="." />
    </xsl:for-each>

    <!-- deviating GENERIC FONT FAMILY -->
    <xsl:if test="style:text-properties/@style:font-name">
      <xsl:variable name="font-family-generic" 
        select="/office:document/office:font-face-decls/style:font-face[
                  @style:name = current()/style:text-properties/@style:font-name
                ]/@style:font-family-generic" />
      <xsl:variable name="parent-font-family-generic" 
        select="/office:document/office:font-face-decls/style:font-face[
                  @style:name = letex:lookup-text-style($parent-style, 'font-name')
                ]/@style:font-family-generic" />

      <xsl:if test="$font-family-generic ne $parent-font-family-generic">
        <xsl:attribute name="font-family-generic" select="$font-family-generic" />
      </xsl:if>
    </xsl:if>

    <!-- deviating FONT WEIGHT -->
    <xsl:if test="style:text-properties/@fo:font-weight">
      <xsl:attribute name="font-weight" select="style:text-properties/@fo:font-weight" />
    </xsl:if>

    <!-- deviating FONT STYLE -->
    <xsl:if test="style:text-properties/@fo:font-style">
      <xsl:attribute name="font-style" select="style:text-properties/@fo:font-style" />
    </xsl:if>

    <!-- deviating LETTER SPACING -->
    <xsl:if test="style:text-properties/@fo:letter-spacing and (style:text-properties/@fo:letter-spacing ne 'normal')">
      <xsl:attribute name="letter-spacing"
        select="if (starts-with(style:text-properties/@fo:letter-spacing, '-')) then 'narrow' else 'wide'" />
    </xsl:if>

    <!-- deviating SUB-/SUPERSCRIPT -->
    <xsl:if test="style:text-properties/@style:text-position and (style:text-properties/@style:text-position ne '0% 100%')">
      <xsl:variable name="pos" select="replace(style:text-properties/@style:text-position, ' .+$', '')" />
<!--       <xsl:variable name="size" select="replace(style:text-properties/@style:text-position, '^.+ ', '')" /> -->
      <xsl:if test="$pos ne '0%'">
        <xsl:attribute name="position" select="if ($pos = 'sub' or starts-with($pos, '-')) then 'sub' else 'sup'" />
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:function name="letex:lookup-text-style" as="xsd:string?">
    <xsl:param name="style-node" as="node()?" />
    <xsl:param name="style-property" as="xsd:string" />
    <xsl:variable name="this-styles-value" select="$style-node/style:text-properties/@*[local-name() = $style-property]" as="xsd:string?" />
    <xsl:choose>
      <xsl:when test="boolean($this-styles-value)">
        <xsl:sequence select="$this-styles-value" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="parent-style" select="root($style-node)/office:document/office:styles/style:style[@style:name = $style-node/@style:parent-style-name]" as="node()?"/>
        <xsl:choose>
          <xsl:when test="boolean($parent-style)">
            <xsl:sequence select="letex:lookup-text-style($parent-style, $style-property)" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="root($style-node)/office:document/office:styles/style:default-style[@style:family = $style-node/@style:family]/style:text-properties/@*[local-name() = $style-property]"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>


  <!-- TRACK CHANGES markup -->

  <xsl:function name="letex:tc-action" as="xsd:string">
    <xsl:param name="change-start-or-end-node" as="node()" />
    <xsl:value-of select="$change-start-or-end-node/ancestor::office:text/text:tracked-changes/text:changed-region[@text:id = $change-start-or-end-node/@text:change-id]/*/local-name()" />
  </xsl:function>

  <xsl:function name="letex:is-deleted" as="xsd:boolean">
    <xsl:param name="node" as="node()" />
    <xsl:variable name="bool-seq" as="xsd:boolean*">
      <xsl:for-each select="$node/ancestor::office:text/text:tracked-changes/text:changed-region[text:deletion]/@text:id">
        <xsl:variable name="change-start" select="$node/ancestor::office:text//text:change-start[@text:change-id = current()]" />
        <xsl:variable name="change-end" select="$node/ancestor::office:text//text:change-end[@text:change-id = current()]" />
        <xsl:variable name="is-between" select="$node &gt;&gt; $change-start and $node &lt;&lt; $change-end" as="xsd:boolean"/>
        <xsl:value-of select="$is-between"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="$bool-seq = true()" />
  </xsl:function>

  <!-- INCOMPLETE: We don't carry out paragraph merges yet! -->
  <xsl:template match="*[letex:is-deleted(.)]" mode="resolve-styles" priority="1000"/>
  
  <xsl:template match="text:change-start | text:change-end | text:tracked-changes" mode="resolve-styles" />


  <!-- GROUP (NEST) STYLES -->

  <xsl:template match="*[text:span[@* and not(@processed)]]" mode="group-styles">
    <xsl:sequence select="letex:group-spans(., distinct-values(for $s in text:span[@* and not(@processed)] return letex:attr-hashes($s)))" />
  </xsl:template>

  <xsl:template match="@processed" mode="clean-group-styles" />

  <xsl:template match="text:span[not(@*)]" mode="clean-group-styles">
    <xsl:apply-templates mode="#current" />
  </xsl:template>

  <xsl:template match="text:span[@*] | text:p[@*]" mode="clean-group-styles">
    <xsl:copy>
      <xsl:copy-of select="@style-name except @style-name[. = ('Footnote')]" />
      <xsl:variable name="rend" select="string-join(for $a in (@* except (@processed union @style-name)) return letex:rend($a), ' ')" />
      <xsl:if test="$rend ne ''">
        <xsl:attribute name="rend" select="$rend" />
      </xsl:if>
      <xsl:apply-templates mode="#current" />
    </xsl:copy>
  </xsl:template>

  <xsl:function name="letex:rend" as="xsd:string?">
    <xsl:param name="attr" as="attribute(*)" />
    <xsl:choose>
      <xsl:when test="name($attr) = 'border'">
        <xsl:choose>
          <xsl:when test="$attr = 'none'" />
          <xsl:otherwise>border</xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="name($attr) = 'font-family-generic'">
        <xsl:choose>
          <xsl:when test="$attr = 'modern'">typewriter</xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="name($attr) = 'font-style'">
        <xsl:choose>
          <xsl:when test="$attr = 'normal'">style-normal</xsl:when>
          <xsl:otherwise><xsl:value-of select="$attr"/></xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="name($attr) = 'font-weight'">
        <xsl:choose>
          <xsl:when test="$attr = 'normal'">weight-normal</xsl:when>
          <xsl:otherwise><xsl:value-of select="$attr"/></xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
<!--         <xsl:value-of select="string-join((name($attr), $attr), ': ')"/> -->
        <xsl:value-of select="$attr"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>


  <xsl:function name="letex:attr-hashes" as="xsd:string*">
    <xsl:param name="node" as="node()?" />
    <xsl:variable name="hashes" as="xsd:string*">
      <xsl:for-each select="$node">
        <xsl:call-template name="attr-hashes" />
      </xsl:for-each>
    </xsl:variable>
    <xsl:sequence select="$hashes" />
  </xsl:function>

  <xsl:template name="attr-hashes">
    <xsl:for-each select="attribute(*)[not(name() = 'processed')]">
      <xsl:value-of select="concat(name(current()), '__', .)" />
    </xsl:for-each>
  </xsl:template>

  <xsl:function name="letex:attname" as="xsd:string">
    <xsl:param name="hash" as="xsd:string" />
    <xsl:value-of select="replace($hash, '__.+$', '')" />
  </xsl:function>

  <xsl:function name="letex:attval" as="xsd:string">
    <xsl:param name="hash" as="xsd:string" />
    <xsl:value-of select="replace($hash, '^.+__', '')" />
  </xsl:function>

  <xsl:template match="@*" mode="test">
    <xsl:attribute name="hash" select="letex:attr-hashes(..)" />
  </xsl:template>

  <xsl:template match="text:span" mode="test">
    <span>
      <xsl:apply-templates select="@*|node()" mode="#current" />
    </span>
  </xsl:template>

  <xsl:function name="letex:group-spans" as="node()*">
    <xsl:param name="parent-node" as="node()" />
    <xsl:param name="properties" as="xsd:string*" />
    <xsl:variable name="nesting" as="node()*">
      <xsl:element name="{name($parent-node)}">
        <xsl:copy-of select="$parent-node/@*" />
        <xsl:choose>
          <xsl:when test="count($properties) gt 0">
            <xsl:for-each-group select="$parent-node/node()" group-adjacent="boolean($properties[1] = letex:attr-hashes(.))">
              <!--               <xsl:message> -->
              <!-- Prop: <xsl:value-of select="$properties[1]"/>  -->
              <!-- Group: -->
              <!--                 <xsl:apply-templates select="current-group()" mode="test"/> -->
              <!--               </xsl:message> -->
              <xsl:choose>
                <xsl:when test="$properties[1] = letex:attr-hashes(current-group()[1]/self::text:span)">
                  <xsl:variable name="common-properties" select="$properties[every $s in current-group() satisfies (. = letex:attr-hashes($s))]"/>
                  <text:span processed="true">
                    <xsl:for-each select="$common-properties">
                      <xsl:attribute name="{letex:attname(current())}" select="letex:attval(current())" />
                    </xsl:for-each>
                    <xsl:apply-templates select="current-group()" mode="exclude">
                      <xsl:with-param name="exclude-properties" select="$common-properties" />
                    </xsl:apply-templates>
                  </text:span>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:copy-of select="current-group()" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each-group>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="$parent-node/node()" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:element>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="every $s in $nesting/text:span satisfies $s/@processed">
        <xsl:copy-of select="$nesting"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="$nesting" mode="group-styles" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>


  <xsl:template match="text:span" mode="exclude">
    <xsl:param name="exclude-properties" as="xsd:string+" />
    <xsl:copy>
      <xsl:copy-of select="@* except @*[max(for $x in $exclude-properties return boolean(name() = letex:attname($x) and (. = letex:attval($x))))]" />
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="exclude-properties" select="$exclude-properties" />
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>



  <xsl:template match="text:sequence-decls" mode="resolve-styles" />
  <xsl:template match="text:soft-page-break" mode="resolve-styles" />
<!--   <xsl:template match="text:line-break" mode="resolve-styles"><lb /></xsl:template> -->
  <xsl:template match="text:s" mode="resolve-styles">
    <xsl:text>&#x20;</xsl:text>
  </xsl:template>

  <!-- mode="main" -->

  <xsl:template match="text:note[@text:note-class='footnote']" mode="main">
    <note xml:id="{@text:id}" type="footnote">
      <xsl:if test="text:note-citation">
        <xsl:attribute name="n" select="text:note-citation" />
      </xsl:if>
      <xsl:apply-templates mode="#current" />
    </note>
  </xsl:template>

  <xsl:template match="text:note[@text:note-class='footnote']/text:note-citation" mode="main" />

  <xsl:template match="text:note-body" mode="main">
    <xsl:apply-templates mode="#current" />
  </xsl:template>

  <xsl:template match="text:p[@style-name = 'Quotations']" mode="main" priority="2">
    <quote>
      <xsl:copy-of select="@* except @style-name" />
      <xsl:apply-templates mode="#current" />
    </quote>
  </xsl:template>

  <xsl:template match="text:p" mode="main">
    <p>
      <xsl:copy-of select="@* except @style-name" />
      <xsl:if test="@style-name[. ne 'Standard'] and not(@rend)">
        <xsl:attribute name="rend" select="@style-name" />
      </xsl:if>
      <xsl:apply-templates mode="#current" />
    </p>
  </xsl:template>

  <xsl:template match="text:p[matches(letex:rendered-content(.), '^\s*&#x2015;\s*$')]" mode="main">
    <milestone unit="section" type="dash" />
    <xsl:call-template name="process-annotations" />
  </xsl:template>

  <xsl:template match="text:p[matches(letex:rendered-content(.), '^\s*\*{3,6}\s*$')]" mode="main">
    <milestone unit="section" type="asterisks" />
    <xsl:call-template name="process-annotations" />
  </xsl:template>

  <xsl:template name="process-annotations">
    <xsl:apply-templates select="office:annotation" mode="#current" />
  </xsl:template>

  <xsl:template match="text:p[text:sequence/@text:name]" mode="main" priority="50" />

  <xsl:template match="text:p[text:sequence/@text:name]" mode="caption">
    <head>
      <xsl:apply-templates mode="#current" />
    </head>
  </xsl:template>

  <xsl:template match="text:spanX" mode="main">
    <xsl:variable name="mapped-style" select="letex:map-style('seg', 'style-name', @style-name)" />
    <xsl:choose>
      <xsl:when test="boolean($mapped-style)">
        <seg type="{$mapped-style}">
          <xsl:apply-templates mode="#current" />
        </seg>
      </xsl:when>
      <xsl:otherwise>
        <seg>
          <xsl:copy-of select="@* except (@style-name union @processed)" />
          <xsl:apply-templates mode="#current" />
        </seg>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="text:span[@*]" mode="main">
    <hi>
      <xsl:apply-templates select="@*" mode="#current" />
      <xsl:apply-templates mode="#current" />
    </hi>
  </xsl:template>

  <xsl:template match="text:span[@style-name='Emphasis']" mode="main" priority="2">
    <emph rend="italics">
      <xsl:apply-templates select="@* except @style-name" mode="#current" />
      <xsl:apply-templates mode="#current" />
    </emph>
  </xsl:template>

  <xsl:template match="text:a[@xlink:href]" mode="main">
    <ref target="{@xlink:href}">
      <xsl:apply-templates mode="#current" />
    </ref>
  </xsl:template>

  <xsl:template match="office:annotation" mode="main">
    <note type="internal"><xsl:apply-templates select="* except (dc:creator union dc:date)" mode="#current" />
    (<name><xsl:value-of select="dc:creator"/></name><!--<date when-iso="{dc:date}"/>-->)
    </note>
  </xsl:template>


  <!-- Utility function to determine the actually rendered content of an element (modulo note text, etc.) -->
  <xsl:function name="letex:rendered-content" as="xsd:string?">
    <xsl:param name="node" as="node()" />
    <xsl:variable name="strings" as="xsd:string*">
      <xsl:apply-templates select="$node" mode="rendered-content" />
    </xsl:variable>
    <xsl:value-of select="string-join($strings, '')"/>
  </xsl:function>

  <!-- list maybe incomplete: -->
  <xsl:template match="text:p | text:h | text:span | 
                       tei:p | tei:seg | tei:div  | tei:l | tei:hi | tei:emph | tei:head" mode="rendered-content">
    <xsl:apply-templates mode="#current" />
  </xsl:template>

  <xsl:template match="text:note" mode="rendered-content">
    <xsl:value-of select="note-citation" />
  </xsl:template>

  <xsl:template match="*" mode="rendered-content" priority="-0.5" />


  <!-- VERSE -->

  <xsl:template match="text:p[@style-name='Verse']" mode="verse">
    <lg type="verse">
      <xsl:for-each-group select="node()" group-starting-with="text:line-break">
        <l>
          <xsl:apply-templates select="current-group() except self::text:line-break" mode="#current"/>
        </l>
      </xsl:for-each-group>
    </lg>
  </xsl:template>

  <xsl:template match="*[text:p[@style-name='Verse']]" mode="verse">
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <xsl:for-each-group select="node()" group-adjacent="boolean(self::text:p[@style-name='Verse'])">
        <xsl:choose>
          <xsl:when test="current-grouping-key()">
            <xsl:text>&#xa;</xsl:text>
            <div type="verse">
              <xsl:copy-of select="current-group()[1]/@rend" />
              <xsl:apply-templates select="current-group()" mode="#current" />
            </div>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="current-group()" mode="#current" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>

  <!-- LETTERs -->

  <xsl:template match="*[text:p[@style-name='Opener']]" mode="letter">
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <xsl:for-each-group select="node()" group-starting-with="text:p[@style-name = 'Opener']">
        <xsl:choose>
          <xsl:when test="current-group()[1][@style-name='Opener']">
            <xsl:text>&#xa;</xsl:text>
            <div type="letter">
              <xsl:apply-templates select="current-group()
                                           except 
                                           current-group()[. &gt;&gt; current-group()/self::text:p[@style-name = 'Salutation']]" 
                mode="#current" />
            </div>
            <xsl:apply-templates select="current-group()[. &gt;&gt; current-group()/self::text:p[@style-name = 'Salutation']]" 
              mode="#current" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="current-group()" mode="#current" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="text:p[@style-name = 'Opener']" mode="letter">
    <xsl:text>&#xa;</xsl:text>
    <opener>
      <xsl:apply-templates select="@* except @style-name | node()" mode="#current" />
    </opener>
  </xsl:template>

  <xsl:template match="text:p[@style-name = 'Salutation' and matches(., '^\s*$')]" mode="letter" />

  <xsl:template match="text:p[@style-name = 'Salutation' and not(matches(., '^\s*$'))]" mode="letter">
    <closer>
      <xsl:apply-templates select="@* except @style-name | node()" mode="#current" />
    </closer>
  </xsl:template>

  <!-- TABLES -->

  <xsl:template match="table:table" mode="main">
    <table>
      <!-- WARNING: we are in trouble if there's a p[@name='Table'] above *and* below the table. Unfortunately ODF doesn't encourage grouping of tables and their captions. -->
      <xsl:apply-templates select="preceding-sibling::*[1]/self::text:p[text:sequence/@text:name='Table'] union following-sibling::*[1]/self::text:p[text:sequence/@text:name='Table']" mode="caption" />
      <xsl:apply-templates mode="#current" />
    </table>
  </xsl:template>

  <xsl:template match="text:sequence" mode="caption">
    <xsl:apply-templates mode="#current" />
  </xsl:template>

  <xsl:template match="table:table-column" mode="main" />

  <xsl:template match="table:table-header-rows" mode="main">
    <xsl:apply-templates mode="#current" />
  </xsl:template>

  <xsl:template match="table:table-row" mode="main">
    <row>
      <xsl:if test="ancestor::*[1]/self::table:table-header-rows">
        <xsl:attribute name="role" select="'data'" />
      </xsl:if>
      <xsl:apply-templates mode="#current" />
    </row>
  </xsl:template>

  <xsl:template match="table:table-cell" mode="main">
    <cell>
      <xsl:if test="@table:number-rows-spanned"><xsl:attribute name="rows" select="@table:number-rows-spanned" /></xsl:if>
      <xsl:if test="@table:number-columns-spanned"><xsl:attribute name="cols" select="@table:number-columns-spanned" /></xsl:if>
      <xsl:apply-templates mode="#current" />
    </cell>
  </xsl:template>

  <xsl:template match="table:covered-table-cell" mode="main" />

  <!-- §§§ warning: piggybacking on anonymous-divs mode; no fundamental but only practical reasons to use this mode here! -->
  <xsl:template match="tei:cell/tei:p" mode="anonymous-divs">
    <xsl:apply-templates mode="#current" />
  </xsl:template>


  <!-- JOIN SEGS (adjacent segs with the same attributes, possibly separated by whitespace-only text nodes) -->

  <xsl:function name="letex:seg-key" as="xsd:string?">
    <xsl:param name="node" as="node()"/>
    <xsl:choose>
      <xsl:when test="$node/preceding-sibling::*[1]/self::tei:seg and $node/self::text()[matches(.,'^[\s]+$')]">
        <xsl:sequence select="$node/preceding-sibling::tei:seg[1]/@type" />
      </xsl:when>
      <xsl:when test="$node/self::tei:seg">
        <xsl:sequence select="$node/@type" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="'none'" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:template match="*[tei:seg]" mode="join-segs">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:for-each-group select="node()" group-adjacent="letex:seg-key(.)">
        <xsl:choose>
          <xsl:when test="current-grouping-key() and current-group()/self::tei:seg">
            <seg type="{current-group()[1]/@type}">
              <xsl:apply-templates select="current-group()" mode="#current"/>
            </seg>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="current-group()" mode="#current"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:seg" mode="join-segs">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>


  <!-- ANONYMOUS DIVs -->

  <xsl:template match="*[tei:div/following-sibling::tei:p]" mode="anonymous-divs">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:for-each-group select="node()" group-adjacent="boolean(self::tei:p)">
        <xsl:choose>
          <xsl:when test="current-grouping-key()">
            <xsl:text>&#xa;</xsl:text>
            <div type="anonymous">
              <xsl:apply-templates select="current-group()" mode="#current"/>
            </div>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="current-group()" mode="#current"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>


  <!-- ADD LINEAR NUMBERING: Add a sequence number to each para, heading, footnote, etc.: -->

  <!-- main text body elements which get a randnummer -->
  <xsl:template  match="&numberedMainTextElements;" mode="add-linear-numbering" priority="2">
    <xsl:copy>
      <xsl:attribute  name="xml:id"  select="concat( 'rn_', letex:index-of( &numberedMainTextElements; , . ))"/>
      <xsl:apply-templates  select="@* except @xml:id | node()"  mode="#current"/>
    </xsl:copy>
  </xsl:template>


  <!-- footnote-elements which get a randnummer -->
  <xsl:template  match="&footnote;//&numberedFootnoteDescendant;" mode="add-linear-numbering">
      <xsl:variable  name="footnoteNumber"            select="letex:index-of( //&footnote; , ancestor-or-self::&footnote; )"/>
      <xsl:variable  name="footnoteDescendantAlphaNumber">
          <xsl:if  test="count( ancestor-or-self::&footnote;//&numberedFootnoteDescendant; ) gt 1">
              <xsl:number  value="letex:index-of( ancestor-or-self::&footnote;//&numberedFootnoteDescendant;, .)"  format="a"/>
          </xsl:if>
      </xsl:variable>
      <xsl:copy>
          <xsl:attribute  name="xml:id"  select="concat( 'rn_fn', $footnoteNumber, $footnoteDescendantAlphaNumber)"/>
          <xsl:apply-templates  select="@* except @xml:id | node()"  mode="#current"/>
      </xsl:copy>
  </xsl:template>


  <!-- elements which are not destined for getting a number -->
  <xsl:template  match="&unnumberedElements;" mode="add-linear-numbering">
      <xsl:copy>
          <xsl:apply-templates  select="@* | node()"  mode="#current"/>
      </xsl:copy>
  </xsl:template>


    <!--__ ALPHA SUBNUMBERING OF FOOTNOTE-SUBELEMENTS AS WELL AS OF PARAS WHICH ARE SPLIT BY INTERSPERSED TABLES ETC. __________________________________-->
    
    <xsl:template match="tei:p[@xml:id]" mode="add-subnumbering-for-split-paras">
        <xsl:variable  name="randnummer"  select="@xml:id"/>
        <!-- split <p> on <table> and <quote> -->
        <xsl:variable  name="temp">
            <xsl:for-each-group  select="node()" group-adjacent="if ( self::table | self::quote ) then 1 else 0">
              <xsl:text>&#xa;</xsl:text>
                <xsl:choose>
                    <xsl:when  test="current-grouping-key()">
                      <xsl:apply-templates  select="current-group()"  mode="#current" />
                    </xsl:when>
                    <xsl:otherwise>
                        <p>
                          <xsl:copy-of  select="../@* except @xml:id"/>
                            <xsl:attribute  name="xml:id"  select="$randnummer"/>
                            <xsl:apply-templates  select="current-group()"  mode="#current" />
                        </p>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:variable>
        <xsl:apply-templates  select="$temp"  mode="splitParas_reassignRandnummern"/>
    </xsl:template>
    

    <!-- if we receive several <p> out of one (which then share the same xml:id), add 'a', 'b', ... to the id-values -->
    <xsl:template  match="p"  mode="splitParas_reassignRandnummern">
        <xsl:variable  name="alphaSubnumber">
            <xsl:if  test="count( ../p) gt 1">
                <xsl:number count="p" level="single" format="a"/>
            </xsl:if>
        </xsl:variable>
        <xsl:copy>
            <xsl:copy-of  select="@* except @xml:id"/>
            <xsl:attribute  name="xml:id"  select="concat( @xml:id, $alphaSubnumber)"/>
            <xsl:apply-templates  mode="#current" />
        </xsl:copy>
    </xsl:template>

    
  <!-- for mode="add-linear_numbering" we use a "catch all"-rule which generates useful warnings -->
  <xsl:template  match="element()"  mode="add-linear_numbering"  priority="-.9">
      <xsl:if  test="normalize-space( string-join( text(), ''))">
          <xsl:message  select="'Warning: an element contains the following text but ist not listed in numberedElements* or unnumberedElements'"/>
          <xsl:message  select="concat('  element:   ', name(.))"/>
          <xsl:message  select="concat('  namespace: ', namespace-uri(.))"/>
          <xsl:message  select="concat('  content:   ', substring( string-join( text(), '&#xA0;'), 0, 100))"/>
      </xsl:if>
      <xsl:copy>
          <xsl:apply-templates  select="attribute()"                mode="#current"/>
          <xsl:apply-templates  select="node() except attribute()"  mode="#current"/>
      </xsl:copy>
  </xsl:template>


  <!-- CATCH ALL -->

  <xsl:template match="*" mode="&catchAllModes;" priority="-1">
    <xsl:element name="{name()}">
      <xsl:apply-templates select="@*|*|text()|processing-instruction()|comment()" mode="#current"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="@*" mode="&catchAllModes;" priority="-1">
    <xsl:attribute name="{name()}" select="." />
  </xsl:template>


  <!-- Utility functions: -->

  <xsl:function name="letex:index-of" as="xsd:double*">
    <xsl:param name="nodes" as="node()*"/>
    <xsl:param name="node" as="node()"/>
    <xsl:sequence select="index-of(for $n in $nodes return generate-id($n), generate-id($node))"/>
  </xsl:function>
  <!-- Could also use the 'is' operator. 
       In addition: Sometimes saxon:memo-function will help, but I skipped it because I don't know whether the processor in use supports it. -->

</xsl:stylesheet>
