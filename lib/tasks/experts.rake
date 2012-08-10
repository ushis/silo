#encoding: utf-8

require 'carmen'

namespace :experts do

  task :import, [:filename] => [:environment] do |task, args|
    puts "Importing experts data from XML file: #{args[:filename]}"

    countries = {
      'Aouth Africa'                     => 'ZA',
      'Austrialia'                       => 'AU',
      'Australia 3149'                   => 'AU',
      'Australia 4350'                   => 'AU',
      'Bosnia And Herzegovina'           => 'BA',
      'Bolivia'                          => 'BO',
      'Canada B0 J 2 C0'                 => 'CA',
      'Canada J4 Z 1 G5'                 => 'CA',
      'Colombia 8'                       => 'CO',
      'Costa Rica C.A.'                  => 'CR',
      'CÔte D’Ivoire'                    => 'CI',
      'French'                           => 'FR',
      'Guatemala 01010'                  => 'GT',
      'Guinea Bissau'                    => 'GW',
      'India 400 058'                    => 'IN',
      'Iran'                             => 'IR',
      'Kazakhstan, 480002'               => 'KZ',
      'Kazakhstan 480090'                => 'KZ',
      'Kosovar Albanian'                 => 'AL',
      'Kosovo Albania'                   => 'AL',
      'Kosovo'                           => 'AL',
      'Kosova'                           => 'AL',
      'Lao Pdr'                          => 'LA',
      'Laos'                             => 'LA',
      'Macedonia'                        => 'MK',
      'Mocambique'                       => 'MZ',
      'Moldova'                          => 'MD',
      'North Ireland'                    => 'IE',
      'Palestinian'                      => 'PS',
      'Papua Neuguinea'                  => 'PG',
      'Russia'                           => 'RU',
      'Saint Lucian'                     => 'LC',
      'Saint Vincent And The Grenadines' => 'VC',
      'Scotland'                         => 'GB',
      'Sebien'                           => 'RS',
      'Serbien'                          => 'RS',
      'Simbabwe'                         => 'ZW',
      'Spain, Canary Isles'              => 'ES',
      'St. Kitts & Nevis'                => 'KN',
      'Syria'                            => 'SY',
      'Tanzania'                         => 'TZ',
      'The Gambia'                       => 'GM',
      'Trinidad And Tobago'              => 'TT',
      'Trinidad & Tobago'                => 'TT',
      'Tunisie'                          => 'TN',
      'U.P. India'                       => 'IN',
      'Usa 07450'                        => 'US',
      'Venezuela'                        => 'VE',
      'Vietnam'                          => 'VN'
    }.inject({}) { |c, t| c[t[0]] = Carmen::Country.coded(t[1]); c }

    country_from_s = lambda do |s|
      c = s.split('/')[0].gsub(/!|\?/, '').strip.titleize

      unless (co = countries[c]) || (co = Carmen::Country.named(c))
        puts "Country Code for: \"#{c}\""

        begin
          code = STDIN.gets.chomp
        end while ! (co = Carmen::Country.coded(code))

        countries[c] = co
      end

      co
    end

    degrees = { master: ['m'], phd: ['dr', 'prof', 'mag', 'dvm'] }

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
        e.job = data['FirmaT']

        if (d = data['Titel'])
          d = d.strip.downcase.split(/\.| /).first
          e.degree = degrees.find { |s, l| l.include?(d) }.try(:first)
        end

        e.company = ['Firma1', 'Firma2'].collect do |f|
          data[f] || ''
        end.join(' ')

        # Citizenship
        if (c = data['Staatsb'])
          e.citizenship = country_from_s.call(c).code
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
        address_keys = ['Stra', 'Wohnort', 'Land']

        if address_keys.any? { |v| ! data[v].blank? }
          address = Address.new
          address.street = data['Stra'].to_s
          address.city = data['Wohnort'].to_s

          if (c = data['Land'])
            address.country = country_from_s.call(c).code
          end

          e.addresses << address
        end

        # Yay!
        unless e.save
          puts "Could not save dataset of #{data['Vorname1']} #{data['Name']}."
          err += 1
        end
      end

      puts "Imported #{len - err} experts."
    end
  end
end
