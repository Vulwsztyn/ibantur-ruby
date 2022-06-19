class CountryConfig
  class << self
    def config
      {
        AL: {
          name: 'Albania',
          code: 'AL',
          bban_format: '8n,16c',
          iban_length: 28,
          bank_code: [4, 7],
          branch_code: [7, 11],
          national_checksum: [11, 12],
          account_number: [12, 28],
          },
        AD: {
          name: 'Andorra',
          code: 'AD',
          bban_format: '8n,12c',
          iban_length: 24,
          bank_code: [4, 8],
          branch_code: [8, 12],
          national_checksum: [nil, nil],
          account_number: [12, 24],
          },
        AT: {
          name: 'Austria',
          code: 'AT',
          bban_format: '16n',
          iban_length: 20,
          bank_code: [4, 9],
          branch_code: [nil, nil],
          national_checksum: [nil, nil],
          account_number: [9, 20],
          },
        AZ: {
          name: 'Azerbaijan',
          code: 'AZ',
          bban_format: '4c,20n',
          iban_length: 28,
          bank_code: [4, 8],
          branch_code: [nil, nil],
          national_checksum: [nil, nil],
          account_number: [8, 28],
          },
        BH: {
          name: 'Bahrain',
          code: 'BH',
          bban_format: '4a,14c',
          iban_length: 22,
          bank_code: [4, 8],
          branch_code: [nil, nil],
          national_checksum: [nil, nil],
          account_number: [8, 22],
          },
        BY: {
          name: 'Belarus',
          code: 'BY',
          bban_format: '4c,4n,16c',
          iban_length: 28,
          bank_code: [4, 8],
          branch_code: [nil, nil],
          national_checksum: [nil, nil],
          account_number: [12, 28],
          },
        BE: {
          name: 'Belgium',
          code: 'BE',
          bban_format: '12n',
          iban_length: 16,
          bank_code: [4, 7],
          branch_code: [nil, nil],
          national_checksum: [14, 16],
          account_number: [7, 14],
          },
        BA: {
          name: 'Bosnia and Herzegovina',
          code: 'BA',
          bban_format: '16n',
          iban_length: 20,
          bank_code: [4, 7],
          branch_code: [7, 10],
          national_checksum: [18, 20],
          account_number: [10, 18],
          },
        BR: {
          name: 'Brazil',
          code: 'BR',
          bban_format: '23n,1a,1c',
          iban_length: 29,
          bank_code: [4, 12],
          branch_code: [12, 17],
          national_checksum: [nil, nil],
          account_number: [17, 27],
          },
        BG: {
          name: 'Bulgaria',
          code: 'BG',
          bban_format: '4a,6n,8c',
          iban_length: 22,
          bank_code: [4, 8],
          branch_code: [8, 12],
          national_checksum: [nil, nil],
          account_number: [14, 22],
          },
        CR: {
          name: 'Costa Rica',
          code: 'CR',
          bban_format: '18n',
          iban_length: 22,
          bank_code: [5, 8],
          branch_code: [nil, nil],
          national_checksum: [nil, nil],
          account_number: [8, 22],
          },
        HR: {
          name: 'Croatia',
          code: 'HR',
          bban_format: '17n',
          iban_length: 21,
          bank_code: [4, 11],
          branch_code: [nil, nil],
          national_checksum: [nil, nil],
          account_number: [11, 21],
          },
        CY: {
          name: 'Cyprus',
          code: 'CY',
          bban_format: '8n,16c',
          iban_length: 28,
          bank_code: [4, 7],
          branch_code: [7, 12],
          national_checksum: [nil, nil],
          account_number: [12, 28],
          },
        CZ: {
          name: 'Czech Republic',
          code: 'CZ',
          bban_format: '20n',
          iban_length: 24,
          bank_code: [4, 8],
          branch_code: [8, 14],
          national_checksum: [nil, nil],
          account_number: [14, 24],
          },
        DK: {
          name: 'Denmark',
          code: 'DK',
          bban_format: '14n',
          iban_length: 18,
          bank_code: [4, 8],
          branch_code: [nil, nil],
          national_checksum: [17, 18],
          account_number: [8, 17],
          },
        DO: {
          name: 'Dominican Republic',
          code: 'DO',
          bban_format: '4a,20n',
          iban_length: 28,
          bank_code: [4, 8],
          branch_code: [nil, nil],
          national_checksum: [nil, nil],
          account_number: [8, 28],
          },
        TL: {
          name: 'East Timor',
          code: 'TL',
          bban_format: '19n',
          iban_length: 23,
          bank_code: [4, 7],
          branch_code: [nil, nil],
          national_checksum: [21, 23],
          account_number: [7, 21],
          },
        EG: {
          name: 'Egypt',
          code: 'EG',
          bban_format: '25n',
          iban_length: 29,
          bank_code: [4, 8],
          branch_code: [8, 12],
          national_checksum: [nil, nil],
          account_number: [12, 29],
          },
        SV: {
          name: 'El Salvador',
          code: 'SV',
          bban_format: '4a,20n',
          iban_length: 28,
          bank_code: [4, 8],
          branch_code: [nil, nil],
          national_checksum: [nil, nil],
          account_number: [8, 28],
          },
        EE: {
          name: 'Estonia',
          code: 'EE',
          bban_format: '16n',
          iban_length: 20,
          bank_code: [4, 6],
          branch_code: [6, 8],
          national_checksum: [19, 20],
          account_number: [8, 19],
          },
        FO: {
          name: 'Faroe Islands',
          code: 'FO',
          bban_format: '14n',
          iban_length: 18,
          bank_code: [4, 8],
          branch_code: [nil, nil],
          national_checksum: [17, 18],
          account_number: [8, 17],
          },
        FI: {
          name: 'Finland',
          code: 'FI',
          bban_format: '14n',
          iban_length: 18,
          bank_code: [4, 10],
          branch_code: [nil, nil],
          national_checksum: [17, 18],
          account_number: [10, 17],
          },
        FR: {
          name: 'France',
          code: 'FR',
          bban_format: '10n,11c,2n',
          iban_length: 27,
          bank_code: [4, 9],
          branch_code: [9, 14],
          national_checksum: [25, 27],
          account_number: [14, 25],
          },
        GE: {
          name: 'Georgia',
          code: 'GE',
          bban_format: '2c,16n',
          iban_length: 22,
          bank_code: [4, 6],
          branch_code: [nil, nil],
          national_checksum: [nil, nil],
          account_number: [6, 22],
          },
        DE: {
          name: 'Germany',
          code: 'DE',
          bban_format: '18n',
          iban_length: 22,
          bank_code: [4, 12],
          branch_code: [nil, nil],
          national_checksum: [nil, nil],
          account_number: [12, 22],
          },
        GI: {
          name: 'Gibraltar',
          code: 'GI',
          bban_format: '4a,15c',
          iban_length: 23,
          bank_code: [4, 8],
          branch_code: [nil, nil],
          national_checksum: [nil, nil],
          account_number: [8, 23],
          },
        GR: {
          name: 'Greece',
          code: 'GR',
          bban_format: '7n,16c',
          iban_length: 27,
          bank_code: [4, 7],
          branch_code: [7, 11],
          national_checksum: [nil, nil],
          account_number: [11, 27],
          },
        GL: {
          name: 'Greenland',
          code: 'GL',
          bban_format: '14n',
          iban_length: 18,
          bank_code: [4, 8],
          branch_code: [nil, nil],
          national_checksum: [17, 18],
          account_number: [8, 17],
          },
        GT: {
          name: 'Guatemala',
          code: 'GT',
          bban_format: '4c,20c',
          iban_length: 28,
          bank_code: [4, 8],
          branch_code: [nil, nil],
          national_checksum: [nil, nil],
          account_number: [12, 28],
          },
        HU: {
          name: 'Hungary',
          code: 'HU',
          bban_format: '24n',
          iban_length: 28,
          bank_code: [4, 7],
          branch_code: [7, 11],
          national_checksum: [11, 28],
          account_number: [12, 27],
          },
        IS: {
          name: 'Iceland',
          code: 'IS',
          bban_format: '22n',
          iban_length: 26,
          bank_code: [4, 6],
          branch_code: [6, 8],
          national_checksum: [nil, nil],
          account_number: [10, 16],
          },
        IQ: {
          name: 'Iraq',
          code: 'IQ',
          bban_format: '4a,15n',
          iban_length: 23,
          bank_code: [4, 8],
          branch_code: [8, 11],
          national_checksum: [nil, nil],
          account_number: [11, 23],
          },
        IE: {
          name: 'Ireland',
          code: 'IE',
          bban_format: '4c,14n',
          iban_length: 22,
          bank_code: [8, 14],
          branch_code: [nil, nil],
          national_checksum: [nil, nil],
          account_number: [14, 22],
          },
        IL: {
          name: 'Israel',
          code: 'IL',
          bban_format: '19n',
          iban_length: 23,
          bank_code: [4, 7],
          branch_code: [7, 10],
          national_checksum: [nil, nil],
          account_number: [10, 23],
          },
        IT: {
          name: 'Italy',
          code: 'IT',
          bban_format: '1a,10n,12c',
          iban_length: 27,
          bank_code: [5, 10],
          branch_code: [10, 15],
          national_checksum: [4, 5],
          account_number: [15, 27],
          },
        JO: {
          name: 'Jordan',
          code: 'JO',
          bban_format: '4a,22n',
          iban_length: 30,
          bank_code: [4, 8],
          branch_code: [8, 12],
          national_checksum: [nil, nil],
          account_number: [12, 30],
          },
        KZ: {
          name: 'Kazakhstan',
          code: 'KZ',
          bban_format: '3n,13c',
          iban_length: 20,
          bank_code: [4, 7],
          branch_code: [nil, nil],
          national_checksum: [nil, nil],
          account_number: [7, 20],
          },
        XK: {
          name: 'Kosovo',
          code: 'XK',
          bban_format: '4n,10n,2n',
          iban_length: 20,
          bank_code: [4, 8],
          branch_code: [nil, nil],
          national_checksum: [nil, nil],
          account_number: [8, 20],
          },
        KW: {
          name: 'Kuwait',
          code: 'KW',
          bban_format: '4a,22c',
          iban_length: 30,
          bank_code: [4, 8],
          branch_code: [nil, nil],
          national_checksum: [nil, nil],
          account_number: [8, 30],
          },
        LV: {
          name: 'Latvia',
          code: 'LV',
          bban_format: '4a,13c',
          iban_length: 21,
          bank_code: [4, 8],
          branch_code: [nil, nil],
          national_checksum: [nil, nil],
          account_number: [8, 21],
          },
        LB: {
          name: 'Lebanon',
          code: 'LB',
          bban_format: '4n,20c',
          iban_length: 28,
          bank_code: [4, 8],
          branch_code: [nil, nil],
          national_checksum: [nil, nil],
          account_number: [8, 28],
          },
        LY: {
          name: 'Libya',
          code: 'LY',
          bban_format: '21n',
          iban_length: 25,
          bank_code: [4, 7],
          branch_code: [7, 10],
          national_checksum: [nil, nil],
          account_number: [10, 25],
          },
        LI: {
          name: 'Liechtenstein',
          code: 'LI',
          bban_format: '5n,12c',
          iban_length: 21,
          bank_code: [4, 9],
          branch_code: [nil, nil],
          national_checksum: [nil, nil],
          account_number: [9, 21],
          },
        LT: {
          name: 'Lithuania',
          code: 'LT',
          bban_format: '16n',
          iban_length: 20,
          bank_code: [4, 9],
          branch_code: [nil, nil],
          national_checksum: [nil, nil],
          account_number: [9, 20],
          },
        LU: {
          name: 'Luxembourg',
          code: 'LU',
          bban_format: '3n,13c',
          iban_length: 20,
          bank_code: [4, 7],
          branch_code: [nil, nil],
          national_checksum: [nil, nil],
          account_number: [7, 20],
          },
        MT: {
          name: 'Malta',
          code: 'MT',
          bban_format: '4a,5n,18c',
          iban_length: 31,
          bank_code: [4, 8],
          branch_code: [8, 13],
          national_checksum: [nil, nil],
          account_number: [13, 31],
          },
        MR: {
          name: 'Mauritania',
          code: 'MR',
          bban_format: '23n',
          iban_length: 27,
          bank_code: [4, 9],
          branch_code: [9, 14],
          national_checksum: [25, 27],
          account_number: [14, 25],
          },
        MU: {
          name: 'Mauritius',
          code: 'MU',
          bban_format: '4a,19n,3a',
          iban_length: 30,
          bank_code: [4, 10],
          branch_code: [10, 12],
          national_checksum: [nil, nil],
          account_number: [12, 24],
          },
        MD: {
          name: 'Moldova',
          code: 'MD',
          bban_format: '2c,18c',
          iban_length: 24,
          bank_code: [4, 6],
          branch_code: [nil, nil],
          national_checksum: [nil, nil],
          account_number: [6, 24],
          },
        MC: {
          name: 'Monaco',
          code: 'MC',
          bban_format: '10n,11c,2n',
          iban_length: 27,
          bank_code: [4, 9],
          branch_code: [9, 14],
          national_checksum: [25, 27],
          account_number: [14, 25],
          },
        ME: {
          name: 'Montenegro',
          code: 'ME',
          bban_format: '18n',
          iban_length: 22,
          bank_code: [4, 7],
          branch_code: [nil, nil],
          national_checksum: [20, 22],
          account_number: [7, 20],
          },
        NL: {
          name: 'Netherlands',
          code: 'NL',
          bban_format: '4a,10n',
          iban_length: 18,
          bank_code: [4, 8],
          branch_code: [nil, nil],
          national_checksum: [nil, nil],
          account_number: [8, 18],
          },
        MK: {
          name: 'North Macedonia',
          code: 'MK',
          bban_format: '3n,10c,2n',
          iban_length: 19,
          bank_code: [4, 7],
          branch_code: [nil, nil],
          national_checksum: [17, 19],
          account_number: [7, 17],
          },
        NO: {
          name: 'Norway',
          code: 'NO',
          bban_format: '11n',
          iban_length: 15,
          bank_code: [4, 8],
          branch_code: [nil, nil],
          national_checksum: [14, 15],
          account_number: [8, 14],
          },
        PK: {
          name: 'Pakistan',
          code: 'PK',
          bban_format: '4c,16n',
          iban_length: 24,
          bank_code: [4, 8],
          branch_code: [nil, nil],
          national_checksum: [nil, nil],
          account_number: [8, 24],
          },
        PS: {
          name: 'Palestinian territories',
          code: 'PS',
          bban_format: '4c,21n',
          iban_length: 29,
          bank_code: [4, 8],
          branch_code: [nil, nil],
          national_checksum: [nil, nil],
          account_number: [8, 29],
          },
        PL: {
          name: 'Poland',
          code: 'PL',
          bban_format: '24n',
          iban_length: 28,
          bank_code: [4, 7],
          branch_code: [7, 11],
          national_checksum: [11, 12],
          account_number: [12, 28],
          },
        PT: {
          name: 'Portugal',
          code: 'PT',
          bban_format: '21n',
          iban_length: 25,
          bank_code: [4, 8],
          branch_code: [8, 12],
          national_checksum: [23, 25],
          account_number: [12, 23],
          },
        QA: {
          name: 'Qatar',
          code: 'QA',
          bban_format: '4a,21c',
          iban_length: 29,
          bank_code: [4, 8],
          branch_code: [nil, nil],
          national_checksum: [nil, nil],
          account_number: [8, 29],
          },
        RO: {
          name: 'Romania',
          code: 'RO',
          bban_format: '4a,16c',
          iban_length: 24,
          bank_code: [4, 8],
          branch_code: [nil, nil],
          national_checksum: [nil, nil],
          account_number: [8, 24],
          },
        LC: {
          name: 'Saint Lucia',
          code: 'LC',
          bban_format: '4a,24c',
          iban_length: 32,
          bank_code: [4, 8],
          branch_code: [nil, nil],
          national_checksum: [nil, nil],
          account_number: [8, 32],
          },
        SM: {
          name: 'San Marino',
          code: 'SM',
          bban_format: '1a,10n,12c',
          iban_length: 27,
          bank_code: [5, 10],
          branch_code: [10, 15],
          national_checksum: [4, 5],
          account_number: [15, 27],
          },
        ST: {
          name: 'São Tomé and Príncipe',
          code: 'ST',
          bban_format: '21n',
          iban_length: 25,
          bank_code: [4, 8],
          branch_code: [8, 12],
          national_checksum: [nil, nil],
          account_number: [12, 25],
          },
        SA: {
          name: 'Saudi Arabia',
          code: 'SA',
          bban_format: '2n,18c',
          iban_length: 24,
          bank_code: [4, 6],
          branch_code: [nil, nil],
          national_checksum: [nil, nil],
          account_number: [6, 24],
          },
        RS: {
          name: 'Serbia',
          code: 'RS',
          bban_format: '18n',
          iban_length: 22,
          bank_code: [4, 7],
          branch_code: [nil, nil],
          national_checksum: [20, 22],
          account_number: [7, 20],
          },
        SC: {
          name: 'Seychelles',
          code: 'SC',
          bban_format: '4a,20n,3a',
          iban_length: 31,
          bank_code: [4, 10],
          branch_code: [10, 12],
          national_checksum: [nil, nil],
          account_number: [nil, nil],
          },
        SK: {
          name: 'Slovakia',
          code: 'SK',
          bban_format: '20n',
          iban_length: 24,
          bank_code: [4, 8],
          branch_code: [8, 14],
          national_checksum: [nil, nil],
          account_number: [14, 24],
          },
        SI: {
          name: 'Slovenia',
          code: 'SI',
          bban_format: '15n',
          iban_length: 19,
          bank_code: [4, 6],
          branch_code: [6, 9],
          national_checksum: [17, 19],
          account_number: [9, 17],
          },
        ES: {
          name: 'Spain',
          code: 'ES',
          bban_format: '20n',
          iban_length: 24,
          bank_code: [4, 8],
          branch_code: [8, 12],
          national_checksum: [12, 14],
          account_number: [14, 24],
          },
        SD: {
          name: 'Sudan',
          code: 'SD',
          bban_format: '14n',
          iban_length: 18,
          bank_code: [4, 6],
          branch_code: [nil, nil],
          national_checksum: [nil, nil],
          account_number: [6, 18],
          },
        SE: {
          name: 'Sweden',
          code: 'SE',
          bban_format: '20n',
          iban_length: 24,
          bank_code: [4, 7],
          branch_code: [nil, nil],
          national_checksum: [nil, nil],
          account_number: [7, 24],
          },
        CH: {
          name: 'Switzerland',
          code: 'CH',
          bban_format: '5n,12c',
          iban_length: 21,
          bank_code: [4, 9],
          branch_code: [nil, nil],
          national_checksum: [nil, nil],
          account_number: [9, 21],
          },
        TN: {
          name: 'Tunisia',
          code: 'TN',
          bban_format: '20n',
          iban_length: 24,
          bank_code: [4, 6],
          branch_code: [6, 9],
          national_checksum: [22, 24],
          account_number: [9, 22],
          },
        TR: {
          name: 'Turkey',
          code: 'TR',
          bban_format: '5n,17c',
          iban_length: 26,
          bank_code: [4, 9],
          branch_code: [nil, nil],
          national_checksum: [nil, nil],
          account_number: [10, 26],
          },
        UA: {
          name: 'Ukraine',
          code: 'UA',
          bban_format: '6n,19c',
          iban_length: 29,
          bank_code: [4, 10],
          branch_code: [nil, nil],
          national_checksum: [nil, nil],
          account_number: [10, 29],
          },
        AE: {
          name: 'United Arab Emirates',
          code: 'AE',
          bban_format: '3n,16n',
          iban_length: 23,
          bank_code: [4, 7],
          branch_code: [nil, nil],
          national_checksum: [nil, nil],
          account_number: [7, 23],
          },
        GB: {
          name: 'United Kingdom',
          code: 'GB',
          bban_format: '4a,14n',
          iban_length: 22,
          bank_code: [4, 8],
          branch_code: [8, 14],
          national_checksum: [nil, nil],
          account_number: [14, 22],
          },
        VA: {
          name: 'Vatican City',
          code: 'VA',
          bban_format: '3n,15n',
          iban_length: 22,
          bank_code: [4, 7],
          branch_code: [nil, nil],
          national_checksum: [nil, nil],
          account_number: [7, 22],
          },
        VG: {
          name: 'Virgin Islands, British',
          code: 'VG',
          bban_format: '4c,16n',
          iban_length: 24,
          bank_code: [4, 8],
          branch_code: [nil, nil],
          national_checksum: [nil, nil],
          account_number: [8, 24],
          },
      }
    end
  end
end