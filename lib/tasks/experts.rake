require 'carmen'
require 'colorize'
require 'psych'

namespace :experts do

  task :import, [:input, :output] => [:environment] do |task, args|
    countries = nil

    File.open(File.expand_path('../countries.yml', __FILE__)) do |f|
      countries = Psych.load(f.read).fetch('countries')
    end

    countries.each { |c, code| countries[c] = Carmen::Country.coded(code) }

    country_from_s = lambda do |s|
      c = s.split('/')[0].gsub(/!|\?/, '').strip.titleize

      unless (co = countries[c]) || (co = Carmen::Country.named(c))
        puts "Country Code for: \"#{c}\""

        begin
          code = STDIN.gets.chomp
        end while ! (co = Carmen::Country.coded(code))

        countries[c] = co
      end

      Country.find_by_country(co.code)
    end

    puts "Importing experts data from XML file: #{args[:input]}"

    File.open(args[:input]) do |f|
      user = User.first
      output = File.open(args[:output], 'w')
      experts = Hash.from_xml(f.read)['dataroot']['Adressen']
      len, err = [experts.length, 0]

      experts.each_with_index do |data, i|
        $stdout.write("Importing: #{i}/#{len}\r")
        e = Expert.new
        e.user = user

        # Base data
        e.name = data.fetch('Name', '').strip

        prename = "#{data.fetch('Vorname1', '')} #{data.fetch('Vorname2', '')}"
        e.prename = prename.split(/\s+/).join(' ').strip

        if data['m'] == '1'
          e.gender = :male
        else
          e.gender = :female
        end

        e.birthday = data['Geburtsdatum'].try(:to_datetime) || nil
        e.degree = data.fetch('Titel', '').strip

        # Job
        job = data['FirmaT'].try(:strip)

        company = ['Firma1', 'Firma2'].collect do |f|
          data[f].try(:strip) || ''
        end.join(' ').strip

        if job.blank?
          e.job = company
        elsif company.blank?
          e.job = job
        else
          e.job = [job, company].join(' - ')
        end

        # Citizenship
        if (c = data['Staatsb'])
          e.country = country_from_s.call(c)
        end

        # Contact data
        e.contact.m_phones << data['Handy'] if data['Handy']
        e.contact.p_phones << data['TelefonP'] if data['TelefonP']
        e.contact.b_phones << data['TelefonD'] if data['TelefonD']

        if (email = data['E_Mail'])
          unless (parts = email.strip.split(/\s+|#/)).empty?
            e.contact.emails << parts[0]
          end
        end

        # First address
        if ['Stra', 'Wohnort'].any? { |v| ! data[v].blank? }
          address = Address.new

          address.address = [data['Stra'], data['Wohnort']].delete_if do |f|
            f.blank?
          end.join("\n")

          if (c = data['Land'])
            address.country = country_from_s.call(c)
          end

          e.addresses << address
        end

        # Comment
        unless (comment = data['Bemerkung']).blank?
          e.comment = Comment.new(comment: comment)
        end

        # Yay!
        if e.save
          output.puts "#{data['Index']}:#{e.id}"
        else
          $stderr.puts '=> Could not save dataset.'.red
          err += 1

          e.errors.each do |attr, msg|
            $stderr.puts "===> #{Expert.human_attribute_name(attr)}: #{msg}".yellow
          end
        end
      end

      output.close
      puts "Imported #{len - err}/#{len} experts."
      puts "Wrote index shifts to: #{output.path}"
    end
  end
end
