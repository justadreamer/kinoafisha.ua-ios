#!/usr/bin/python
# coding=utf8

import os
import subprocess
import json
import sys

reload(sys)
sys.setdefaultencoding('utf8')

def get_path(filename):
  return os.path.join(os.path.dirname(os.path.abspath(__file__)),filename)

def get_json(xsl_name):
  proc = subprocess.Popen(["./test_xsl.sh"+" "+xsl_name ], stdout=subprocess.PIPE, shell=True)
  (out, err) = proc.communicate()
  return out

def download_fresh_files():
  os.system('curl -o examples/cities.html http://kinoafisha.ua/cinema/')
  os.system('curl -o examples/cinemas.html http://kinoafisha.ua/cinema/kiev/')
  os.system('curl -o examples/films.html http://kinoafisha.ua/kinoafisha/kiev/')

def test_is_json_valid():
  print "Testing whether we get a valid JSON:"
  assert 0 == os.system('./test.sh')

def test_cities():
  json_string = get_json('cities')
  cities = json.loads(json_string)
  assert len(cities)>=53
  kiev = filter(lambda city: 'Киев' in city['name'], cities)
  assert kiev

def test_films():
  pass

def test_cinemas():
  pass

def test_single_film():
  pass

def test_single_cinema():
  pass


if __name__ == "__main__":
  download_fresh_files()
  test_is_json_valid()
  test_cities()
  test_films()
  test_cinemas()
  test_single_film()
  test_single_cinema()