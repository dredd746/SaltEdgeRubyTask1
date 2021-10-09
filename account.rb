class ACCOUNT
  @transactions = Array.new()
  attr_accessor :name, :currency , :balance , :nature

  def initialize(name,currency,balance,nature,transaction)
    @name = name
    @currency = currency
    @balance = balance
    @nature = nature
    @transactions = [transaction.hashed]
  end

  def add_transaction(transaction)
      @transactions.push([transaction.hashed])
  end

  def show_data
    puts "Name: %s , Currency: %s , Balance: %s , Nature: %s " % [@name,@currency,@balance.to_s,@nature]
    puts @transactions
  end

  def as_json(options={})
    {
      name: @name,
      balance: @balance,
      currency: @currency,
      nature: @nature,
      transactions: @transactions
    }
  end

  def to_json(*options)
    as_json(*options).to_json(*options)
  end

end