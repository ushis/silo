# The ExpertsReport provides report rendering of the reports for a single
# Expert and a colltion of mutliple experts.
class ExpertsReport < ApplicationReport

  # Creates a report for a single Expert.
  #
  #   send_data ExpertsReport.for_expert(Expert.find(1)).render,
  #             filename: 'report.pdf'
  def self.for_expert(expert)
    report = ExpertsReport.new(expert.full_name_with_degree)
    report.add_expert(expert)
    report
  end

  # Adds an expert to a report.
  def add_expert(e)
    data = [
      [t('label.name'), e.name],
      [t('label.prename'), e.prename],
      [t('label.gender'), e.human_gender],
      [''],
      [t('label.birthday'), l(e.birthday, format: :short)],
      [t('label.citizenship'), e.human_citizenship],
      [''],
      [t('label.job'), e.job],
      [''],
      [t('label.degree'), e.degree],
      [t('label.languages'), e.languages.collect { |l| l.human }.join(', ')],
      [''],
      [t('label.former_collaboration'), e.human_former_collaboration],
      [t('label.fee'), e.fee],
      ['']
    ]

    Contact::FIELDS.collect do |f|
      unless (values = e.contact.send(f)).empty?
        data << [t(f, scope: [:values, :contacts]), values.join(', ')]
      end
    end

    e.addresses.each_with_index do |address, i|
      data << ['']
      data << ["#{i + 1}. #{t('label.address')}", address.address]
      data << ['', address.human_country]
    end

    table(data, cell_style: { borders: [], padding: 5 })
    move_down 16
    text e.comment.to_s
  end
end
