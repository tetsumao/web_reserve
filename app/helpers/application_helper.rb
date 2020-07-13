module ApplicationHelper
  def date_to_s_with_wday(date)
    date.strftime("%Y/%m/%d(#{wday_to_s(date.wday)})")
  end
  def wday_to_s(wday)
    '日月火水木金土'[wday]
  end
  def td_rate_tag(reserved, stock)
    rate = reserved / stock
    class_name = 'align-middle text-center'
    if rate <= 0.5
      class_name += ' rate-50'
    elsif rate <= 0.85
      class_name += ' rate-85'
    else
      class_name += ' rate-100'
    end
    tag.td "#{reserved} / #{stock}", class: class_name
  end
end
