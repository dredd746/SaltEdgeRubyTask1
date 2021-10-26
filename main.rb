require 'watir'
require 'selenium-webdriver'
require 'rubygems'
require 'nokogiri'
require './account.rb'
require './transactions.rb'
require 'json'

Selenium::WebDriver::Chrome.driver_path = "C:/Users/Lil-Dredd/Downloads/chromedriver_win32/chromedriver.exe"
$p
$b = Watir::Browser.new :chrome #, headless: true

# DREDD DREDD DREDD
# Extract data rules:
# wait_for_parsing -> always 1st instruction
# get_username :return name , get_balance :return balance_amount,currency  , get_nature :return card_types
# get_transaction -> !!! after this you cant extract get_username,get_balance and get_nature !!!
# serialize -> Serialize for stocking all data
# DREDD DREDD DREDD

def wait_for_parsing
  $b.goto 'https://www.sberbank.ru/common/img/uploaded/secure/demosbol/general.html#/'
  sleep(6)
  $p = Nokogiri::HTML.parse($b.html)
end

def get_balance
  full_balance = 0.0

  #Extract card balances
  all_balances = $p.css('.overallAmount').text
  all_balances = all_balances.delete(' ')
  balance = all_balances.split('.',-1)
  currency = balance[1].gsub(/(\d+|(,))/,"")

  #Balance addition
  for item in balance
    full_balance = full_balance + item.tr(',','.').to_f
  end

  #Returning balance and currency of cards
  return full_balance,currency
end

def get_username
  #Extract full username
   $p.css('#previousEnterInfo > span > span').text
end

def get_nature
  all_types = ''

  #Extracting card types
  nature = $p.css('.cardType').text
    for item in nature.split
      all_types = item + ' + ' + all_types
    end
  all_types.strip!

  #Deleting last '+'
  all_types[all_types.length-1] = ''
  return all_types
end

def get_transactions

  # Saving data for intialization of ACCOUNT CLASS
  balance,currency = get_balance
  name = get_username
  nature = get_nature
  account = nil

  #Opening needed page to extract transactions
  $b.a(:href => "#/history_operations").click!
  sleep(6)
  $p = Nokogiri::HTML.parse($b.html)
  tr_step = 2

  #Count number of rows by class
  count_limit = $p.search(".ListLine0").size + $p.search(".ListLine1").size + 1 # Bcs tr_step starts with 2 we add +1

  loop do

    #Extract table data
    payment_description = $p.css('#simpleTable0 > div > table > tbody > tr:nth-child(%s) > td.payment-description.executed > table.paymentDescription > tbody > tr:nth-child(1)' % [tr_step]).text
    payment_date = $p.css('#simpleTable0 > div > table > tbody > tr:nth-child(%s) > td:nth-child(4)' % [tr_step]).text
    payment_money =  $p.css('#simpleTable0 > div > table > tbody > tr:nth-child(%s) > td.align-right.executed' % [tr_step]).text

    #Deleting whitespaces
    payment_description.strip!
    payment_date.strip!
    payment_money.strip!

    # LOOP BREAK CONDITIONS
    # LOOP BREAK CONDITIONS
    # LOOP BREAK CONDITIONS
    #Checking transcation date
    time = Time.new
    date = payment_date.split('.',-1)
    date_interval1 = (date[1].to_i * 30 ) + date[0].to_i
    date_interval2 = (time.month.to_i * 30) + time.day.to_i
    # 90 days = 3 months
    # Dont check year bcs table data is out of date (2015)
    # Change days if no loaded data.
    days = 120
    if  (date_interval1 - date_interval2).abs > days
      break
    end
    #If transaction date is older than 90 days we dont check rest of the table.

    #Extract Currency
    payment_currency = payment_money.delete!(' ')
    payment_currency = payment_currency.gsub(/(\d+|(,))/,"")
    payment_currency.delete!('−')

    #Exract Payment amount
    payment_amount = payment_money.delete!('−')
    payment_amount = payment_amount.to_s
    payment_amount = payment_amount.split(',',-1)
    payment_amount = payment_amount[0]

    #Serialize extracted data
    transaction = TRANSACTIONS.new(payment_date,payment_description,payment_amount,payment_currency,get_username)
    if account == nil
      account = ACCOUNT.new(name,currency,balance,nature,transaction)
    else
      account.add_transaction(transaction)
      account.show_data
      p
    end

    #Counting tr_steps to parse table data
    tr_step = tr_step+1

    # LOOP BREAK CONDITIONS
    # LOOP BREAK CONDITIONS
    # LOOP BREAK CONDITIONS
    #Checking if we are in table size
    if tr_step > count_limit
      break
    end

  end
  return account
end

wait_for_parsing
a = get_transactions
fJSON = File.open("REZULTATUL.json","w")
fJSON.write(a.to_json)
fJSON.close
