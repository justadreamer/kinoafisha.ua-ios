~/bin/xsltproc --html --xincludestyle --param baseURL "'http://kinoafisha.ua'" $1.xsl examples/$1.html | jsonlint $2
