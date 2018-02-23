# Facebook cleaner

This is a command line script written in ruby that lets you delete all the years from your Facebook. So you can delete all the old content, but not the last one.

For this it uses the facebook mobile page, because it just doesn't have Javascript und presents the last amount of confirmation dialogs, which are stepped through using selenium webdriver.

## Requirements

You need a version of [ruby](https://www.ruby-lang.org) for it and [bundler](http://bundler.io/). The former you can probably easily install via your package manager and the latter one you can install easily via command line afterwards (just type `gem install bundler`).

## Usage

```sh
bundle
ruby run.rb
```

You'll be asked to enter your name, your password (securely of course), your username (that thing, that is written after www.facebook.com/ if you click on your profile) and the year you want to delete.

## Guarantees that it will work?

Nope, but after some iterations it ran through my years of facebook posts and did a pretty good job deleting almost all of it. So it definitely saves you a lot of time.

## License

MIT, see `LICENSE` file
