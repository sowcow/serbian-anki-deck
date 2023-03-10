require 'pathname'
require_relative 'l'

class Usage
  def initialize config
    @config = config
  end

  def get_examples word, empty_if_absent=false
    place = Pathname @config.cache_dir
    place += self.class.name
    file = place + "#{word}-usage-examples"

    if file.exist?
      File.read file
    else
      return '' if empty_if_absent
      L.info "fetching usage: #{word}"
      text = fetch_usage_examples word
      file.parent.mkpath unless file.parent.exist?
      File.write file, text
      text
    end
  end

  def fetch_usage_examples word, backoff_min = 10
    result = `#{@config.command} 'multiple example sentences in Serbian that use Serbian word "#{word}" in different forms and different positions, highlight the word with star right after it and write translations sentences in english in parenthesis'`.strip

    #throw "no usage examples for word #{word}" if result == ''
    if result == ''
      L.info "backoff #{backoff_min} minutes"
      sleep 60 * backoff_min
      return fetch_usage_examples word, backoff_min * 2
    end

    sleep @config.fetch_pause if @config.fetch_pause
    result
  end
end


if __FILE__ == $0
  require 'minitest/autorun'
  require 'ostruct'
  require 'tmpdir'


  describe Usage do
    before do
      @dir = Dir.mktmpdir 'mini-test'
      config = OpenStruct.new(
        cache_dir: @dir,
        fetch_pause: nil,
        command: 'chatgpt',
        #command: File.expand_path('~/go/bin/cligpt'),
      )
      @usage = Usage.new config
    end

    after do
      FileUtils.remove_entry @dir
    end

    it 'works' do
      result = @usage.get_examples 'biti'
      puts result
      assert_match /bi.+bi.+bi/im, result
    end
  end
end
