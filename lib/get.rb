require 'pathname'
require 'httparty'


# access to urls cached in a local directory
# compensates for open-uri-cached that failed to work
# (wget could be usable too with it's automatic links absolutization)
#
class Get
  def initialize config
    @config = config
  end

  ESCAPE = { # char => char
    '/' => '_',
  }

  def get url
    file = url_to_file url

    if file.exist?
      File.read file
    else
      text = basic_fetch url
      file.parent.mkpath unless file.parent.exist?
      File.write file, text
      text
    end
  end

  def url_to_file url
    place = Pathname @config.cache_dir
    place += self.class.name
    name = url.tr(ESCAPE.keys.join, ESCAPE.values.join)
    file = place + name
  end

  def basic_fetch url
    res = HTTParty.get url
    return '' if res.code == 404
    throw "wtf request error: #{res.code}" unless res.code == 200
    res.body
  end
end


if __FILE__ == $0
  require 'minitest/autorun'
  require 'ostruct'
  require 'tmpdir'


  describe Get do
    before do
      @dir = Dir.mktmpdir 'mini-test'
      config = OpenStruct.new(
        cache_dir: @dir,
      )
      @subj = Get.new config
    end

    after do
      FileUtils.remove_entry @dir
    end

    it 'works' do
      result = @subj.get 'http://google.com'
      assert_match /doctype/i, result
    end
  end
end
