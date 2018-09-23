SITE_DIR = _site

all: build

serve:
	jekyll serve --watch

build:
	jekyll build

clean:
	jekyll clean
	rm -rf $(SITE_DIR)

upload: build
	./deploy.sh $(SITE_DIR)/* \
	            --exclude *.sublime-workspace \
	            --exclude *.sublime-project \
	            --exclude Makefile \
	            --exclude *.md \
	            --exclude *.sh
