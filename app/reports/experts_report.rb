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
    a = lambda { |k| Expert.human_attribute_name(k) }

    data = [
      [a.call(:name), e.name],
      [a.call(:prename), e.prename],
      [a.call(:gender), e.human_gender],
      [''],
      [a.call(:birthday), l(e.birthday, format: :short)],
      [a.call(:citizenship), e.human_citizenship],
      [''],
      [a.call(:job), e.job],
      [''],
      [a.call(:degree), e.degree],
      [a.call(:languages), e.languages.collect { |l| l.human }.join(', ')],
      [''],
      [a.call(:former_collaboration), e.human_former_collaboration],
      [a.call(:fee), e.fee],
      ['']
    ]

    Contact::FIELDS.collect do |f|
      unless (values = e.contact.send(f)).empty?
        data << [t(f, scope: [:values, :contacts]), values.join(', ')]
      end
    end

    table(data, cell_style: { borders: [], padding: 5 })

    unless e.addresses.empty?
      move_down 16
      text a.call(:addresses)

      e.addresses.each do |address|
        move_down 16
        text address.address
        text address.human_country
      end
    end

    move_down 16
    text e.comment.to_s
  end
end
