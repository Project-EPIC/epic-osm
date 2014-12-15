rm -r doc/
rm -r ../doc/

rdoc --all -x Gemfile.lock -x Gemfile -x .gemspec -x .css -x .geojson -x .json  -x _site -x _posts -x _layouts -x _includes _x assets -x pages -x index.html -x index.md -x .yml -x spec -x sample_projects -x jekyll -x .sh -x setup -x Rakefile -x .config --main README.md