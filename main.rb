require "pry"

require "hash_dot"
Hash.use_dot_syntax = true
Hash.hash_dot_use_default = true

require 'dry/monads'
extend Dry::Monads[:result]

def clean_iban(number)
  Success(number.gsub(/[\s\r\n\-;]/, '').upcase)
end

def global_validate(iban)
  return Failure("Too short") if iban.length < 4
  transformed_number = iban[4...] + iban[0...2]
  checksum = iban[2...4]
  calculate_checksum(transformed_number)
    .bind { |x| x == checksum ? Success(iban) : Failure("Niepoprawna suma kontrolna - #{checksum}. Powinna być #{x}") }
end

def calculate_checksum(number)
  Success(number)
    .bind { |x| x.split('').map { |chr| to_hexatrigesimal(chr) } }
    .then { |x| x.inject(Success('')) { |acc, num| acc.either(-> a { num.either(-> n { Success(a + n) }, -> _ { num }) }, -> _ { acc }) } }
    .fmap { |x| x.to_i }
    .fmap { |x| x * 100 }
    .fmap { |x| 98 - (x % 97) }
    .fmap { |x| format('%02d', x) }
    .either(-> x { Success(x) }, -> x { Failure("#{x} #{number}") })
end

def to_hexatrigesimal(chr)
  if '0' <= chr && chr <= '9'
    Success(chr)
  elsif 'A' <= chr && chr <= 'Z'
    Success((chr.ord - 'A'.ord + 10).to_s)
  else
    Failure("#{chr} nie jest dozwolonym znakiem dla IBAN.")
  end
end

def get_country_code(iban)
  iban[0...2]
end

def get_checksum(iban)
  iban[2...4].to_i
end

def get_local_checksum(iban)
  procs = {
    AL: -> x { x[11] },
    BE: -> x { x[14...16] },
    BA: -> x { x[18...20] },
  }
  country_code = get_country_code(iban).to_sym
  procs.key?(country_code) ? Success(procs[country_code].call(iban).to_i) : Failure("No way to get local checksum for country #{country_code}")
end

def get_bank_code(iban)
  procs = {
    AL: -> x { x[4...7] },
    BE: -> x { x[4...7] },
    BA: -> x { x[4...7] },
  }
  country_code = get_country_code(iban).to_sym
  procs.key?(country_code) ? Success(procs[country_code].call(iban)) : Failure("No way to get bank code for country #{country_code}")
end

def get_branch_code(iban)
  procs = {
    AL: -> x { x[7...11] },
    BE: -> { '' },
    BA: -> x { x[7...10] },
  }
  country_code = get_country_code(iban).to_sym
  procs.key?(country_code) ? Success(procs[country_code].call(iban)) : Failure("No way to get branch code for country #{country_code}")
end

def get_account_number(iban)
  procs = {
    AL: -> x { x[12...28] },
    BE: -> x { x[7...14] },
    BA: -> x { x[10...18] },
  }
  country_code = get_country_code(iban).to_sym
  procs.key?(country_code) ? Success(procs[country_code].call(iban)) : Failure("No way to get account number for country #{country_code}")
end

def albania_validate(iban)
  calculated_checksum = get_bank_code(iban)
                          .bind { |x| get_branch_code(iban).either(-> y { Success(x + y) }, -> y { Failure(y) }) }
                          .fmap { |x| x.split('') }
                          .fmap { |x| x.map { |chr| chr.to_i } }
                          .fmap { |x| x.zip([9, 7, 3, 1, 9, 7, 3, 1]) }
                          .fmap { |x| x.map { |num, weight| num * weight } }
                          .fmap { |x| x.sum }
                          .fmap { |x| x % 10 }
                          .fmap { |x| x == 0 ? 0 : 10 - x }
  calculated_checksum.bind { |x| get_local_checksum(iban).either(-> y { x == y ? Success(iban) : Failure("Niepoprawna suma kontrolna - #{y}. Powinna być #{x}: #{iban}") }, -> y { Failure(y) }) }
end

def belgium_validate(iban)
  calculated_checksum = get_bank_code(iban)
                          .bind { |x| get_account_number(iban).either(-> y { Success(x + y) }, -> y { Failure(y) }) }
                          .fmap { |x| x.to_i }
                          .fmap { |x| x % 97 }
                          .fmap { |x| x == 0 ? 97 : x }
  calculated_checksum.bind { |x| get_local_checksum(iban).either(-> y { x == y ? Success(iban) : Failure("Niepoprawna suma kontrolna - #{y}. Powinna być #{x}: #{iban}") }, -> y { Failure(y) }) }
end

def iso7064_mod97_10(str)
  ai = 1
  check = str[-1].to_i
  str[...-1].reverse.each_char do |ch|
    ai = (ai * 10) % 97
    check += ai * ch.to_i
  end
  98 - (check % 97)
end

def bosnia_and_herzegovina_validate(iban)
  intermediate_checksum = get_bank_code(iban)
                            .bind { |x| get_branch_code(iban).either(-> y { Success(x + y) }, -> y { Failure(y) }) }
                            .bind { |x| get_account_number(iban).either(-> y { Success(x + y) }, -> y { Failure(y) }) }
                            .bind { |x| get_local_checksum(iban).either(-> y { Success(x + y.to_s) }, -> y { Failure(y) }) }
                            .fmap { |x| puts x; x }
  # .fmap { |x| iso7064_mod97_10(x)}
  # .fmap { |x| x.to_i }

  calculated_checksum = intermediate_checksum
                          .fmap { |x| x + '111000' }
                          .fmap { |x| x.to_i }
                          .fmap { |x| x % 97 }
                          .fmap { |x| puts x; x }
                          .fmap { |x| 98 - x }
  calculated_checksum.bind { |x| get_local_checksum(iban).either(-> y { x == y ? Success(iban) : Failure("Niepoprawna suma kontrolna - #{y}. Powinna być #{x}: #{iban}") }, -> y { Failure(y) }) }
end

def local_validate(iban)
  procs = {
    AL: -> x { albania_validate(x) },
    BE: -> x { belgium_validate(x) },
    BA: -> x { Success(x) }, # it only exists so that the global checksum is 39
  }
  country_code = get_country_code(iban).to_sym
  procs.key?(country_code) ? procs[country_code].call(iban) : Failure("No way to validate for country #{country_code}")
end

def validate_iban(number)
  Success(number)
    .bind { |x| clean_iban(x) }
    .bind { |x| global_validate(x) }
    .bind { |x| local_validate(x) }
end

['al', 'be', 'ba', 'hr'].each do |country_code|
  file = File.open("./example-ibans/#{country_code}-ibans")

  lines = file.readlines
  lines.each do |line|
    puts validate_iban(line)
  end
end

# binding.pry