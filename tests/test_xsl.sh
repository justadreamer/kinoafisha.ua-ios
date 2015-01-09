~/bin/xsltproc --html --xincludestyle --param baseURL "'http://kinoafisha.ua'" ../XSLT/$1.xsl examples/$1.html 2>/dev/null| jsonlint $2
