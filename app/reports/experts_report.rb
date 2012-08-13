
class ExpertsReport < ApplicationReport

  def self.for_expert(expert)
    report = ExpertsReport.new(expert.full_name_with_degree)
    report.add_expert(expert)
    report
  end

  def add_expert(e)
    data = [
      [t('label.name'), e.name],
      [t('label.prename'), e.prename],
      [t('label.gender'), t(e.gender, scope: :gender)],
      [''],
      [t('label.birthday'), l(e.birthday, format: :short)],
      [t('label.birthplace'), e.birthplace],
      [t('label.citizenship'), e.human_citizenship],
      [''],
      [t('label.job'), e.job],
      [t('label.company'), e.company],
      [''],
      [t('label.degree'), e.degree && t(e.degree, scope: :degree)],
      [t('label.languages'), e.languages.collect { |l| l.human }.join(', ')],
      [''],
      [t('label.former_collaboration'), t(e.former_collaboration.to_s, scope: :label)],
      [t('label.fee'), e.fee],
      ['']
    ]

    Contact::FIELDS.collect do |f|
      unless (values = e.contact.send(f)).empty?
        data << [t(f, scope: :label), values.join(', ')]
      end
    end

    e.addresses.each_with_index do |address, i|
      data << ['']
      data << ["#{i + 1}. #{t('label.address')}"]
      data << [t('label.street'), address.street]
      data << [t('label.city'), "#{address.zipcode} #{address.city}"]
      data << [t('label.country'), address.human_country]
      data << [t('label.more'), address.more] unless address.more.blank?
    end

    table(data, cell_style: { borders: [], padding: 5 })
    move_down 16
    text e.comment.to_s
  end
end