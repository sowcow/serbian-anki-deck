require_relative 'config'
require_relative 'lib/trans'
require_relative 'lib/usage'
require_relative 'lib/wiktionary'
require_relative 'lib/transliterate'
require_relative 'lib/clean'

# - collects all needed information
# - generates the deck

words = Config.file.words.read
trans = Trans.new Config.trans
usage = Usage.new Config.usage
wiktionary = Wiktionary.new Config.wiktionary

data = []
words.each { |serbian_word|
  #puts serbian_word
  #puts Clean.trans trans.get_html(serbian_word, 'sr:en')
  #puts with_absolute_links wiktionary.get_html Transliterate.to_cyrillic serbian_word
  #puts with_absolute_links wiktionary.get_html serbian_word
  #puts Clean.examples usage.get_examples serbian_word

  front = serbian_word

  articles = []
  articles.push with_absolute_links wiktionary.get_html serbian_word
  articles.push with_absolute_links wiktionary.get_html Transliterate.to_cyrillic serbian_word
  articles.sort_by! { |x| -Transliterate.to_latin(x).length }
  articles.reject! { |x| x.strip.empty? }

  back = <<-END.strip
<div style='text-align: left'>
#{ Clean.trans trans.get_html(serbian_word, 'sr:en') }
<hr />
#{ articles * '<hr />' }
<hr />
#{ use_list Clean.examples usage.get_examples(serbian_word, !Config.fetch_new_examples) }
</div>
  END

  data << { 'type' => 'Basic', 'fields' => { 'Front' => front, 'Back' => back }}
}

Config.file.deck_yaml.write data
Config.file.deck_anki.unlink if Config.file.deck_anki.exist?
cmd = [
  'anki-cli-unofficial load',
  Config.file.deck_yaml.to_s.inspect,
  Config.file.deck_anki.to_s.inspect,
] * ' '
system cmd


BEGIN {
  def with_absolute_links html
    html
      .gsub('<source src="//', '<source src="https://')
      .gsub('<a href="//', '<a href="https://')
      .gsub('<a href="/', '<a href="https://en.wiktionary.org/')
  end

  def use_list text
    text = text.strip.lines.map(&:strip)
      .map { |x| "<li>#{x}</li>" } * ?\n
    '<ol>%s</ol>' % text
  end
}
