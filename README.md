# [hardscrabble.net](https://www.hardscrabble.net)

my personal site. powered by [jekyll](http://jekyllrb.com/) and hosted on
[github pages](http://pages.github.com/)

## working on the site

(note to self)

* Run `bin/dev` to generate (and watch for changes then recompile)
* visit <http://localhost:1234>

## publishing a new post

* run `bin/new my great post` to create a draft file.
* run `bin/publish _drafts/my-great-post.md` to move that file into the `_posts`
directory and add the current timestamp

## adding a podcast episode

* record and export an mp3 (the feed assumes mp3)
* upload it to s3, make public, copy the URL
* add a file to _metaphorloop_episodes named, e.g. 4.md for episode 4
* required attributes in the header:
  * `title`
  * `summary`
  * `date`
  * `audio_url`
  * `number_of_bytes` -- actually count the bytes of the audio file, e.g. 4000000
  * `length_as_text` -- e.g. "07:05"
* optional attributes in the header:
  * `custom_art` if an episode should have special art, link it here
