# /test_code/sample.rb

# This class is a "God Object" and should
# be flagged for an SRP violation.
class GodClass
  def initialize
    #...
  end

  def load_users
    #...
  end

  def save_users
    #...
  end

  def email_report
    #...
  end

  def calculate_payroll
    #...
  end

  def export_pdf
    #...
  end

  def log_activity
    # This is the 7th method
  end
end

class SmallClass
  def ok
    #...
  end
end
