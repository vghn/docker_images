# Vlad's Logspout

[![](https://images.microbadger.com/badges/image/vladgh/ls.svg)](https://microbadger.com/images/vladgh/ls "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/vladgh/ls.svg)](https://microbadger.com/images/vladgh/ls "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/commit/vladgh/ls.svg)](https://microbadger.com/images/vladgh/ls "Get your own commit badge on microbadger.com")
[![](https://images.microbadger.com/badges/license/vladgh/ls.svg)](https://microbadger.com/images/vladgh/ls "Get your own license badge on microbadger.com")

Logspout based on https://github.com/gliderlabs/logspout/.
Adds the VladGH Root CA for logs.ghn.me

Note: the empty files `build.sh` and `modules.go` are required because of the ONBUILD commands in the official Dockerfile.
