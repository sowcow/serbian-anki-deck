require 'yaml'
require 'pathname'
require_relative 'l'


# - depends on translate-shell tool/package being installed
# - depends on esc2html tool/package being installed
#
class Trans
  def initialize config
    @config = config
  end

  attr_reader :config

  def get_html word, direction
    text = get_text word, direction
    html = `echo #{text.inspect} | esc2html`.strip
    html[/<pre.+<\/pre>/m]
  end

  def get_text word, direction
    file = trans_text_file word, direction
    return File.read file if file.exist?

    L.info "fetching translation: #{word}"
    result = `trans #{word} #{direction}`.strip

    throw "translation failed?, no result" if result == ''
    file.parent.mkpath unless file.parent.exist?
    File.write file, result
    sleep config.fetch_pause if config.fetch_pause

    result
  end

  def trans_text_file word, direction
    place = Pathname config.cache_dir
    place += self.class.name
    place + "#{word}-#{direction}.txt"
  end
end


if __FILE__ == $0
  require 'minitest/autorun'
  require 'ostruct'
  require 'tmpdir'


  describe Trans do
    before do
      @dir = Dir.mktmpdir 'mini-test'
      config = OpenStruct.new(
        cache_dir: @dir,
        fetch_pause: nil,
      )
      @trans = Trans.new config
    end

    after do
      FileUtils.remove_entry @dir
    end

    it 'works' do
      result = @trans.get_html 'biti', 'sr:en'
      assert_match /to be/, result
    end
  end
end
