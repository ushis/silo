namespace :experts do

  task :import, [:filename] => [:environment] do |task, args|
    puts "Importing experts data from XML file: #{args[:filename]}"

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
          e.gender = Expert.genders[:male]
        else
          e.gender = Expert.genders[:female]
        end

        e.birthname = data['Geburtsname']
        e.birthday = data['Geburtsdatum'].try(:to_datetime) || nil
        e.birthplace = data['Geburtsort']
        e.citizenship = data['Staatsb']
        e.degree = data['Titel']

        if data['Familienstand'].try(:downcase) == 'v'
          e.marital_status = Expert.marital_status[:married]
        else
          e.marital_status = Expert.marital_status[:single]
        end

        # Contact data
        e.contact = Contact.new

        ['Handy', 'TelefonP', 'TelefonD'].each do |phone|
          if (number = data[phone])
            e.contact.phones << number
          end
        end

        if (email = data['E-Mail'])
          email = email.strip.split(/\s+|#/)
          e.contact.emails << email[0] if email.length > 0
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

  task :deleteall => :environment do
    Expert.all.each { |e| e.destroy }
  end
end
