require 'nokogiri'

module Clean
  module_function

  LIST_ITEM_CLEAN = [
    /^\d+\.\s*/, # numered
    /^\*\s+/,    # stars
    /^\-\s+/,    # dashes
  ]

  def examples text
    text.lines.select { |x| x =~ /\(/ }
      .map(&:strip)
      .reject { |x| x =~ /Warning:|Note:/ }
      .map { |x|
        pattern = LIST_ITEM_CLEAN.find { |re| re =~ x }
        if pattern
          x.sub pattern, ''
        else
          x
        end
      }
      .join(?\n)
  end

  def trans html
    (first, *rest) = html.lines
    after_found_empty = false
    xs = rest.select {|x|
      if after_found_empty == false
        after_found_empty = x.strip == ''
      end
      after_found_empty
    }
    xs.unshift first
    xs.reject! { |x| x =~ /Definitions of/ || x =~ /<b>English/ }
    html = xs.map { |x| x.strip }.join(?\n).strip.gsub "\n\n\n", "\n\n"

    doc = Nokogiri.HTML html
    doc.css('img').remove
    doc.to_html
  end
end


if __FILE__ == $0
  require 'minitest/autorun'

  describe Clean do
    it '.examples works' do
      input = <<-END
      :

      1. abc ()

      * def ()

      ghi ()

      END
      expected = "abc ()\ndef ()\nghi ()"

      result = Clean.examples input
      assert_equal result, expected
    end
  end
end
