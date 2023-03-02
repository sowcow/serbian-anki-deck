require_relative 'config'
require_relative 'lib/transliterate'

# - normalizes
# - clears duplicates
# - selects a subset

text = Config.file.input.read

words_and_counts = text.strip.lines.map { |x|
  (word, count) = x.strip.split ' ', 2
  word = Transliterate.to_latin word # normalizes, there are duplicates
  [word, Integer(count)]
}

grouped = words_and_counts.group_by { |x|
  x[0]
}.map { |k, pairs|
  [k, pairs.map { |x| x[1] }.reduce(:+)]
}
grouped.sort_by! { |x| -x[1] }

words = grouped.map { |x| x[0] }

words = words.take Config.words_count

Config.file.words.write words
