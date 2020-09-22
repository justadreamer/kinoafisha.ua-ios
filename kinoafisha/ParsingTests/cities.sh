~/bin/xsltproc --html --param 'baseURL' '"https://kinoafisha.com"' ../XSLT/cities.xsl ../html/cities.html 2>/dev/null | jsonlint > cities.json.gitignore
diff cities.json.gitignore cities_snapshot.json
