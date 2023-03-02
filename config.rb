require_relative 'lib/configuration'
require_relative 'lib/file_access'
require 'pathname'
require 'yaml'

here = Pathname __dir__


config = {
  words_count: 10_000,
  trans: Configuration.new(
    cache_dir: here + 'cache',
    fetch_pause: 2, # sec.
  ),
  usage: Configuration.new(
    cache_dir: here + 'cache', # to have inheritance of a kind...?
    fetch_pause: 2, # sec.
    cligpt: File.expand_path('~/go/bin/cligpt'),
  ),
  wiktionary: Configuration.new(
    cache_dir: here + 'cache',
    language: 'Serbo-Croatian',
  ),
  file: Configuration.new(
    input: FileAccess.provide(here + 'data/sr_50k.txt'),
    words: FileAccess.provide(here + 'data/words.yml', YAML),
    deck_yaml: FileAccess.provide(here + 'data/deck.yml', YAML),
    deck_anki: FileAccess.provide(here + 'data/Serbian-en-Wiktionary-Davinci-AI.apkg'),
  ),
}

Config = Configuration.new config
