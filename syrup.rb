class Syrup
  def self.parse(to_parse)
    raise StandardError unless to_parse.is_a?(File)

    case to_parse.getc
    when 't'
      true
    when 'f'
      false
    else
      raise StandardError
    end
  end
end
