---
layout: post
title: Decimal Comma in Matlab Plots
tags: Matlab, Octave
disqusIdentifier: "73 http:\\/\\/frommyplayground.com\\/?p=73"
---

A lot of languages (not only the European ones) use <strong>decimal comma</strong> instead decimal point to separate the whole and the fractional part of a number in decimal form. <strong>Matlab</strong> (like other programs) uses decimal point for this purpose. This is okay when using it for computations but it is better to use decimal comma in graphs embedded in documents written in some European language.

<a href="{{ site.baseurl }}/public/img/decimal_comma_with.png">
<img class="alignnone" title="A Matlab graph with decimal commas" alt="" src="{{ site.baseurl }}/public/img/decimal_comma_with.png" width="318" height="239">
</a>


This approach also works in <strong>GNU Octave</strong> which is available for free. ;-)

<!--more-->

Basic plotting in Matlab is done by the <a href="http://www.mathworks.com/help/matlab/ref/plot.html">plot</a> function:

{% highlight matlab %}
% Define function
x = -1:0.1:1;
y = x.^3;

% Open graph window and plot the function
figure;
plot(x, y);

% Label axes, show grid and title
grid on;
title('Simple plot');
ylabel('y=x^3');
xlabel('x');
{% endhighlight %}

To change decimal point to decimal comma I used simple approach: Function <em>get(gca, 'XTick')</em> returns the tick of X asix. In our case it is a vector -1:0.01:1. Another function <em>set(gca, 'XTickLabel')</em> sets a label for X axis. This label contains cell array of strings. The only necessary step between calling these functions is to change decimal points to commas using the <a href="http://www.mathworks.com/help/matlab/ref/strrep.html">strrep</a> function.

I wrapped this code into a simple function <a href="https://github.com/adamheinrich/decimal-comma"><strong>decimal_comma</strong></a> with a few arguments:
<ul>
    <li><strong>axes_handle</strong> is handle of axes to be changed. Just enter gca for current plot.</li>
    <li><strong>axis_name</strong> is the name of axis to be changed: <em>'X'</em>, <em>'Y'</em> or <em>'XY'</em> for both axes.</li>
    <li><strong>formatstr</strong> (optional) is simple <a href="http://www.mathworks.com/help/matlab/ref/sprintf.html#inputarg_formatSpec">sprintf</a>-like format string, e.g. <em>'%2.2f'</em></li>
</ul>
Just copy the code below and save it into new script file named decimal_comma.m or clone the whole <strong><a href="https://github.com/adamheinrich/decimal-comma">Github repository</a></strong>:

{% highlight matlab %}
function decimal_comma(axis_handle, axis_name, varargin)
%DECIMAL_COMMA - decimal comma in 2-D plot
%
%   A simple function to replace decimal points with decimal commas (which
%   are usual in Europe) in Matlab or Octave plots.
%
%   DECIMAL_COMMA(axis_handle, axis_name) changes decimal point to decimal
%   comma in a plot. Use gca for current axes handle and one of 'X', 'Y' or
%   'XY' for axis_name.
%
%   DECIMAL_COMMA(axis_handle, axis_name, formatstr) changes decimal point 
%   to decimal comma in a plot. Number format is specified by formatstr 
%   (see SPRINTF for details).   

% (c) 2012 Adam Heinrich <adam@adamh.cz>. Published under the MIT license.

    if (nargin < 2 || nargin > 3)
        error('Wrong number of input parameters.');
    end

    switch axis_name
        case 'XY'
            decimal_comma(axis_handle, 'X', varargin{:});
            decimal_comma(axis_handle, 'Y', varargin{:});
            
        case {'X', 'Y'}
            tick = get(axis_handle, strcat(axis_name, 'Tick'));
            
            n = length(tick);
            labels = cell(1,n);

            for i = 1:n
                label = num2str(tick(i), varargin{:});
                labels{i} = strrep(label, '.', ',');
            end
            
            labels{1} = '';
            labels{n} = '';

            set(axis_handle, strcat(axis_name, 'TickLabel'), labels);
            
        otherwise
            error('Wrong axis name! Use one of X, Y or XY.');
    end
end
{% endhighlight %}

Usage for our example function <em>y</em>=<em>x</em><sup>3</sup>:

{% highlight matlab %}
x = -1:0.1:1;
y = x.^3;

figure;
plot(x, y);

grid on;
title('Simple plot');
ylabel('y=x^3');
xlabel('x');

decimal_comma(gca, 'XY');
{% endhighlight %}

If you like to hide numbers on the left and right, just add this line before <em>set(axis_handle, ...)</em>:

{% highlight matlab %}
labels{1} = '';
labels{n} = '';
{% endhighlight %}

The plot will then change to:

<a href="{{ site.baseurl }}/public/img/decimal_comma_without.png">
<img class="alignnone" title="A Matlab graph with decimal commas" alt="" src="{{ site.baseurl }}/public/img/decimal_comma_without.png" width="318" height="239">
</a>

Get the whole code from my <a href="https://github.com/adamheinrich/decimal-comma">Github</a>!