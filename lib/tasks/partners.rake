# encoding: UTF-8

require 'carmen'
require 'colorize'
require 'psych'
require 'csv'

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

    i = 0
    user = User.first
    puts "Importing partners data from CSV file: #{args[:input]}"

    CSV.foreach(args[:input], col_sep: ';', headers: true) do |row|
      next if row.empty?
      data = row.to_hash
      $stdout.write "Importing: #{i += 1}\r"
      p = Partner.new
      p.user = user

      {
        company: 'Firma',
        zip:     'PLZ',
        street:  'Straße',
        city:    'Ort',
        phone:   'TelefonD',
        fax:     'Fax',
        email:   'EmailD',
        website: 'Homepage'
      }.each { |attr, key| p[attr] = data[key].try(:strip) }

      p.country = country_from_s.call(data['Land']) unless data['Land'].blank?

      p.comment.comment = data['Bemerkungen'].strip unless data['Bemerkungen'].blank?

      p.businesses = data['Kategorie'] if data['Kategorie'].present?

      unless (advisers = data['Ansprechpartner']).blank?
        evil = ['dr.', 'd.k.', 'dk', 'bs', 'dr', 'f', 'd', 'm']

        p.advisers = advisers.underscore.split(/[,_\s\/\+]+/).reject do |adviser|
          evil.include?(adviser)
        end.map(&:capitalize).join(',')
      end

      unless (name = data['Name']).blank?
        p.employees << Employee.new.tap do |emp|
          {
            name: 'Name',
            prename: 'Vorname',
            job: 'Tätigkeit',
            title: 'Titel'
          }.each { |attr, key| emp[attr] = data[key].try(:strip) }

          emp.gender = (data['Anrede2'] =~ /Frau/) ? :female : :male

          {
            p_phones: 'TelefonP',
            b_phones: 'TelefonD2',
            m_phones: 'Handy',
            emails: 'EmailP'
          }.each do |attr, key|
            emp.contact.send(attr) << data[key] unless data[key].blank?
          end
        end
      end

      unless p.save
        $stderr.puts '=> Could not save dataset'.red

        p.errors.each do |attr, msg|
          $stderr.puts "===> #{Partner.human_attribute_name(attr)}: #{msg}".yellow
        end
      end
    end
  end
end
