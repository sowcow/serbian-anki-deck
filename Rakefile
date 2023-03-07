require_relative 'config'

task :blacklist do
  files = `ag -il "^I'm sorry" ./cache/Usage`.strip.lines.map &:strip
  words = files.map { |x| x[%r|cache/Usage/(.+)-usage-examples|, 1] }
  Config.file.generated_blacklist.write words
end
