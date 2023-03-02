require 'delegate'
require 'pathname'


class FileAccess < SimpleDelegator
  def self.provide path, format=nil
    path = Pathname(path).expand_path
    result = FileAccess.new path
    result.format = format
    result
  end

  attr_accessor :format

  def read
    text = File.read to_path
    if format
      format.load text
    else
      text
    end
  end

  def write data
    if format
      data = format.dump data
    end
    File.write to_path, data
  end
end


if __FILE__ == $0
  require 'minitest/autorun'

  describe FileAccess do
    it 'works' do
      file = FileAccess.provide __FILE__
      assert_match /file\.read/, file.read
    end
  end
end
