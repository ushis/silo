#encoding: utf-8

require 'carmen'

namespace :experts do

  task :import, [:filename] => [:environment] do |task, args|
    puts "Importing experts data from XML file: #{args[:filename]}"

    countries = {
      'Bosnia And Herzegovina'           => 'BA',
      'Bolivia'                          => 'BO',
      'CÔte D’Ivoire'                    => 'CI',
      'French'                           => 'FR',
      'Guinea Bissau'                    => 'GW',
      'Iran'                             => 'IR',
      'Kosovar Albanian'                 => 'AL',
      'Kosovo Albania'                   => 'AL',
      'Kosovo'                           => 'AL',
      'Macedonia'                        => 'MK',
      'Moldova'                          => 'MD',
      'Palestinian'                      => 'PS',
      'Papua Neuguinea'                  => 'PG',
      'Russia'                           => 'RU',
      'Saint Lucian'                     => 'LC',
      'Saint Vincent And The Grenadines' => 'VC',
      'Sebien'                           => 'RS',
      'Serbien'                          => 'RS',
      'Simbabwe'                         => 'ZW',
      'St. Kitts & Nevis'                => 'KN',
      'Syria'                            => 'SY',
      'Tanzania'                         => 'TZ',
      'The Gambia'                       => 'GM',
      'Trinidad And Tobago'              => 'TT',
      'Trinidad & Tobago'                => 'TT',
      'Venezuela'                        => 'VE',
      'Vietnam'                          => 'VN'
    }.inject({}) { |c, t| c[t[0]] = Carmen::Country.coded(t[1]); c }

    File.open(args[:filename]) do |f|
      user = User.first
      experts = Hash.from_xml(f.read)['dataroot']['Adressen']
      len, err = [experts.length, 0]

      experts.each_with_index do |data, i|
        $stdout.write("Importing: #{i}/#{len}\r")
        e = Expert.new
        e.user = user

        # Base data
        e.name = data.fetch('Name', '')

        prename = "#{data.fetch('Vorname1', '')} #{data.fetch('Vorname2', '')}"
        e.prename = prename.split(/\s+/).join(' ')

        if data['m'] == '1'
          e.gender = :male
        else
          e.gender = :female
        end

        e.birthday = data['Geburtsdatum'].try(:to_datetime) || nil
        e.birthplace = data['Geburtsort']
        e.degree = data['Titel']
        e.job = data['FirmaT']

        e.company = ['Firma1', 'Firma2'].collect do |f|
          data[f] || ''
        end.join(' ')

        if (c = data['Staatsb'])
          c = c.split('/')[0].gsub(/!|\?/, '').strip.titleize

          unless (co = countries[c]) || (co = Carmen::Country.named(c))
            puts "Country Code for: \"#{c}\""

            begin
              code = STDIN.gets.chomp
            end while ! (co = Carmen::Country.coded(code))

            countries[c] = co
          end

          e.citizenship = co.code
        end

        # Contact data
        ['Handy', 'TelefonP', 'TelefonD'].each do |phone|
          if (number = data[phone])
            e.contact.phones << number
          end
        end

        if (email = data['E_Mail'])
          unless (parts = email.strip.split(/\s+|#/)).empty?
            e.contact.emails << parts[0]
          end
        end

        if (fax = data['Fax'])
          e.contact.faxes << data['Fax']
        end

        # First address
        if (st = data['Stra']) || (ci = data['Wohnort']) || (co = data['Land'])
          address = { street: st || '', city: ci || '', country: co }
          e.addresses << Address.new(address)
        end

        unless e.save
          puts "Could not save dataset of #{data['Vorname1']} #{data['Name']}."
          err += 1
        end
      end

      puts "Imported #{len - err} experts."
    end
  end
end
