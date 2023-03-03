require_relative 'lib/configuration'
require_relative 'lib/file_access'
require 'pathname'
require 'yaml'

here = Pathname __dir__


config = {
  words_count: 10_000,
  deck_name: 'Serbian en.wiktionary ChatGPT/Davinci AI',
  trans: Configuration.new(
    cache_dir: here + 'cache',
    fetch_pause: 2, # sec.
  ),
  usage: Configuration.new(
    cache_dir: here + 'cache', # I wonder if adding implicit inheritance of a kind could play well here
    fetch_pause: 25, # 25 sec. - <150 requests/hour - below empirical chat-gpt limit that I got
    command: 'chatgpt', # - for ChatGPT through chatgpt-wrapper
    #command: File.expand_path('~/go/bin/cligpt'), # - for Davinci through cligpt instead, no need for pause then
  ),
  wiktionary: Configuration.new(
    cache_dir: here + 'cache',
    language: 'Serbo-Croatian',
  ),
  file: Configuration.new(
    input: FileAccess.provide(here + 'data/sr_50k.txt'),
    words: FileAccess.provide(here + 'data/words.yml', YAML),
    deck_yaml: FileAccess.provide(here + 'data/deck.yml', YAML),
    deck_anki: FileAccess.provide(here + 'data/Serbian-en-Wiktionary-AI.apkg'),
  ),
}

Config = Configuration.new config
