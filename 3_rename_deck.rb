require_relative 'config'

file = Config.file.deck_anki
temp_dir = file.parent + 'tmp_renaming_deck'
temp_dir.rmtree if temp_dir.exist?
temp_dir.mkpath

Dir.chdir temp_dir do
  system "cp #{file.to_s.inspect} ."
  name = file.basename.to_s

  system "unzip #{name.inspect}"
  system "rm #{name.inspect}"

  value = `sqlite3 collection.anki2 "select decks from col;"`.strip
  value.sub! '"Default"', '"Serbian en.wiktionary Davinci AI"'
  v = value.inspect[1..-2]
  system %( echo "update col set decks='#{v}';" | sqlite3 collection.anki2 )

  system "zip #{name.inspect} *"

  system "mv #{name.inspect} #{file.to_s.inspect}"
end

temp_dir.rmtree
