# encoding: UTF-8

require 'carmen'
require 'colorize'
require 'psych'

namespace :partners do

  task :import, [:input] => [:environment] do |task, args|
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

    puts "Importing partners data from XML file: #{args[:input]}"

    File.open(args[:input]) do |f|
      user = User.first
      partners = Hash.from_xml(f.read)['dataroot']['AdressenPartner']
      len, err = [partners.length, 0]

      partners.each_with_index do |data, i|
        $stdout.write "Importing: #{i}/#{len}\r"
        p = Partner.new
        p.user = user

        p.company = ['Firma1', 'Firma2'].map do |key|
          data[key]
        end.join(' ').strip.squeeze(" ")

        {zip: 'FirmaPLZ', street: 'FirmaStra', city: 'FirmaOrt'}.each do |attr, key|
          p[attr] = data[key].try(:strip)
        end

        p.country = country_from_s.call(data['Land']) unless data['Land'].blank?

        p.comment.comment = data['Notizen'].strip unless data['Notizen'].blank?

        [[:website, 'Homepage'], [:phone, 'TelefonD']].each do |attr, key|
          p[attr] = data[key].try(:strip)
        end

        unless (email = data['E_Mail']).blank?
          email.split('#').pop.gsub('mailto:', '').gsub('http://', '').strip.tap do |email|
            p.email = email.downcase if email.index('@')
          end
        end

        unless (name = data['LTRName']).blank?
          p.employees << Employee.new(name: name.strip).tap do |emp|
            emp.job = data['LTRBez'].try(:strip)
            emp.gender = (data['LTRGeschl'].try(:downcase) == 'w') ? :female : :male
          end
        end

        unless (name = data['AnsprPartner']).blank?
          p.employees << Employee.new(name: name.strip).tap do |emp|
            emp.contact.m_phones << data['Handy'].strip unless data['Handy'].blank?
            emp.contact.p_phones << data['TelefonP'].strip unless data['TelefonP'].blank?
          end
        end

        unless (advisers = data['IAKPartner']).blank?
          evil = ['dr.', 'd.k.', 'f', 'd', 'm', 'geschäftsführg.']

          p.advisers = advisers.underscore.split(/[,_\s\/\+]+/).reject do |adviser|
            evil.include?(adviser)
          end.map(&:capitalize).join(',')
        end

        unless p.save
          $stderr.puts '=> Could not save dataset'.red
          err += 1

          p.errors.each do |attr, msg|
            $stderr.puts "===> #{Partner.human_attribute_name(attr)}: #{msg}".yellow
          end
        end
      end
    end
  end
end
