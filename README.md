Note: My initial spec submission can be found [here](https://github.com/suterr252/skippy/blob/master/submitted.txt)

# Skippy!


This project aims to automate the experience of stepping through a route in Google Street View images.

# Specific language implementation used:
[SBCL](http://www.sbcl.org/), Steel Bank Common Lisp

## Some motivation for lisp:
[Beating the Averages, Paul Graham (YCombinator)](http://www.paulgraham.com/avg.html)

![Lisp Cycles](https://github.com/suterr252/skippy/blob/master/img/lisp_cycles.png)

# What's the project do?

Let's demonstrate with an example route of `3065 Jackson St San Francisco, CA 94115` to `2261 Fillmore St San Francisco, CA 94115`. That is, we will find the walking directions from the first locale to the second.


Here is a visual overview of our route


![Route Overview](https://github.com/suterr252/skippy/blob/master/img/walking-route.png)

We pass this along to the [Google directions API](https://developers.google.com/maps/documentation/directions/) which gives us, among other things, a series of (encoded) polylines for each leg of the trip (remember, this is a Lisp - a LISt Processing Language - so we'll be abstracting our data as lists):

``` common-lisp
;; Each string represents a polyline
("mateFrbjjVUqDi@gIk@mIg@kIASg@uHg@uH?Q[sEOuB"
 "_jteFb_hjVnDa@nDc@h@I")
```

But we're using an old language for which there isn't a large open source community sponsoring libraries for current APIs. Thus, we will be implementing our version of [Google's Encoded Polyline Algorithm Format](https://developers.google.com/maps/documentation/utilities/polylinealgorithm), which can be found in the source file `/src/decode-polyline.lisp`. The output of decoding is a series of latitude and longitude lines, as plotted here:


![First Polyline](https://github.com/suterr252/skippy/blob/master/img/polyline1.png) ![Second Polyline](https://github.com/suterr252/skippy/blob/master/img/polyline2.png)



Or in tabular form, here:
``` common-lisp
((37.791107 -122.44537)
 ;; Each nested list represents a lat:long pair
 (37.791218 -122.44449)
 (37.791428 -122.44285) (37.79165 -122.44118)
 (37.791847 -122.439514) (37.79186 -122.439415)
 (37.79206 -122.43787) (37.79226 -122.43632)
 (37.79226 -122.436226) (37.7924 -122.435165)
 (37.79248 -122.43458) (37.79248 -122.43458)
 (37.7916 -122.43441) (37.790718 -122.43423)
 (37.79051 -122.43417))
```


While less convenient, this is neat because it means there's plenty of low hanging fruit for which one can make open source contributions. I intend to submit mine to the [QuickLisp](https://www.quicklisp.org/beta/) library manager (analogous to node's NPM) so others can use it (it takes about two weeks for contributions to be properly vetted).



To these polylines, we will add a camera direction (bearing, or heading) for each location. The formula for doing so can be found [here](https://stackoverflow.com/questions/3932502/calculate-angle-between-two-latitude-longitude-points#answer-18738281):

![Vector Components](https://github.com/suterr252/skippy/blob/master/img/directions-added.jpg)

Or, again, in tabular form:
``` common-lisp
((37.791107 -122.44537 "82.843")
 ;; Each nested list represents a lat:long:heading triple
 (37.791218 -122.44449 "82.676")
 (37.791428 -122.44285 "82.420") (37.79165 -122.44118 "83.166")
 (37.791847 -122.439514 "83.390") (37.79186 -122.439415 "82.527")
 (37.79206 -122.43787 "82.666") (37.79226 -122.43632 "90.000")
 (37.79226 -122.436226 "82.383") (37.7924 -122.435165 "82.201")
 (37.79248 -122.43458 "0.000") (37.79248 -122.43458 "169.261")
 (37.7916 -122.43441 "168.309") (37.790718 -122.43423 "165.776")
 (37.79051 -122.43417 "165.776"))
```



We will there go through and download an image for each latitude:longitude:heading tuple from the [Google Street View Image API](https://developers.google.com/maps/documentation/streetview/).

From here we will rely on [ImageMagick](https://www.imagemagick.org/script/index.php) to `"to create, edit, compose, or convert bitmap images"` (process these images and then create a GIF).

From there, we will send our generated gif to Amazon's [S3](https://aws.amazon.com/s3/) for storage with a url of `https://s3.amazonaws.com/skippy-cs252/<filename>.gif` where the filename is formed via the input directions. For the example above, this would be [https://s3.amazonaws.com/skippy-cs252/3065JacksonStSanFranciscoCA94115to2261FillmoreStSanFranciscoCA94115.gif](https://s3.amazonaws.com/skippy-cs252/3065JacksonStSanFranciscoCA94115to2261FillmoreStSanFranciscoCA94115.gif).

![Final GIF](https://github.com/suterr252/skippy/blob/master/img/3065JacksonStSanFranciscoCA94115to2261FillmoreStSanFranciscoCA94115.gif)


# Implementation Details

# run redis for background job processing:
$ psychiq --host localhost --port 6379 --system skippy

Note: The background worker enables us to queue up many jobs, in order that we can process them all in a non-blocking, asynchronous manner. While this is currently working, there is not currently a web interface with which to queue up jobs, so I have been adding them locally rom my machine.


# Credits:

## Libraries used:


[drakma](https://github.com/edicl/drakma), a Common Lisp HTTP client


[psychiq](https://github.com/fukamachi/psychiq), Background job processing for common lisp


[trivial-download](https://github.com/eudoxia0/trivial-download), a utility for downloading remote files


[zs3](https://github.com/xach/zs3), a library for interacting with AWS's S3


## Misc. Code Snippets:

Range list generating function `#'range` was borrowed from [here](https://stackoverflow.com/questions/13937520/pythons-range-analog-in-common-lisp#answer-13937652)

Bit shifting operations `#'shl` and `#'shr` were borrowed from [here](http://tomszilagyi.github.io/2016/01/CL-bitwise-Rosettacode)


# Before you go

![Unmatched](https://github.com/suterr252/skippy/blob/master/img/unmatched.png)
