<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="xsl tei xs" version="2.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0">
  
  <xsl:output method="xhtml" indent="no" encoding="UTF-8" omit-xml-declaration="yes"/>

  <xsl:variable name="attribute_prefix">data-tei-</xsl:variable>

<!--  <xsl:template name="make_xml_seperate_attributes">

    <element>
      <xsl:attribute name="name" select="name()" />
      <xsl:for-each select="@*">
        <attribute>
          <xsl:attribute name="name" select="name()" />
          <!-\- attributes seperated by space divided into seperate attributes -\->
          <xsl:for-each select="tokenize(., ' ')">
            <value>
              <xsl:attribute name="name" select="." />
            </value>
          </xsl:for-each>
        </attribute>
      </xsl:for-each>
    </element>
  </xsl:template>-->

  <xsl:template name="make_xml">
    <element>
      <xsl:attribute name="name" select="translate(name(), ':', '')" />
      <xsl:for-each select="@*">
        <attribute>
          <xsl:attribute name="name" select="translate(name(), ':', '')" />
          <value>
            <xsl:value-of select="translate(., ':', '')" />
          </value>
        </attribute>
      </xsl:for-each>
    </element>
  </xsl:template>

  <xsl:template name="add_attributes">

    <xsl:variable name="local_xml">
      <xsl:copy-of select="//titleStmt/author" />
      <xsl:copy-of select="//handNote" />

      <xsl:call-template name="make_xml" />
    </xsl:variable>

    <xsl:for-each select="$local_xml/element" xpath-default-namespace="">
      <xsl:variable name="attribute">
        <xsl:value-of select="$attribute_prefix" />
        <xsl:text>e</xsl:text>
      </xsl:variable>
      <xsl:variable name="value" select="@name" />
      <xsl:attribute name="{$attribute}" select="$value" />
    </xsl:for-each>


    <xsl:for-each select="$local_xml/element/attribute/value" xpath-default-namespace="">
      <xsl:choose>
        <xsl:when test="../@name = 'hand'">
          <xsl:variable name="full_hand_id" select="." />
          <xsl:variable name="hand_id" select="substring-after(., '#')" />

          <xsl:for-each select="//handNote[@xml:id = $hand_id]"
            xpath-default-namespace="http://www.tei-c.org/ns/1.0">
            <!-- setting variables for medium -->
            <xsl:variable name="attribute_medium">
              <xsl:value-of select="$attribute_prefix" />
              <xsl:text>a-hand-medium</xsl:text>
            </xsl:variable>
            <xsl:variable name="value_medium" select="@medium"/>
            
            <!-- setting variables for resp -->
            <xsl:variable name="attribute_resp">
              <xsl:value-of select="$attribute_prefix" />
              <xsl:text>a-hand-resp</xsl:text>
            </xsl:variable>
            <xsl:variable name="value_resp">
              <xsl:value-of select="substring-after(@resp, '#')" />
            </xsl:variable>
            
            <xsl:attribute name="{$attribute_medium}" select="$value_medium" />
            <xsl:attribute name="{$attribute_resp}" select="$value_resp" />
            
            <!-- adding full name as the title -->
            <xsl:variable name="resp" select="substring-after(@resp, '#')"/>
            <xsl:for-each select="//author[@xml:id = $resp]"
              xpath-default-namespace="http://www.tei-c.org/ns/1.0">
              
              <!-- setting variables for title/name -->
              <xsl:variable name="attribute_name">
                <xsl:text>title</xsl:text>
              </xsl:variable>
              <xsl:variable name="value_name">
                <xsl:value-of select="." />
              </xsl:variable>
              
              <xsl:attribute name="{$attribute_name}" select="$value_name" />
              
            </xsl:for-each> <!-- /adding full name as title -->   
          </xsl:for-each><!-- /adding data-tei-a-hand elements -->    
          
        </xsl:when>
        <xsl:otherwise>

          <xsl:variable name="attribute">
            <xsl:value-of select="$attribute_prefix" />
            <xsl:text>a</xsl:text>
            <xsl:text>-</xsl:text>
            <xsl:value-of select="../@name" />
          </xsl:variable>
          <xsl:variable name="value">
            <xsl:value-of select="." />
          </xsl:variable>
          <xsl:attribute name="{$attribute}" select="$value" />

        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
    <!-- for testing, delete later -->
    <!--<test><xsl:copy-of select="$local_xml"/></test>-->
  </xsl:template>
  
  <!-- Generic template for all elements -->
  <xsl:template match="tei:text//*">
    <span>
      <xsl:call-template name="add_attributes" />
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="teiHeader" /><!-- do nothing -->

  <!-- ===============
    override elements for semantic HTML elements 
  =================== -->

  <xsl:template match="p" priority="1">
  	<!-- unless inside another p, then span -->
  	<xsl:choose>
  		<xsl:when test="ancestor::p">
  			<span>
  			  <xsl:call-template name="add_attributes"/>
          <xsl:apply-templates/>
  			</span>
  		</xsl:when>
  		<xsl:otherwise>
  			<p>
  			  <xsl:call-template name="add_attributes"/>
  			  <xsl:apply-templates/>
  			</p>
  		</xsl:otherwise>
  	</xsl:choose>
  </xsl:template>
  
  <!-- force block level elements -->
  <xsl:template 
    match="div | div1 | div2 | div3 | div4 | div5 | div6 | div7 | body" 
    priority="1">
        <div>
          <xsl:call-template name="add_attributes"/>
          <xsl:apply-templates/>
        </div>
  </xsl:template>
  
  <!-- todo: add head number based on div nesting and @type = sub -->
  <xsl:template 
    match="head" 
    priority="1">
    <h2>
      <xsl:call-template name="add_attributes"/>
      <xsl:apply-templates/>
    </h2>
  </xsl:template>
  
  <xsl:template 
    match="del" 
    priority="1">
    <del>
      <xsl:call-template name="add_attributes"/>
      <xsl:apply-templates/>
    </del>
  </xsl:template>
  
  <!-- Content Sectioning -->

  <!-- <address>
  <article>
  <h1>, <h2>, <h3>, <h4>, <h5>, <h6> DONE
  <main>
  <section> -->

  <!-- Text content -->

  <!-- <blockquote> and <q>
  <figure> containing <figcaption>
  <hr> milestone
  <ul><li>
  <ol><li>
  <p> DONE -->

  <!-- Inline text semantics -->

  <!-- <a>
  <abbr>
  <b> is used to draw the reader's attention to the element's contents, which are not otherwise granted special importance.
  <br> lb
  <cite> must contain title
  <data>
  <em> can be nested to represent levels of emphasis
  <i> represents a range of text that is set off from the normal text for some reason.
  <mark> represents text which is marked or highlighted for reference or notation purposes, due to the marked passage's relevance or importance in the enclosing context.
  <s>
  <strong>
  <sub>
  <sup>
  <time>
  <u> represents a span of inline text which should be rendered in a way that indicates that it has a non-textual annotation. -->

  <!-- Image and multimedia -->

  <!-- <audio>
  <img>
  <video> -->

  <!-- Edits -->

  <!-- <del>  DONE
  <ins> -->

  <!-- Tables -->

  <!-- <table> <caption> <thead> <tbody> <tfoot> -->

  <!-- see https://developer.mozilla.org/en-US/docs/Web/HTML/Element -->
</xsl:stylesheet>
