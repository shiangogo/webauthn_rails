class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  def encode(data)
    data = [data].pack('m0')
    data.chomp!('==') or data.chomp!('=')
    data.tr!('+/', '-_')
    data
  end

  def decode(data)
    if !data.end_with?('=') && data.length % 4 != 0
      data = data.ljust((data.length + 3) & ~3, '=')
      data.tr!('-_', '+/')
    else
      data = data.tr('-_', '+/')
    end
    data.unpack1('m0')
  end
end
