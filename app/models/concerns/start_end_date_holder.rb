module StartEndDateHolder
  extend ActiveSupport::Concern

  def date_range(s_date, e_date)
    ((start_date >= s_date ? start_date : s_date)..(end_date <= e_date ? end_date : e_date))
  end

  def date_to_s(date)
    date.strftime('%Y/%m/%d')
  end

  def start_date_to_s
    date_to_s(start_date)
  end
  
  def end_date_to_s
    date_to_s(end_date)
  end

  def start_end_date_to_s
    "#{start_date_to_s} ～ #{end_date_to_s}"
  end

  included do
    scope :between, -> (s_date, e_date){where("#{self.table_name}.start_date <= ? AND #{self.table_name}.end_date >= ?", e_date, s_date)}
    validates :start_date, presence: true
    validates :end_date, presence: true
    validate :start_date_not_before_end_date
  end

  private
    def start_date_not_before_end_date
      errors.add(:start_date, 'は終了日以前を選択してください') if start_date.nil? || end_date.nil? || start_date > end_date
    end
end
