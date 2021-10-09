class TRANSACTIONS < ACCOUNT
  attr_accessor :date , :description , :amount , :currency , :account_name

  def initialize(date,description,amount,currency,account_name)
    @date = date
    @description = description
    @amount = amount
    @currency = currency
    @account_name = account_name
  end

  def show_data
    puts "Date: %s | amount: %s | currency: %s | name: %s | desc: %s" % [@date,@amount,@currency,@account_name,@description]
  end

  def hashed
    return {"date:" => @date,"description:" => @description,"amount:" => @amount,"currency:" => @currency,"account_name:" => @account_name}
  end

end