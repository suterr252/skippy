Note: My initial spec submission can be found in the project root/submitted.txt

# Specific language implementation used:
[SBCL](http://www.sbcl.org/), Steel Bank Common Lisp

## Some motivation for lisp:
[Beating the Averages, Paul Graham (YCombinator)](http://www.paulgraham.com/avg.html)


# run redis for background job processing:
$ psychiq --host localhost --port 6379 --system skippy

# run server:
$ blahhh...




# Credits:

## Libraries used:

[drakma](https://github.com/edicl/drakma), a Common Lisp HTTP client
[psychiq](https://github.com/fukamachi/psychiq), Background job processing for common lisp
[postmodern](https://github.com/marijnh/Postmodern), a Common Lisp PostgreSQL programming interface
[trivial-download](https://github.com/eudoxia0/trivial-download), a utility for downloading remote files
[zs3](https://github.com/xach/zs3), a library for interacting with AWS's S3


## Misc. Code Snippets:

Range list generating function `#'range' was borrowed from here:
https://stackoverflow.com/questions/13937520/pythons-range-analog-in-common-lisp#answer-13937652

Bit shifting operations `#'shl' and `#'shr' were borrowed from here:
http://tomszilagyi.github.io/2016/01/CL-bitwise-Rosettacode
