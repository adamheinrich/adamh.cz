# adamheinrich.com
Source code for my personal websites [adamheinrich.com](http://adamheinrich.com) and [adamh.cz](http://adamh.cz). I've used some great open source projects which was the main reason to make it source public.

## Usage
Just run

    jekyll serve --watch

and head to [localhost](http://localhost) to see the site in action.

To build everything and push to Amazon S3, run

    ./_deploy.sh all

The script will gzip and copy contents of the _site directory. Some files are renamed and some deleted (the CZ version does not contain blog and english pages).

## Based on
 * [Jekyll](http://jekyllrb.com/) - the static site generator
 * [Poole](http://getpoole.com/) - butler for Jekyll. Great thing to start with!
 * [Publish](https://kovshenin.com/themes/publish/) - Clean and mininal theme originally for Wordpress. I'm using its CSS and layout
 * [Font Awesome](http://fortawesome.github.io/Font-Awesome/) - The iconic font and CSS toolkit
 * [Deploy script](http://www.savjee.be/2014/03/Jekyll-to-S3-deploy-script-with-gzip/) by Xavier Decuyper
 * [Share buttons widget](http://codingtips.kanishkkunal.in/share-buttons-jekyll/) by Kanishk Kunal

Thank you!

## License

Seet the [LICENSE.md](LICENSE.md) file.