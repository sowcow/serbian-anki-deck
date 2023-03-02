module Transliterate
  module_function

  TO_LATIN = {
    "а" => "a",
    "б" => "b",
    "в" => "v",
    "г" => "g",
    "д" => "d",
    "ђ" => "đ",
    "е" => "e",
    "ж" => "ž",
    "з" => "z",
    "и" => "i",
    "ј" => "j",
    "к" => "k",
    "л" => "l",
    "љ" => "lj",
    "м" => "m",
    "н" => "n",
    "њ" => "nj",
    "о" => "o",
    "п" => "p",
    "р" => "r",
    "с" => "s",
    "т" => "t",
    "ћ" => "ć",
    "у" => "u",
    "ф" => "f",
    "х" => "h",
    "ц" => "c",
    "ч" => "č",
    "џ" => "dž",
    "ш" => "š",
    "А" => "A",
    "Б" => "B",
    "В" => "V",
    "Г" => "G",
    "Д" => "D",
    "Ђ" => "Đ",
    "Е" => "E",
    "Ж" => "Ž",
    "З" => "Z",
    "И" => "I",
    "Ј" => "J",
    "К" => "K",
    "Л" => "L",
    "Љ" => "Lj",
    "М" => "M",
    "Н" => "N",
    "Њ" => "Nj",
    "О" => "O",
    "П" => "P",
    "Р" => "R",
    "С" => "S",
    "Т" => "T",
    "Ћ" => "Ć",
    "У" => "U",
    "Ф" => "F",
    "Х" => "H",
    "Ц" => "C",
    "Ч" => "Č",
    "Џ" => "Dž",
    "Ш" => "Š",
  }

  TO_CYRILLIC_PAIRS = TO_LATIN.invert.select { |k,_| k.length == 2 }
  TO_CYRILLIC_SINGLES = TO_LATIN.invert.select { |k,_| k.length == 1 }

  def to_latin cyrillic
    cyrillic.chars.map { |x|
      got = TO_LATIN[x]
      got || x
    }.join
  end

  def to_cyrillic latin
    result = latin.dup
    TO_CYRILLIC_PAIRS.each { |k,v|
      result.gsub! k, v
    }
    TO_CYRILLIC_SINGLES.each { |k,v|
      result.gsub! k, v
    }
    result
  end
end


if __FILE__ == $0
  require 'minitest/autorun'

  describe Transliterate do
    it 'works' do
      cyr = 'ЧЏ 1'
      lat = 'ČDž 1'
      assert_equal lat, Transliterate.to_latin(cyr)
      assert_equal cyr, Transliterate.to_cyrillic(lat)
    end
  end
end
