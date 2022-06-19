require "pry"

require "hash_dot"
Hash.use_dot_syntax = true
Hash.hash_dot_use_default = true

require 'dry/monads'
extend Dry::Monads[:result]

require_relative "./country_config.rb"

def clean_iban(number)
  Success(number.gsub(/[^a-z0-9]/i, '').upcase)
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

def albania_validate(iban)
  calculated_checksum = get_bank_code(iban)
                          .bind { |x| get_branch_code(iban).either(-> y { Success(x + y) }, -> y { Failure(y) }) }
                          .fmap { |x| weighted(x, [9, 7, 3, 1, 9, 7, 3, 1], 10, -> y { y == 0 ? 0 : 10 - y }) }
  calculated_checksum.bind { |x| get_local_checksum(iban).either(-> y { x == y.to_i ? Success(iban) : Failure("Niepoprawna suma kontrolna - #{y}. Powinna być #{x}: #{iban}") }, -> y { Failure(y) }) }
end

def belgium_validate(iban)
  calculated_checksum = get_bank_code(iban)
                          .bind { |x| get_account_number(iban).either(-> y { Success(x + y) }, -> y { Failure(y) }) }
                          .fmap { |x| x.to_i }
                          .fmap { |x| x % 97 }
                          .fmap { |x| x == 0 ? 97 : x }
  calculated_checksum.bind { |x| get_local_checksum(iban).either(-> y { x == y.to_i ? Success(iban) : Failure("Niepoprawna suma kontrolna - #{y}. Powinna być #{x}: #{iban}") }, -> y { Failure(y) }) }
end

# def iso7064_mod97_10(str)
#   ai = 1
#   check = str[-1].to_i
#   str[...-1].reverse.each_char do |ch|
#     ai = (ai * 10) % 97
#     check += ai * ch.to_i
#   end
#   98 - (check % 97)
# end

# def bosnia_and_herzegovina_validate(iban)
#   intermediate_checksum = get_bank_code(iban)
#                             .bind { |x| get_branch_code(iban).either(-> y { Success(x + y) }, -> y { Failure(y) }) }
#                             .bind { |x| get_account_number(iban).either(-> y { Success(x + y) }, -> y { Failure(y) }) }
#                             .bind { |x| get_local_checksum(iban).either(-> y { Success(x + y.to_s) }, -> y { Failure(y) }) }
#                             .fmap { |x| puts x; x }
#   # .fmap { |x| iso7064_mod97_10(x)}
#   # .fmap { |x| x.to_i }
#
#   calculated_checksum = intermediate_checksum
#                           .fmap { |x| x + '111000' }
#                           .fmap { |x| x.to_i }
#                           .fmap { |x| x % 97 }
#                           .fmap { |x| puts x; x }
#                           .fmap { |x| 98 - x }
#   calculated_checksum.bind { |x| get_local_checksum(iban).either(-> y { x == y ? Success(iban) : Failure("Niepoprawna suma kontrolna - #{y}. Powinna być #{x}: #{iban}") }, -> y { Failure(y) }) }
# end

def croatia_validate(iban)
  def mod_10_11(acc, num)
    sum = acc + num
    subtotal = sum % 10 == 0 ? 10 : sum % 10
    (subtotal * 2) % 11
  end

  calculated_checksum_bank_code = get_bank_code(iban)
                                    .fmap { |x| x.split('').inject(10) { |acc, num| mod_10_11(acc, num.to_i) } }
                                    .fmap { |x| x == 1 ? 0 : 11 - x }
  calculated_checksum_acc_number = get_account_number(iban)
                                     .fmap { |x| x.split('').inject(10) { |acc, num| mod_10_11(acc, num.to_i) } }
                                     .fmap { |x| x == 1 ? 0 : 11 - x }
  bank_matches = calculated_checksum_bank_code.bind { |x| x == 9 ? Success(x) : Failure("Niepoprawna suma kontrolna - #{x}. Powinna być 9.") }
  acc_matches = calculated_checksum_acc_number.bind { |x| x == 9 ? Success(x) : Failure("Niepoprawna suma kontrolna - #{x}. Powinna być 9.") }
  if bank_matches.failure? || acc_matches.failure?
    return bank_matches.either(-> y { acc_matches }, -> y { acc_matches.either(-> z { Failure(y) }, -> z { Failure([y, z]) }) })
  end
  Success(iban)
end

def czech_validate(iban)
  calculated_checksum_acc_number = get_account_number(iban)
                                     .fmap { |x| weighted(x, [6, 3, 7, 9, 10, 5, 8, 4, 2, 1], 11, -> y { y == 0 ? 0 : 11 - y }) }
  calculated_checksum_branch_number = get_branch_code(iban)
                                        .fmap { |x| weighted(x, [10, 5, 8, 4, 2, 1], 11, -> y { y == 0 ? 0 : 11 - y }) }
  acc_matches = calculated_checksum_acc_number.bind { |x| x == 0 ? Success(x) : Failure("Niepoprawna suma kontrolna - #{x}. Powinna być 0.") }
  branch_matches = calculated_checksum_branch_number.bind { |x| x == 0 ? Success(x) : Failure("Niepoprawna suma kontrolna - #{x}. Powinna być 0.") }
  # TODO - combaing failures
  if acc_matches.failure? || branch_matches.failure?
    Failure(acc_matches.either(-> y { branch_matches }, -> y { branch_matches.either(-> z { Failure(y) }, -> z { Failure([y, z]) }) }))
  end
  Success(iban)
end

# function _iso7064_mod97_10_generated($input) {
#   $input = strtoupper($input); # normalize
#   if(!preg_match('/^[0123456789]+$/',$input)) { return ''; } # bad input
#   $modulus       = 97;
#   $radix         = 10;
#   $output_values = '0123456789';
#   $p             = 0;
#   for($i=0; $i<strlen($input); $i++) {
#     $val = strpos($output_values,substr($input,$i,1));
#   if($val < 0) { return ''; } # illegal character encountered
#   $p = (($p + $val) * $radix) % $modulus;
#   }
#   $p = ($p*$radix) % $modulus;
#   $checksum = ($modulus - $p + 1) % $modulus;
#   $second = $checksum % $radix;
#   $first = ($checksum - $second) / $radix;
#   return substr($output_values,$first,1) . substr($output_values,$second,1);
#   }
# _iban_nationalchecksum_implementation_mod97_10
# montenegro, macedionia, serbia, solvenia

def east_timor_validate(iban)
  calculated_checksum = get_bank_code(iban)
                          .bind { |x| get_account_number(iban).either(-> y { Success(x + y) }, -> y { Failure(y) }) }
                          .fmap { |x| iso7064_mod97_10(x) }
  calculated_checksum.bind { |x| get_local_checksum(iban).either(-> y { x == y.to_i ? Success(iban) : Failure("Niepoprawna suma kontrolna - #{y}. Powinna być #{x}: #{iban}") }, -> y { Failure(y) }) }
end

def estonia_validate(iban)
  calculated_checksum = get_branch_code(iban)
                          .bind { |x| get_account_number(iban).either(-> y { Success(x + y) }, -> y { Failure(y) }) }
                          .fmap { |x| weighted(x, [7, 3, 1], 10, -> y { y == 0 ? 0 : 10 - y }, prezip: -> y { y.reverse }) }
  # .fmap { |x| x.split('') }
  # .fmap { |x| x.map { |chr| chr.to_i } }
  # .fmap { |x| x.reverse }
  # .fmap { |x| x.zip([7, 3, 1].cycle) }
  # .fmap { |x| x.map { |num, weight| num * weight } }
  # .fmap { |x| x.sum }
  # .fmap { |x| x % 10 }
  # .fmap { |x| x == 0 ? 0 : 10 - x }
  calculated_checksum.bind { |x| get_local_checksum(iban).either(-> y { x == y.to_i ? Success(iban) : Failure("Niepoprawna suma kontrolna - #{y}. Powinna być #{x}: #{iban}") }, -> y { Failure(y) }) }
end

def finland_validate(iban)
  calculated_checksum = get_bank_code(iban)
                          .bind { |x| get_account_number(iban).either(-> y { Success(x + y) }, -> y { Failure(y) }) }
                          .fmap { |x| weighted(x, [2, 1], 10, -> y { y == 0 ? 0 : 10 - y }, presum: -> y { y.map { |num| num % 10 + num / 10 } }) }
  calculated_checksum.bind { |x| get_local_checksum(iban).either(-> y { x == y.to_i ? Success(iban) : Failure("Niepoprawna suma kontrolna - #{y}. Powinna być #{x}: #{iban}") }, -> y { Failure(y) }) }
end

# function _iban_nationalchecksum_implementation_fr($iban,$mode) {
#   if($mode != 'set' && $mode != 'find' && $mode != 'verify') { return ''; } # blank value on return to distinguish from correct execution
#   # first, extract the BBAN
#   $bban = iban_get_bban_part($iban);
#   # convert to numeric form
#   $bban_numeric_form = _iban_nationalchecksum_implementation_fr_letters2numbers_helper($bban);
#   # if the result was null, something is horribly wrong
#   if(is_null($bban_numeric_form)) { return ''; }
#   # extract other parts
#   $bank = substr($bban_numeric_form,0,5);
#   $branch = substr($bban_numeric_form,5,5);
#   $account = substr($bban_numeric_form,10,11);
#   # actual implementation: mod97( (89 x bank number "Code banque") + (15 x branch code "Code guichet") + (3 x account number "Numéro de compte") )
#   $sum = (89*($bank+0)) + ((15*($branch+0)));
#   $sum += (3*($account+0));
#   $expected_nationalchecksum = 97 - ($sum % 97);
#   if(strlen($expected_nationalchecksum) == 1) { $expected_nationalchecksum = '0' . $expected_nationalchecksum; }
#   # return
#   if($mode=='find') {
#     return $expected_nationalchecksum;
#   }
#   elseif($mode=='set') {
#     return _iban_nationalchecksum_set($iban,$expected_nationalchecksum);
#   }
#   elseif($mode=='verify') {
#     return (iban_get_nationalchecksum_part($iban) == $expected_nationalchecksum);
#   }
#   }

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
                          # to pokurwione mapowanie liter na cyfry ale nie wiem, po co
                          .fmap { |x| x.map { |e| e.split('') } }
                          .fmap { |x| x.map { |e| e.map { |l| french_letter_to_digit(l).to_s } } }
                          .fmap { |x| x.map { |e| e.join } }
                          .fmap { |x| x.map &:to_i }
                          .fmap { |x| x.zip([89, 15, 3]) } # no idea where these come from
                          .fmap { |x| x.map { |num, weight| num * weight } }
                          .fmap { |x| x.sum }
                          .fmap { |x| iso7064_mod97_10(x, minuend: 97, premod: -> x { x }) }

  calculated_checksum.bind { |x| get_local_checksum(iban).either(-> y { x == y.to_i ? Success(iban) : Failure("Niepoprawna suma kontrolna - #{y}. Powinna być #{x}: #{iban}") }, -> y { Failure(y) }) }
end

def hungary_validate(iban)
  calculated_checksum_bank_code = get_bank_code(iban)
                                    .fmap { |x| weighted(x, [9, 7, 3, 1], 10, -> y { y == 0 ? 0 : 10 - y }) }
  calculated_checksum_branch_number = get_branch_code(iban)
                                        .fmap { |x| weighted(x, [9, 7, 3, 1], 10, -> y { y == 0 ? 0 : 10 - y }) }
  national_checksum = get_account_number(iban) # this is not technically correct since they are not consecutive
  if national_checksum.failure?
    return national_checksum
  end
  bank_code_checksum = national_checksum.value![0]
  branch_number_checksum = national_checksum.value![-1]
  bank_code_matches = calculated_checksum_bank_code.bind { |x| x == bank_code_checksum ? Success(x) : Failure("Niepoprawna suma kontrolna - #{x}. Powinna być 0.") }
  branch_matches = calculated_checksum_branch_number.bind { |x| x == branch_number_checksum ? Success(x) : Failure("Niepoprawna suma kontrolna - #{x}. Powinna być 0.") }
  # TODO - combaing failures
  if bank_code_matches.failure? || branch_matches.failure?
    Failure(bank_code_matches.either(-> y { branch_matches }, -> y { branch_matches.either(-> z { Failure(y) }, -> z { Failure([y, z]) }) }))
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
                          .fmap { |x| x.sum }
                          .fmap { |x| x % 26 }
                          .fmap { |x| ('A'.ord + x).chr }
  calculated_checksum.bind { |x| get_local_checksum(iban).either(-> y { x == y ? Success(iban) : Failure("Niepoprawna suma kontrolna - #{y}. Powinna być #{x}: #{iban}") }, -> y { Failure(y) }) }
end

def north_macedonia_validate(iban)
  calculated_checksum = get_bank_code(iban)
                          .bind { |x| get_account_number(iban).either(-> y { Success(x + y) }, -> y { Failure(y) }) }
                          .fmap { |x| iso7064_mod97_10(x) }

  calculated_checksum.bind { |x| get_local_checksum(iban).either(-> y { x == y.to_i ? Success(iban) : Failure("Niepoprawna suma kontrolna - #{y}. Powinna być #{x}: #{iban}") }, -> y { Failure(y) }) }
end

def mauritania_validate(iban)
  calculated_checksum = get_bank_code(iban)
                          .bind { |x| get_branch_code(iban).either(-> y { Success(x + y) }, -> y { Failure(y) }) }
                          .bind { |x| get_account_number(iban).either(-> y { Success(x + y) }, -> y { Failure(y) }) }
                          .fmap { |x| iso7064_mod97_10(x, minuend: 97) }
  calculated_checksum.bind { |x| get_local_checksum(iban).either(-> y { x == y.to_i ? Success(iban) : Failure("Niepoprawna suma kontrolna - #{y}. Powinna być #{x}: #{iban}") }, -> y { Failure(y) }) }
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

done = ['al', 'be', 'ba', 'hr', 'cz', 'tl', 'ee', 'fi', 'fr', 'hu', 'is', 'it', 'mk', 'mr']
done.each do |country_code|
  file = File.open("./example-ibans/#{country_code}-ibans")

  lines = file.readlines
  lines.each do |line|
    validate_iban(line).either(-> x { nil }, -> x { puts "Failure: #{x}" })
  end
end

# binding.pry