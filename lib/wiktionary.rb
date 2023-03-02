require 'yaml'
require 'nokogiri'
require 'erb'
require 'pathname'
require_relative 'get'
require_relative 'l'


# rough way to extract needed part of Wiktionary article
# it sometimes renders not needed stuff
# but not enough to be significant
#
class Wiktionary
  def initialize config
    @config = config
  end

  def get_html word
    place = Pathname @config.cache_dir
    place += self.class.name
    file = place + "#{word}.html"
   
    return File.read file if file.exist?

    L.info "fetching article: #{word}"
    text = fetch word
    place.mkpath unless place.exist?
    File.write file, text
    text
  end

  def fetch word
    url = url_template % ERB::Util.url_encode(word)
    get = Get.new @config
    page = clean get.get url
  end

  def url_template
    "https://en.wiktionary.org/wiki/%s##{@config.language}"
  end

  def header_re
    /#{@config.language}/i
  end

  # 1. keep only parent
  # 2. clean stuff among it's children

  # remove all before h2 /Serbo/
  # remove all after(including) h2 that follows ↑
  # remove all after(including) #catlinks
  #
  def clean page
    doc = Nokogiri.HTML page

    headers = doc.css('h2')
    needed = headers.find { |x| x.text =~ header_re }

    if needed
      doc = needed.parent

      keep_paths = []
      keep = []
      rest = []
      deleting = true

      doc.traverse { |x|
        if x == needed
          deleting = false
        else
          if deleting == false
            deleting = true if x.matches? '#catlinks'
            deleting = true if x.matches? 'h2'
          end
        end

        if !deleting
          keep_paths << x.path
          keep << x
        else
          rest << x
        end
      }

      rest.each { |x|
        unless x.path =~ /text|\?/
          # rough check to keep parents of uselful nodes
          unless keep_paths.find { |child_path| child_path =~ /#{Regexp.escape x.path}/ }
            x.remove
          end
        end
      }

      doc.css('.mw-editsection').remove
      doc.css('img').remove
      doc.to_html
    else
      return '' # no fitting data at all
    end
  end
end


if __FILE__ == $0
  require 'minitest/autorun'
  require 'ostruct'
  require 'tmpdir'


  describe Wiktionary do
    before do
      @dir = Dir.mktmpdir 'mini-test'
      config = OpenStruct.new(
        cache_dir: @dir,
        language: 'Serbo-Croatian',
      )
      @subj = Wiktionary.new config
    end

    after do
      FileUtils.remove_entry @dir
    end

    it 'works' do
      result = @subj.get_html 'rekao'
      assert_match /participle/i, result
    end
  end
end
