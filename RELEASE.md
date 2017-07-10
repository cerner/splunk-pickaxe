# How to release

This project is hosted on https://rubygems.org.  You can see it [here][project-url].

Releasing the project requires these steps:

0. Set the version number in the code
1. `gem build splunk-pickaxe.gemspec` and `gem push splunk-pickaxe*.gem`
2. `git tag -a NEW-TAG -m MESSAGE ABOUT RELEASE` (be sure it follows [semver][semantic-versioning])
3. Update `master` to a new minor version

Incorporate a GitHub [project release][github-release-url] as well.

[project-url]: https://rubygems.org/gems/splunk-pickaxe
[semantic-versioning]: http://semver.org/
[github-release-url]: https://help.github.com/articles/creating-releases/
