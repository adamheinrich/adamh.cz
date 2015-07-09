---
layout: post
title: Overcoming the Same-Origin Policy in an Iframe
tags: Hack, HTML, iframe, Web

disqusIdentifier: "220 http:\\/\\/frommyplayground.com\\/?p=220"
---

A lot of webmasters use the <em>Access-Control-Allow-Origin</em> header in order not to have their content displayed somewhere else on the web. It is quite understandable as they want to have their intellectual property protected. But sometimes it might be useful to have some website loaded into an iframe although the iframe is quite old-fashioned HTML element.

In order to do so I found interesting service called <a href="http://whateverorigin.org">WhateverOrigin.org</a> (which is an open Source clone of similar service called <a href="http://anyorigin.com">AnyOrigin.com</a>). It just grabs content from a website specified in GET parameter and returns it together with HTTP status code as JSON data.
<!--more-->
With this approach you don't point iframe to the target site like

{% highlight html %}
<iframe src="http://pojects.adamh.cz" height="240" width="320"></iframe>
{% endhighlight %}

but to some HTML page located at your server called eg. <em>loader.html</em>:

{% highlight html %}
<iframe src="loader.html" height="240" width="320"></iframe>
{% endhighlight %}

This page contains simple script which loads page's content, replaces relative links in images and links to absolute ones and displays it:

{% highlight html js %}
<!DOCTYPE html>
<head>
    <script src="http://code.jquery.com/jquery-1.2.3.min.js"></script>
</head>
<body>
    <script>
        var url = 'http://projects.adamh.cz';
        $.getJSON('http://whateverorigin.org/get?url=' + encodeURIComponent(url) + '&callback=?', function(data){
            var html = ""+data.contents;
    
            /* Replace relative links to absolute ones */
            html = html.replace(new RegExp('(href|src)="/', 'g'),  '$1="'+url+'/');

            $("#siteLoader").html(html);
        });
    </script>
    <div id="siteLoader">
        <i>Loading&hellip;</i>
    </div>
</body>
</html>
{% endhighlight %}

This <a href="http://dir.adamheinrich.com/same-origin-hack-iframe/test.html">little example</a> shows the whole thing in action.

<a href="{{ site.baseurl }}/public/img/overcoming-the-same-origin-policy-in-an-iframe/iframe_hack_screenshot.png">
<img src="{{ site.baseurl }}/public/img/overcoming-the-same-origin-policy-in-an-iframe/iframe_hack_screenshot_thumb.png" alt="Dealing with the same-origin policy" width="300" height="157" class="alignnone" style="border: 1px solid #ccc;">
</a>

It might be useful to remove Google Analytics code and some other stuff.