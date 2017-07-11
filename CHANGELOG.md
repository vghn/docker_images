# Change Log

## [v0.2.1](https://github.com/vghn/docker_images/tree/v0.2.1) (2017-07-11)
[Full Changelog](https://github.com/vghn/docker_images/compare/v0.2.0...v0.2.1)

**Implemented enhancements:**

- Adhere to recommended community standards [\#107](https://github.com/vghn/docker_images/issues/107)
- Add eyaml gem in puppet server cli [\#105](https://github.com/vghn/docker_images/issues/105)

**Fixed bugs:**

- Fix docker package name in TravisCI [\#106](https://github.com/vghn/docker_images/issues/106)

## [v0.2.0](https://github.com/vghn/docker_images/tree/v0.2.0) (2017-06-06)
[Full Changelog](https://github.com/vghn/docker_images/compare/v0.1.1...v0.2.0)

**Implemented enhancements:**

- Allow webhook to execute a command in a docker container [\#104](https://github.com/vghn/docker_images/issues/104)
- APP\_ENV is now preferred and recommended over RACK\_ENV for setting environment [\#103](https://github.com/vghn/docker_images/issues/103)
- Upgrade Alpine to 3.6 [\#98](https://github.com/vghn/docker_images/issues/98)
- Reduce Sync container log noise [\#25](https://github.com/vghn/docker_images/issues/25)
- Create a rake task to update or check versions [\#22](https://github.com/vghn/docker_images/issues/22)
- CSR sign script should allow multiple AWS accounts [\#12](https://github.com/vghn/docker_images/issues/12)
- Specify the environment to be deployed [\#11](https://github.com/vghn/docker_images/issues/11)
- Increase max\_user\_watches [\#10](https://github.com/vghn/docker_images/issues/10)
- Pin versions in all dockerfiles [\#9](https://github.com/vghn/docker_images/issues/9)
- Use a configuration file for the webhook [\#102](https://github.com/vghn/docker_images/pull/102) ([vladgh](https://github.com/vladgh))
- Simplify AWS setup in the Puppet CSR script [\#101](https://github.com/vghn/docker_images/pull/101) ([vladgh](https://github.com/vladgh))
- Allow PuppetServer's CSR script to read Docker secrets [\#100](https://github.com/vghn/docker_images/pull/100) ([vladgh](https://github.com/vladgh))
- Minor changes [\#99](https://github.com/vghn/docker_images/pull/99) ([vladgh](https://github.com/vladgh))
- Update options for the release task [\#97](https://github.com/vghn/docker_images/pull/97) ([vladgh](https://github.com/vladgh))
- Allow restarting docker swarm services [\#94](https://github.com/vghn/docker_images/pull/94) ([vladgh](https://github.com/vladgh))
- Cache Travis public key [\#93](https://github.com/vghn/docker_images/pull/93) ([vladgh](https://github.com/vladgh))
- Small changes to rake tasks and webhook [\#92](https://github.com/vghn/docker_images/pull/92) ([vladgh](https://github.com/vladgh))
- Updates [\#91](https://github.com/vghn/docker_images/pull/91) ([vladgh](https://github.com/vladgh))
- Use the new puppet server base image for PuppetDB [\#90](https://github.com/vghn/docker_images/pull/90) ([vladgh](https://github.com/vladgh))
- Remove Faraday gem version requirement [\#89](https://github.com/vghn/docker_images/pull/89) ([vladgh](https://github.com/vladgh))
- Update syntax for Vtasks [\#87](https://github.com/vghn/docker_images/pull/87) ([vladgh](https://github.com/vladgh))
- Use the new options for release [\#86](https://github.com/vghn/docker_images/pull/86) ([vladgh](https://github.com/vladgh))
- Use the shared contexts from Vtasks gem [\#85](https://github.com/vghn/docker_images/pull/85) ([vladgh](https://github.com/vladgh))
- Restart services instead of starting stopped ones [\#84](https://github.com/vghn/docker_images/pull/84) ([vladgh](https://github.com/vladgh))
- Add Tini to images [\#83](https://github.com/vghn/docker_images/pull/83) ([vladgh](https://github.com/vladgh))
- Minor changes [\#82](https://github.com/vghn/docker_images/pull/82) ([vladgh](https://github.com/vladgh))
- Add Code of Conduct [\#79](https://github.com/vghn/docker_images/pull/79) ([vladgh](https://github.com/vladgh))
- Add support for LetsEncrypt [\#78](https://github.com/vghn/docker_images/pull/78) ([vladgh](https://github.com/vladgh))
- Migrate to the Vtasks gem [\#77](https://github.com/vghn/docker_images/pull/77) ([vladgh](https://github.com/vladgh))
- Rename images and add Load Balancer and LetsEncrypt [\#75](https://github.com/vghn/docker_images/pull/75) ([vladgh](https://github.com/vladgh))
- Use the docker-api gem [\#73](https://github.com/vghn/docker_images/pull/73) ([vladgh](https://github.com/vladgh))
- Improvements [\#72](https://github.com/vghn/docker_images/pull/72) ([vladgh](https://github.com/vladgh))
- Add script to sign certificate request [\#71](https://github.com/vghn/docker_images/pull/71) ([vladgh](https://github.com/vladgh))
- Minor changes [\#70](https://github.com/vghn/docker_images/pull/70) ([vladgh](https://github.com/vladgh))
- Improve Rakefile [\#69](https://github.com/vghn/docker_images/pull/69) ([vladgh](https://github.com/vladgh))
- Upgrade Docker and Ruby versions for API [\#68](https://github.com/vghn/docker_images/pull/68) ([vladgh](https://github.com/vladgh))
- Clean-up api image [\#67](https://github.com/vghn/docker_images/pull/67) ([vladgh](https://github.com/vladgh))
- Fix Puppet Server Image [\#66](https://github.com/vghn/docker_images/pull/66) ([vladgh](https://github.com/vladgh))
- Improve API output [\#65](https://github.com/vghn/docker_images/pull/65) ([vladgh](https://github.com/vladgh))
- Fix docker tags [\#64](https://github.com/vghn/docker_images/pull/64) ([vladgh](https://github.com/vladgh))
- Improve VPM API [\#61](https://github.com/vghn/docker_images/pull/61) ([vladgh](https://github.com/vladgh))
- Add hiera-eyaml to the server [\#60](https://github.com/vghn/docker_images/pull/60) ([vladgh](https://github.com/vladgh))
- Separate AWS CLI and R10K from the API code \(use containers instead\) [\#59](https://github.com/vghn/docker_images/pull/59) ([vladgh](https://github.com/vladgh))
- Use the new Trusty build container in TravisCI [\#56](https://github.com/vghn/docker_images/pull/56) ([vladgh](https://github.com/vladgh))
- Improve VPM-API [\#55](https://github.com/vghn/docker_images/pull/55) ([vladgh](https://github.com/vladgh))
- Improve VPM-API [\#54](https://github.com/vghn/docker_images/pull/54) ([vladgh](https://github.com/vladgh))
- Base the API image on vladgh/awcliruby [\#53](https://github.com/vghn/docker_images/pull/53) ([vladgh](https://github.com/vladgh))
- Improve API [\#52](https://github.com/vghn/docker_images/pull/52) ([vladgh](https://github.com/vladgh))

**Fixed bugs:**

- Fix typo [\#96](https://github.com/vghn/docker_images/pull/96) ([vladgh](https://github.com/vladgh))
- Fix container id issues [\#95](https://github.com/vghn/docker_images/pull/95) ([vladgh](https://github.com/vladgh))
- Undo gem versions [\#88](https://github.com/vghn/docker_images/pull/88) ([vladgh](https://github.com/vladgh))
- Fix command line parameters for the certbot command [\#81](https://github.com/vghn/docker_images/pull/81) ([vladgh](https://github.com/vladgh))
- Fix unbound OPTIONS variable [\#80](https://github.com/vghn/docker_images/pull/80) ([vladgh](https://github.com/vladgh))
- Update MicroBadger web hooks [\#76](https://github.com/vghn/docker_images/pull/76) ([vladgh](https://github.com/vladgh))
- Prevent threads from failing silently [\#74](https://github.com/vghn/docker_images/pull/74) ([vladgh](https://github.com/vladgh))
- Fix docker latest tags [\#63](https://github.com/vghn/docker_images/pull/63) ([vladgh](https://github.com/vladgh))
- Fix api and server images [\#62](https://github.com/vghn/docker_images/pull/62) ([vladgh](https://github.com/vladgh))
- Fix YAML indentation in the R10K template [\#58](https://github.com/vghn/docker_images/pull/58) ([vladgh](https://github.com/vladgh))
- Fix base64 requirement [\#57](https://github.com/vghn/docker_images/pull/57) ([vladgh](https://github.com/vladgh))

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