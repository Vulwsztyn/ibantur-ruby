require "mustache"
file = File.open("./formats_wiki")

lines = file.readlines

last_country_code = nil

config = {}

def maybe_inc_second(arr)
  [arr[0], arr[1] ? arr[1] + 1 : arr[1]]
end

def add_new_country_to_config(line)
  match = /^(?<name>[a-zÀ-ž\s,]+)\s*(?<garbage>\[.*\])*\s*(?<len>\d+)\s*(?<bban_format>(?:\d{1,2}[a-z],*\s*)+)\s*(?<iban_format>(?:[a-z\d]{1,4}\s*)+)\s+(?<rest>\w+\s=.*)/i.match(line)
  unless match
    if line.strip.length == 0
      return
    else
      raise "Regex workn't"
    end
  end
  name = match['name'].strip
  bban_format = match['bban_format'].gsub(/\s+/, '')
  iban_format = match['iban_format'].gsub(/\s+/, '')
  len = match['len'].to_i
  if iban_format.length != len
    raise "Lengths don't match, should be: #{len} but is #{iban_format.length}, iban_format: #{iban_format}"
  end
  country_code = iban_format[0...2]
  national_bank_code_indexes = [iban_format.index('b'), iban_format.rindex('b')]
  branch_code_indexes = [iban_format.index('s'), iban_format.rindex('s')]
  national_checksum_indexes = [iban_format.index('x'), iban_format.rindex('x')]
  account_number_indexes = [iban_format.index('c'), iban_format.rindex('c')]
  # t = Account type (cheque account, savings account etc.) - Come to Brazil
  # n = Owner account number ("1", "2" etc.)[39] - Come to Brazil
  # i = Account holder's kennitala (national identification number) - Iceland
  # m = Currency code - Seszele
  {
    country_code => {
      country_name: name,
      country_code: country_code,
      bban_format: bban_format,
      national_bank_code_indexes: maybe_inc_second(national_bank_code_indexes),
      branch_code_indexes: maybe_inc_second(branch_code_indexes),
      national_checksum_indexes: maybe_inc_second(national_checksum_indexes),
      account_number_indexes: maybe_inc_second(account_number_indexes),
      iban_length: len,
    } }
end

def add_line_to_config(line)
  nil
end

def parse_line(line)
  if line[/^\w\s=\s/i]
    add_line_to_config(line)
  else
    add_new_country_to_config(line)
  end
end

lines.each do |line|
  parsed = parse_line(line)
  config.merge!(parsed) if parsed
end
puts config
puts config.values
puts File.write("../country_config.rb", Mustache.render(File.read("template.mustache"), { countries: config.values }))