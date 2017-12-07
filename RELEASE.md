# How to release

This project is hosted on https://rubygems.org.  You can see it [here][project-url].

Releasing the project requires these steps:

1. Ensure the code has built successfully and everything is ready to be released
2. Close the current milestone associated to the release
3. Install release gems (`bundle install ...`)
4. Run release task `bundle exec rake release`

Incorporate a GitHub [project release][github-release-url] as well.

[project-url]: https://rubygems.org/gems/splunk-pickaxe
[semantic-versioning]: http://semver.org/
[github-release-url]: https://help.github.com/articles/creating-releases/
