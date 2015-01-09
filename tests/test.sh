EXITVAL=0

for xsl in 'cities' 'cinemas' 'films' 'single_cinema' 'single_film'
  do ./test_xsl.sh $xsl 1>/dev/null 2>/dev/null;
    retval=$?
    if [ $retval -eq 0 ]; then
      echo "testing $xsl ok"
    else
      echo "testing $xsl failed"
      EXITVAL=1
    fi
  done

exit $EXITVAL