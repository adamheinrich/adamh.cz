CZ_BUCKET = s3://www.adamh.cz/
EN_BUCKET = s3://www.adamheinrich.com/
SITE_DIR = _site

all:
	make en
	make cz

serve:
	jekyll serve --watch

build:
	jekyll build

	# gzip HTML, JS and CSS
	find $(SITE_DIR) \( -iname '*.html' -o -iname '*.css' -o -iname '*.js' \) \
	-exec gzip -9 -n {} \; -exec mv {}.gz {} \;

clean:
	rm -rf $(SITE_DIR)

clear_en:
	$(eval BUCKET := $(EN_BUCKET))

	rm -rf $(SITE_DIR)/*.sublime-workspace
	rm -rf $(SITE_DIR)/*.sublime-project

	rm -rf $(SITE_DIR)/Makefile
	rm -rf $(SITE_DIR)/README.md
	rm -rf $(SITE_DIR)/LICENSE.md

	rm -rf $(SITE_DIR)/kontakt
	rm -rf $(SITE_DIR)/fakturacni-udaje
	rm -rf $(SITE_DIR)/index_cz.html
	rm -rf $(SITE_DIR)/404_cz.html
	rm -rf $(SITE_DIR)/projekty

clear_cz:
	$(eval BUCKET := $(CZ_BUCKET))

	rm -rf $(SITE_DIR)/*.sublime-workspace
	rm -rf $(SITE_DIR)/*.sublime-project

	rm -rf $(SITE_DIR)/Makefile
	rm -rf $(SITE_DIR)/README.md
	rm -rf $(SITE_DIR)/LICENSE.md

	rm -rf $(SITE_DIR)/contact
	rm -rf $(SITE_DIR)/blog
	rm -rf $(SITE_DIR)/public/img
	rm -rf $(SITE_DIR)/projects

	mv $(SITE_DIR)/index_cz.html $(SITE_DIR)/index.html
	mv $(SITE_DIR)/404_cz.html $(SITE_DIR)/404.html

en: build clear_en upload

cz: build clear_cz upload

upload:
	# Sync CSS and JS (CacheL expire in 1 week)
	s3cmd sync --exclude '*.*' --include '*.css' \
	--add-header='Content-Type: text/css' \
	--add-header='Cache-Control: max-age=604800' \
	--add-header='Content-Encoding: gzip' $(SITE_DIR)/ $(BUCKET)

	s3cmd sync --exclude '*.*' --include '*.js' \
	--add-header='Content-Type: application/javascript' \
	--add-header='Cache-Control: max-age=604800' \
	--add-header='Content-Encoding: gzip' $(SITE_DIR)/ $(BUCKET)

	# Sync media files (Cache: expire in 10 weeks)
	s3cmd sync --exclude '*.*' --include '*.png' --include '*.jpg' \
	--include '*.ico' --add-header='Expires: Sat, 20 Nov 2020 18:46:39 GMT' \
	--add-header='Cache-Control: max-age=6048000' $(SITE_DIR)/ $(BUCKET)

	# Sync html files (Cache: 2 hours)
	s3cmd sync --exclude '*.*' --include '*.html' \
	--add-header='Content-Type: text/html' \
	--add-header='Cache-Control: max-age=7200, must-revalidate' \
	--add-header='Content-Encoding: gzip' $(SITE_DIR)/ $(BUCKET)

	# Sync everything else
	s3cmd sync --delete-removed $(SITE_DIR)/ $(BUCKET)
