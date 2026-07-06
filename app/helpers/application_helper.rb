module ApplicationHelper
  def format_temp(value)
    return "--" if value.blank?
    "#{value.round}°#{unit_system == 'imperial' ? 'F' : 'C'}"
  end

  def format_wind(value)
    return "--" if value.blank?
    "#{value.round} #{unit_system == 'imperial' ? 'mph' : 'km/h'}"
  end

  def format_precip(value)
    return "--" if value.blank?
    "#{value} #{unit_system == 'imperial' ? 'in' : 'mm'}"
  end
end
