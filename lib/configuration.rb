class Configuration
  # values part
  #
  def initialize hash
    hash.each { |k, v|
      instance_variable_set "@#{k}", v
      define_singleton_method k do
        instance_variable_get "@#{k}"
      end
    }
  end
end


if __FILE__ == $0
  require 'minitest/autorun'

  describe Configuration do
    it 'works' do
      assert_equal Configuration.new(hey: 'ok').hey, 'ok'
    end
  end
end
