# Puppet Docker Images
[![Build Status](https://travis-ci.org/vghn/puppet-docker.svg?branch=master)](https://travis-ci.org/vghn/puppet_docker)

Docker Images for Vlad's Puppet Control Repo

## Development

- Run rake tasks

  ```
  bundle exec rake {TASK}
  ```
- Run rake tasks for specific image

  ```
  bundle exec rake {IMAGE}:{TASK}
  ```

- Upload deployment ssh key

  ```
  travis env set DEPLOY_RSA $(sudo base64 --wrap=0 ~/.ssh/deploy_rsa)
  ```

## Contribute

1. Open an issue to discuss proposed changes
2. Fork the repository
3. Create your feature branch: `git checkout -b my-new-feature`
4. Commit your changes: `git commit -am 'Add some feature'`
5. Push to the branch: `git push origin my-new-feature`
6. Submit a pull request :D

## License
Licensed under the Apache License, Version 2.0.
