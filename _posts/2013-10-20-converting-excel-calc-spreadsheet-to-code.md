---
layout: post
title: Converting Excel (Calc) Spreadsheet to Code
tags: Excel, Java, util
---

A few months ago I needed to convert quite complex (kind of black box) computation from Excel spreadsheet to C code. At first I manually copied expressions from all cells but this was not simple as I had to check cells mentioned in expressions (formulas). It took long time and energy and the code didn't work properly - results calculated by the spreadsheet differed from my program's result.

Therefore I decided to save the Excel spreadsheet in ODF format (OpenOffice.org Calc) and write a little helper called <strong>SpreadsheetToCode</strong>. It's a command-line utility that does the following steps:
<ol>
  <li><strong>Load OpenDocument Spreadsheet file</strong> (.ods) because it's basically XML file wrapped in ZIP and therefore super easy to handle</li>
  <li><strong>Pick all cells</strong> which contain numerical values (inputs, parameters) or expressions with them (formulas)</li>
  <li><strong>Print C-like source code</strong> with the spreadsheet's functionality expressed in lines of code</li>
</ol>

<!--more-->

As this is just helper and not fully equipped Excel-to-EXE converter, so that your task is to rename variables to something meaningful (instead of G42), maybe merge some lines of code or remove redundant steps and incorporate the resulting code in your own program. Converter's greatest help is that it checks for dependencies which means that code

{% highlight c %}
double C2 = C10/3;
{% endhighlight %}

will be placed after

{% highlight c %}
double C10 = C5+C1;
{% endhighlight %}

because C10 mustn't be used before its declaration/definition.

<h2>Usage</h2>

To illustrate the usage I created <a href="http://dir.adamheinrich.com/spreadsheet_to_code/resistive_divider.ods">simple spreadsheet</a> (the original complex spreadsheet can not be disclosed) for calculating resistive voltage divider. It calculates <em>V2</em> from <em>V1</em>, <em>R1</em> and <em>R2</em>:

<a href="{{ site.baseurl }}/public/img/converting-excel-calc-spreadsheet-to-code/resistive_divider_spreadsheet.png">
<img class="alignnone" alt="Resistive divider spreadsheet" src="{{ site.baseurl }}/public/img/converting-excel-calc-spreadsheet-to-code/resistive_divider_spreadsheet_thumb.png" width="500">
</a>

{* *}

Of course this is a trivial task but I couldn't think up anything better that wouldn't take long minutes to create (Excel calculations aren't my style, I use it just for painting tables). Many thanks to Wikipedia for the <a href="http://en.wikipedia.org/wiki/File:Resistive_divider.png">File:Resistive_divider.png</a>.

For the conversion just download <a href="http://dir.adamheinrich.com/spreadsheet_to_code/SpreadsheetToCode.jar">SpreadsheetToCode.jar</a> and run it:

{% highlight sh %}
java -jar SpreadsheetToCode.jar resistive_divider.ods
{% endhighlight %}

The resulting code will be:

{% highlight c %}
/* Constants: */
double C5 = 22.0;
double C6 = 20.0;
double C7 = 3.0;

/* Formulas: */
double C10 = C6+C7;
double C11 = C7/C10;
double E5 =  C5*C11;
{% endhighlight %}

The only thing you need is to wrap it into some function and look into spreadsheet what cells are inputs (<em>C5</em>, <em>C6</em>, <em>C7</em>: they are listed in <em>Constants</em> section) and which are results (<em>E5</em> in our case). Problem solved!

<h2>Source code and limitations</h2>
Full Java source code is at <a href="http://dir.adamheinrich.com/spreadsheet_to_code/">dir.adamheinrich.com/spreadsheet_to_code/</a> (source.zip). As this was an one-hour project the code is not ideal (but I tried to keep it understandable) and there are some known limitations (or features :-) ) I didn't want to solve:
<ul>
  <li>The resulting code is always C-like (with statements ended by a semicolon). You can change this in <strong>Cell.getGeneratedCode()</strong> method.</li>
  <li>Your task is to decide what cells are inputs and which are outputs. The easiest way is to wrap generated code in function and fill input cells with function arguments.</li>
  <li>Formulas containing IF or mathematical functions are not converted to valid C code (but from the generated code it's quite obvious is it supposed to do). Your task is to change function names to something meaningful and replace IF with ternary operator.</li>
  <li>Cells with column indexes higher than Z (AA1, AB1, ...) are not correctly represented. You can modify the cell name assignment in <strong>Cell.setName(int row, int column)</strong> method if you need this. It should be a few lines of code.</li>
</ul>

<h2>Result</h2>
This utility saved me hours of boring copy&amp;paste in Excel and ordering lines of code because of dependencies. Instead I spend the time coding this utility which was more fun:-) It is placed online so that it can help someone else. Enjoy!