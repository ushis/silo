# The ExpertsReport provides report rendering of the reports for a single
# Expert and a collection of mutliple experts.
class ExpertsReport < ApplicationReport

  # Creates a report for an Expert or a collection of experts.
  def self.for(obj, user, params = {})
    case obj
    when Expert
      report = new(obj.full_name_with_degree, user)
      report.show(obj)
    when Array, ActiveRecord::Relation
      report = new(I18n.t('labels.expert.index'), user)
      report.index(obj, params)
    else
      flash[:alert] = t('messages.attachment.errors.store') and return
      raise TypeError, "Argument 1 must be an Expert or Array: #{obj.class}"
    end

    report
  end

  # Adds a bunch of experts to a report
  def index(experts, params)
    a = lambda { |k| Expert.human_attribute_name(k) }

    data = [
      [a.call(:name), params[:name]],
      [a.call(:languages), Language.where(id: params[:languages]).join(', ')],
      [a.call(:country), Country.where(id: params[:countries]).join(', ')],
      [t('labels.generic.fulltext'), params[:q]],
      [t('labels.generic.page'), "#{experts.current_page}/#{experts.total_pages}"]
    ]

    h2 t('labels.generic.search_params')
    table data

    return if experts.empty?

    data = experts.collect do |expert|
      [expert.name, expert.prename, expert.country.try(:human)]
    end

    move_down 16
    h2 t('labels.generic.results')
    table(data) { |table| table.width = 380 }
  end

  # Adds an expert to a report.
  def show(e)
    a = lambda { |k| Expert.human_attribute_name(k) }

    data = [
      [a.call(:degree), e.degree],
      [a.call(:prename), e.prename],
      [a.call(:name), e.name],
      [a.call(:country), e.country.try(:human)],
      [a.call(:birthday), e.human_birthday],
      [a.call(:gender), e.human_gender],
      [a.call(:languages), e.languages.collect { |l| l.human }.join(', ')],
      [a.call(:job), e.job],
      [a.call(:fee), e.fee],
      [a.call(:former_collaboration), e.human_former_collaboration],
    ]

    Contact::FIELDS.collect do |f|
      unless (values = e.contact.send(f)).empty?
        data << [t(f, scope: [:values, :contacts]), values.join(', ')]
      end
    end

    table data

    unless e.addresses.empty?
      move_down 16
      h2 a.call(:addresses)
      current_y = y - 36

      e.addresses.each_with_index do |address, i|
        bounding_box [(i * 130), current_y], width: 120 do
          indent 5 do
            text address.address

            if address.country
              move_down 4
              text address.country.human
            end
          end
        end
      end
    end

    move_down 16
    h2 a.call(:comment)
    indent(5) { text e.comment.to_s }
  end
end
