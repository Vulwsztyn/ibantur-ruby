require "pry"

require "hash_dot"
Hash.use_dot_syntax = true
Hash.hash_dot_use_default = true

require 'dry/monads'
extend Dry::Monads[:result]

require_relative "./country_config.rb"

def clean_iban(number)
  Success(number.gsub(/[^a-z\d]/i, '').upcase)
end

def global_validate(iban)
  return Failure("Too short") if iban.length < 4
  transformed_number = iban[4...] + iban[0...2]
  checksum = iban[2...4]
  calculate_checksum(transformed_number)
    .bind { |x| x == checksum ? Success(iban) : Failure("#{iban}: Niepoprawna suma kontrolna - #{checksum}. Powinna być #{x}") }
end

def concat_results(arr_of_results, concat_fn: -> x, y { x + y })
  arr_of_results.inject { |acc, num| acc.either(-> a { num.either(-> n { Success(concat_fn.call(a, n)) }, -> _ { num }) }, -> _ { acc }) }
end

def calculate_checksum(number)
  Success(number)
    .bind { |x| x.split('').map { |chr| to_hexatrigesimal(chr) } }
    .then { |x| concat_results(x) }
    .fmap(&:to_i)
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

def get_part_of_iban(iban, config_field)
  country_code = get_country_code(iban).to_sym
  indexes = CountryConfig.config[country_code][config_field.to_sym]
  !indexes[0].nil? ? Success(iban[indexes[0]...indexes[1]]) : Failure("No way to get #{config_field} for country #{country_code}")
end

def get_local_checksum(iban)
  get_part_of_iban(iban, 'national_checksum')
end

def get_bank_code(iban)
  get_part_of_iban(iban, 'bank_code')
end

def get_branch_code(iban)
  get_part_of_iban(iban, 'branch_code')
end

def get_account_number(iban)
  get_part_of_iban(iban, 'account_number')
end

def weighted(text, weights, modulo, postproc, prezip: -> x { x }, presum: -> x { x })
  text
    .split('')
    .map(&:to_i)
    .then { |x| prezip.call(x) }
    .zip(weights.cycle)
    .map { |num, weight| num * weight }
    .then { |x| presum.call(x) }
    .sum
    .then { |x| x % modulo }
    .then { |x| postproc.call(x) }
end

def iso7064_mod97_10(text, modulo: 97, minuend: 98, premod: -> x { x * 100 })
  text
    .to_i
    .then { |x| premod.call(x) }
    .then { |x| x % modulo }
    .then { |x| minuend - x }
end

def compare_results(calculated, actual)
  concat_results([calculated, actual], concat_fn: -> x, y { x == y.to_i })
    .bind { |x| x ? Success() : Failure([calculated, actual]) }
end

def compare_to_local_checksum(iban, calculated_checksum)
  compare_results(calculated_checksum, get_local_checksum(iban)).either(-> x { Success(x) }, -> x { Failure("#{x} #{iban}") })
end

def get_iban_parts(iban, parts, concat_fn: -> x, y { x + y })
  getters = {
    bank_code: -> x { get_bank_code(x) },
    branch_code: -> x { get_branch_code(x) },
    account_number: -> x { get_account_number(x) },
  }
  parts
    .map { |x| getters[x.to_sym].call(iban) }
    .then { |x| concat_results(x, concat_fn: concat_fn) }
end

def generic_national_checksum_calculation(iban, parts, calcluation_fn)
  get_iban_parts(iban, parts).fmap { |x| calcluation_fn.call(x) }
end

def generic_national_checksum_check(iban, parts, calcluation_fn)
  calculated_checksum = generic_national_checksum_calculation(iban, parts, calcluation_fn)
  compare_to_local_checksum(iban, calculated_checksum)
end

def albania_validate(iban)
  generic_national_checksum_check(
    iban,
    ['bank_code', 'branch_code'],
    -> x { weighted(x, [9, 7, 3, 1, 9, 7, 3, 1], 10, -> y { y == 0 ? 0 : 10 - y }) }
  )
end

def belgium_validate(iban)
  generic_national_checksum_check(
    iban,
    ['bank_code', 'account_number'],
    -> x { (x.to_i % 97).then { |x| x == 0 ? 97 : x } }
  )
end

def croatia_validate(iban)
  def mod_10_11(acc, num)
    sum = acc + num
    subtotal = sum % 10 == 0 ? 10 : sum % 10
    (subtotal * 2) % 11
  end

  calculate = -> x do
    y = x.split('').inject(10) { |acc, num| mod_10_11(acc, num.to_i) }
    y == 1 ? 0 : 11 - y
  end

  calculated_checksum_bank_code = generic_national_checksum_calculation(iban, ['bank_code'], calculate)
  calculated_checksum_acc_number = generic_national_checksum_calculation(iban, ['account_number'], calculate)

  bank_matches = compare_results(calculated_checksum_bank_code, Success(9))
  acc_matches = compare_results(calculated_checksum_acc_number, Success(9))

  concat_results([bank_matches, acc_matches], concat_fn: -> _, _ { true }).either(-> _ { Success(iban) }, -> x { Failure("#{x} #{iban}") })
end

def czech_validate(iban)
  calculated_checksum_acc_number = get_account_number(iban)
                                     .fmap { |x| weighted(x, [6, 3, 7, 9, 10, 5, 8, 4, 2, 1], 11, -> y { y == 0 ? 0 : 11 - y }) }
  calculated_checksum_branch_number = get_branch_code(iban)
                                        .fmap { |x| weighted(x, [10, 5, 8, 4, 2, 1], 11, -> y { y == 0 ? 0 : 11 - y }) }
  acc_matches = compare_results(calculated_checksum_acc_number, Success(0))
  branch_matches = compare_results(calculated_checksum_branch_number, Success(0))
  concat_results([acc_matches, branch_matches], concat_fn: -> _, _ { true }).either(-> _ { Success(iban) }, -> x { Failure("#{x} #{iban}") })
end

def east_timor_validate(iban)
  generic_national_checksum_check(
    iban,
    ['bank_code', 'account_number'],
    -> x { iso7064_mod97_10(x) }
  )
end

def estonia_validate(iban)
  generic_national_checksum_check(
    iban,
    ['branch_code', 'account_number'],
    -> x { weighted(x, [7, 3, 1], 10, -> y { y == 0 ? 0 : 10 - y }, prezip: -> y { y.reverse }) }
  )
end

def finland_validate(iban)
  generic_national_checksum_check(
    iban,
    ['bank_code', 'account_number'],
    -> x { weighted(x, [2, 1], 10, -> y { y == 0 ? 0 : 10 - y }, presum: -> y { y.map { |num| num % 10 + num / 10 } }) }
  )
end

def france_validate(iban)
  def french_letter_to_digit(letter)
    return letter.to_i if letter[/^\d$/]
    if letter <= 'I'
      letter.ord - 'A'.ord + 1 # A-I => 1-9
    elsif letter <= 'R'
      letter.ord - 'I'.ord # J-R => 1-9
    else
      letter.ord - 'R'.ord + 1 # S-Z => 2-9
    end
  end

  calculated_checksum = get_bank_code(iban)
                          .bind { |x| get_branch_code(iban).either(-> y { Success([x, y]) }, -> y { Failure(y) }) }
                          .bind { |x| get_account_number(iban).either(-> y { Success(x + [y]) }, -> y { Failure(y) }) }
                          .fmap { |x| x.map { |e| e.split('') } }
                          .fmap { |x| x.map { |e| e.map { |l| french_letter_to_digit(l).to_s } } }
                          .fmap { |x| x.map(&:join) }
                          .fmap { |x| x.map(&:to_i) }
                          .fmap { |x| x.zip([89, 15, 3]) } # no idea where these come from
                          .fmap { |x| x.map { |num, weight| num * weight } }
                          .fmap(&:sum)
                          .fmap { |x| iso7064_mod97_10(x, minuend: 97, premod: -> x { x }) }

  compare_to_local_checksum(iban, calculated_checksum)
end

def hungary_validate(iban)
  calculate = -> x { weighted(x, [9, 7, 3, 1], 10, -> y { y == 0 ? 0 : 10 - y }) }
  calculated_checksum_bank_code = get_iban_parts(iban, ['bank_code', 'branch_code']).fmap { |x| calculate.call(x) }
  calculated_checksum_branch_number = get_account_number(iban).fmap { |x| calculate.call(x) }
  national_checksum = get_local_checksum(iban) # this is not technically correct since they are not consecutive - HUkk bbbs sssX cccc cccc cccc cccX

  return national_checksum if national_checksum.failure?

  bank_code_checksum = national_checksum.value![0]
  branch_number_checksum = national_checksum.value![-1]
  bank_code_matches = calculated_checksum_bank_code.bind { |x| x == bank_code_checksum.to_i ? Success(x) : Failure("Niepoprawna suma kontrolna1 - #{x}. Powinna być #{bank_code_checksum}.") }
  branch_matches = calculated_checksum_branch_number.bind { |x| x == branch_number_checksum.to_i ? Success(x) : Failure("Niepoprawna suma kontrolna2 - #{x}. Powinna być #{branch_number_checksum}.") }
  if bank_code_matches.failure? || branch_matches.failure?
    return Failure(bank_code_matches.either(-> _ { branch_matches }, -> y { branch_matches.either(-> z { Failure(y) }, -> z { Failure([y, z, iban]) }) }))
  end
  Success(iban)
end

def iceland_validate(iban)
  kennitala = iban[16..]
  calculated_checksum = Success(kennitala[0...8])
                          .fmap { |x| weighted(x, [3, 2, 7, 6, 5, 4, 3, 2], 11, -> y { y == 0 ? 0 : 11 - y }) }
  checksum = kennitala[8].to_i
  calculated_checksum.bind { |x| checksum == x ? Success(iban) : Failure("Niepoprawna suma kontrolna - #{checksum}. Powinna być #{calculated_checksum.value!}: #{iban}") }
end

def italy_validate(iban)
  def odd_map(letter)
    digit_map = [1, 0, 5, 7, 9, 13, 15, 17, 19, 21]
    letter_map = [1, 0, 5, 7, 9, 13, 15, 17, 19, 21, 2, 4, 18, 20, 11, 3, 6, 8, 12, 14, 16, 10, 22, 25, 24, 23]
    if letter[/^\d$/]
      digit_map[letter.to_i]
    else
      letter_map[letter.ord - 'A'.ord]
    end
  end

  def even_map(letter)
    if letter[/^\d$/]
      letter.to_i
    else
      letter.ord - 'A'.ord
    end
  end

  calculated_checksum = get_bank_code(iban)
                          .bind { |x| get_branch_code(iban).either(-> y { Success(x + y) }, -> y { Failure(y) }) }
                          .bind { |x| get_account_number(iban).either(-> y { Success(x + y) }, -> y { Failure(y) }) }
                          .fmap { |x| x.split('') }
                          .fmap { |x| x.each_with_index.map { |chr, i| (i + 1).even? ? even_map(chr) : odd_map(chr) } }
                          .fmap(&:sum)
                          .fmap { |x| x % 26 }
                          .fmap { |x| ('A'.ord + x).chr }
  calculated_checksum.bind { |x| get_local_checksum(iban).either(-> y { x == y ? Success(iban) : Failure("Niepoprawna suma kontrolna - #{y}. Powinna być #{x}: #{iban}") }, -> y { Failure(y) }) }
end

def north_macedonia_validate(iban)
  generic_national_checksum_check(
    iban,
    ['bank_code', 'account_number'],
    -> x { iso7064_mod97_10(x) }
  )
end

def mauritania_validate(iban)
  generic_national_checksum_check(
    iban,
    ['bank_code', 'branch_code', 'account_number'],
    -> x { iso7064_mod97_10(x, minuend: 97) }
  )
end

def montenegro_validate(iban)
  generic_national_checksum_check(
    iban,
    ['bank_code', 'account_number'],
    -> x { iso7064_mod97_10(x) }
  )
end

def norway_validate(iban)
  calculated_checksum = get_bank_code(iban)
                          .bind { |x| get_account_number(iban).either(-> y { Success([x, y]) }, -> y { Failure(y) }) }
                          .fmap { |x, y| y.start_with?('00') ? y[2..] : x + y }
                          .fmap { |x| weighted(x, [5, 4, 3, 2, 7, 6, 5, 4, 3, 2], 11, -> y { y == 0 ? 0 : 11 - y }) } # TODO 1 - invalid
  compare_to_local_checksum(iban, calculated_checksum)
end

def poland_validate(iban)
  generic_national_checksum_check(
    iban,
    ['bank_code', 'branch_code'],
    -> x { weighted(x, [3, 9, 7, 1], 10, -> y { y == 0 ? 0 : 10 - y }) }
  )
end

def portugal_validate(iban)
  generic_national_checksum_check(
    iban,
    ['bank_code', 'branch_code', 'account_number'],
    -> x { iso7064_mod97_10(x) }
  )
end

def serbia_validate(iban)
  generic_national_checksum_check(
    iban,
    ['bank_code', 'account_number'],
    -> x { iso7064_mod97_10(x) }
  )
end

def slovenia_validate(iban)
  generic_national_checksum_check(
    iban,
    ['bank_code', 'branch_code', 'account_number'],
    -> x { iso7064_mod97_10(x) }
  )
end

def spain_validate(iban)
  calculate = -> weights, x { weighted(x, weights, 11, -> y { y <= 1 ? y : 11 - y }) }
  calculated_checksum_bank_code = get_iban_parts(iban, ['bank_code', 'branch_code'])
                                    .fmap { |x| calculate.call([4, 8, 5, 10, 9, 7, 3, 6], x) }
  calculated_checksum_acc_number = get_account_number(iban)
                                     .fmap { |x| calculate.call([1, 2, 4, 8, 5, 10, 9, 7, 3, 6], x) }
  national_checksum = get_local_checksum(iban) # this is not technically correct since they are not consecutive

  return national_checksum if national_checksum.failure?

  bank_code_checksum = national_checksum.value![0]
  acc_number_checksum = national_checksum.value![-1]
  bank_code_matches = calculated_checksum_bank_code.bind { |x| x == bank_code_checksum.to_i ? Success(x) : Failure("ES1Niepoprawna suma kontrolna - #{x}. Powinna być #{bank_code_checksum}.") }
  branch_matches = calculated_checksum_acc_number.bind { |x| x == acc_number_checksum.to_i ? Success(x) : Failure("ES2Niepoprawna suma kontrolna - #{x}. Powinna być #{acc_number_checksum}.") }
  # TODO - combaing failures
  if bank_code_matches.failure? || branch_matches.failure?
    return Failure(bank_code_matches.either(-> _ { branch_matches }, -> y { branch_matches.either(-> z { Failure(y) }, -> z { Failure([y, z, iban]) }) }))
  end
  Success(iban)
end

def tunisia_validate(iban)
  generic_national_checksum_check(
    iban,
    ['bank_code', 'branch_code', 'account_number'],
    -> x { iso7064_mod97_10(x, minuend: 97) }
  )
end

def local_validate(iban)
  procs = {
    AL: -> x { albania_validate(x) },
    BE: -> x { belgium_validate(x) },
    BA: -> x { Success(x) }, # it only exists so that the global checksum is 39
    HR: -> x { croatia_validate(x) },
    CZ: -> x { czech_validate(x) },
    TL: -> x { east_timor_validate(x) },
    EE: -> x { estonia_validate(x) },
    FI: -> x { finland_validate(x) },
    FR: -> x { france_validate(x) },
    HU: -> x { hungary_validate(x) },
    IS: -> x { iceland_validate(x) },
    IT: -> x { italy_validate(x) },
    MK: -> x { north_macedonia_validate(x) },
    MR: -> x { mauritania_validate(x) },
    MC: -> x { france_validate(x) }, # monaco uses the same algorithm as France
    ME: -> x { montenegro_validate(x) },
    NO: -> x { norway_validate(x) },
    PL: -> x { poland_validate(x) },
    PT: -> x { portugal_validate(x) },
    SM: -> x { italy_validate(x) }, # San Marino uses the same algorithm as Italy
    RS: -> x { serbia_validate(x) },
    SK: -> x { czech_validate(x) }, # Slovakia uses the same algorithm as Czechia
    SI: -> x { slovenia_validate(x) },
    ES: -> x { spain_validate(x) },
    TN: -> x { tunisia_validate(x) },
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

done = ['al', 'be', 'ba', 'hr', 'cz', 'tl', 'ee', 'fi', 'fr', 'hu', 'is', 'it', 'mk', 'mr', 'mc', 'me', 'no', 'pl', 'sm', 'rs', 'sk', 'es', 'tn']
ok = 0

done.each do |country_code|
  file = File.open("./example-ibans/#{country_code}-ibans")

  lines = file.readlines
  lines.each do |line|
    validate_iban(line).either(-> x { ok += 1 }, -> x { puts "Failure: #{x}" })
  end

end
puts ok
