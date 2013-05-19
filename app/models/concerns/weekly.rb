module Weekly

  extend ActiveSupport::Concern

  module ClassMethods

    def weeks(date)
      weeks = []
      begin
        weeks << (date.beginning_of_week..date.end_of_week)
        date += 7
      end while date < Date.today
      weeks
    end

  end

end
