# Change Log

## [v0.1.1](https://github.com/vghn/docker_images/tree/v0.1.1) (2017-01-06)
[Full Changelog](https://github.com/vghn/docker_images/compare/v0.1.0...v0.1.1)

**Implemented enhancements:**

- Wait for deployment feedback before finishing build [\#14](https://github.com/vghn/docker_images/issues/14)
- Add documentation [\#13](https://github.com/vghn/docker_images/issues/13)
- Consolidate rake tasks [\#50](https://github.com/vghn/docker_images/pull/50) ([vladgh](https://github.com/vladgh))
- Use the Ruby version that is preinstalled on Travis [\#49](https://github.com/vghn/docker_images/pull/49) ([vladgh](https://github.com/vladgh))
- Update LICENSE [\#47](https://github.com/vghn/docker_images/pull/47) ([vladgh](https://github.com/vladgh))
- Rename folder for sensitive files to `./secure` [\#44](https://github.com/vghn/docker_images/pull/44) ([vladgh](https://github.com/vladgh))
- Clean-up base images and rake tasks [\#43](https://github.com/vghn/docker_images/pull/43) ([vladgh](https://github.com/vladgh))
- Improve puppet server health check [\#41](https://github.com/vghn/docker_images/pull/41) ([vladgh](https://github.com/vladgh))
- Update Puppet Server version [\#40](https://github.com/vghn/docker_images/pull/40) ([vladgh](https://github.com/vladgh))
- Remove rack-ssl from vpm-api [\#39](https://github.com/vghn/docker_images/pull/39) ([vladgh](https://github.com/vladgh))
- Improve Rakefile [\#38](https://github.com/vghn/docker_images/pull/38) ([vladgh](https://github.com/vladgh))
- Add a backup image [\#37](https://github.com/vghn/docker_images/pull/37) ([vladgh](https://github.com/vladgh))
- Fix RSpec tests [\#36](https://github.com/vghn/docker_images/pull/36) ([vladgh](https://github.com/vladgh))
- Add Deluge image [\#35](https://github.com/vghn/docker_images/pull/35) ([vladgh](https://github.com/vladgh))
- Add MiniDLNA image and rename VPM images [\#34](https://github.com/vghn/docker_images/pull/34) ([vladgh](https://github.com/vladgh))

**Fixed bugs:**

- Fix git branch [\#51](https://github.com/vghn/docker_images/pull/51) ([vladgh](https://github.com/vladgh))
- Alpine 3.5 specifies Python 2 [\#48](https://github.com/vghn/docker_images/pull/48) ([vladgh](https://github.com/vladgh))
- Add the findutils package [\#46](https://github.com/vghn/docker_images/pull/46) ([vladgh](https://github.com/vladgh))
- Delete empty dirs left over from S3 sync command [\#45](https://github.com/vghn/docker_images/pull/45) ([vladgh](https://github.com/vladgh))
- Fix Puppet Server health check typo [\#42](https://github.com/vghn/docker_images/pull/42) ([vladgh](https://github.com/vladgh))
- Use after\_success hook for deployment [\#33](https://github.com/vghn/docker_images/pull/33) ([vladgh](https://github.com/vladgh))

## [v0.1.0](https://github.com/vghn/docker_images/tree/v0.1.0) (2016-12-03)
[Full Changelog](https://github.com/vghn/docker_images/compare/v0.0.9...v0.1.0)

**Implemented enhancements:**

- Do not pin versions of system packages [\#26](https://github.com/vghn/docker_images/issues/26)
- Deploy docker-compose directly from TravisCI [\#23](https://github.com/vghn/docker_images/issues/23)
- Add rubycritic and reek [\#21](https://github.com/vghn/docker_images/issues/21)
- Unify rake tasks and add release task [\#32](https://github.com/vghn/docker_images/pull/32) ([vladgh](https://github.com/vladgh))
- Rename badge [\#31](https://github.com/vghn/docker_images/pull/31) ([vladgh](https://github.com/vladgh))
- Add exact time stamps to aws sync commands [\#30](https://github.com/vghn/docker_images/pull/30) ([vladgh](https://github.com/vladgh))
- Add exact time stamps to aws sync commands [\#29](https://github.com/vghn/docker_images/pull/29) ([vladgh](https://github.com/vladgh))
- Update Puppet Server version [\#28](https://github.com/vghn/docker_images/pull/28) ([vladgh](https://github.com/vladgh))
- Misc updates [\#27](https://github.com/vghn/docker_images/pull/27) ([vladgh](https://github.com/vladgh))
- Deploy docker-compose directly from TravisCI [\#24](https://github.com/vghn/docker_images/pull/24) ([vladgh](https://github.com/vladgh))

## [v0.0.9](https://github.com/vghn/docker_images/tree/v0.0.9) (2016-09-10)
[Full Changelog](https://github.com/vghn/docker_images/compare/v0.0.8...v0.0.9)

**Implemented enhancements:**

- Add README badges [\#20](https://github.com/vghn/docker_images/issues/20)
- Add Microbadger webhooks [\#19](https://github.com/vghn/docker_images/issues/19)

## [v0.0.8](https://github.com/vghn/docker_images/tree/v0.0.8) (2016-09-10)
[Full Changelog](https://github.com/vghn/docker_images/compare/v0.0.7...v0.0.8)

**Fixed bugs:**

- Clean-up Rakefile [\#18](https://github.com/vghn/docker_images/issues/18)

## [v0.0.7](https://github.com/vghn/docker_images/tree/v0.0.7) (2016-09-10)
[Full Changelog](https://github.com/vghn/docker_images/compare/v0.0.6...v0.0.7)

**Implemented enhancements:**

- Replace TravisCI slug/token webhook with verified signature [\#17](https://github.com/vghn/docker_images/issues/17)
- Add environment aware logging [\#16](https://github.com/vghn/docker_images/issues/16)

## [v0.0.6](https://github.com/vghn/docker_images/tree/v0.0.6) (2016-08-22)
[Full Changelog](https://github.com/vghn/docker_images/compare/v0.0.5...v0.0.6)

**Implemented enhancements:**

- Remove VPM and VGS from api deployment [\#15](https://github.com/vghn/docker_images/issues/15)
- Update README for TravisCI deployment [\#7](https://github.com/vghn/docker_images/issues/7)
- Create better labels [\#5](https://github.com/vghn/docker_images/issues/5)
- Improve SSL grade for API [\#1](https://github.com/vghn/docker_images/issues/1)

**Merged pull requests:**

- Improve API image [\#8](https://github.com/vghn/docker_images/pull/8) ([vladgh](https://github.com/vladgh))
- Improve labels [\#6](https://github.com/vghn/docker_images/pull/6) ([vladgh](https://github.com/vladgh))

## [v0.0.5](https://github.com/vghn/docker_images/tree/v0.0.5) (2016-08-20)
[Full Changelog](https://github.com/vghn/docker_images/compare/v0.0.4...v0.0.5)

**Closed issues:**

- Automate change log generation [\#2](https://github.com/vghn/docker_images/issues/2)

**Merged pull requests:**

- Update Readme [\#4](https://github.com/vghn/docker_images/pull/4) ([vladgh](https://github.com/vladgh))
- Automate change log generation [\#3](https://github.com/vghn/docker_images/pull/3) ([vladgh](https://github.com/vladgh))

## [v0.0.4](https://github.com/vghn/docker_images/tree/v0.0.4) (2016-08-19)
[Full Changelog](https://github.com/vghn/docker_images/compare/v0.0.3...v0.0.4)

## [v0.0.3](https://github.com/vghn/docker_images/tree/v0.0.3) (2016-08-17)
[Full Changelog](https://github.com/vghn/docker_images/compare/v0.0.2...v0.0.3)

## [v0.0.2](https://github.com/vghn/docker_images/tree/v0.0.2) (2016-08-17)
[Full Changelog](https://github.com/vghn/docker_images/compare/v0.0.1...v0.0.2)

## [v0.0.1](https://github.com/vghn/docker_images/tree/v0.0.1) (2016-08-17)


\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*