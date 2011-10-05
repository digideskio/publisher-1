class Action
  include Mongoid::Document

  STATUS_ACTIONS = [
    CREATED              = "created",
    NEW_VERSION          = "new_version",
    FACT_CHECK_REQUESTED = "fact_check_requested",
    FACT_CHECK_RECEIVED  = "fact_check_received",
    REVIEW_REQUESTED     = "review_requested",
    REVIEWED             = "reviewed",
    OKAYED               = "okayed",
    PUBLISHED            = "published",
  ]

  NON_STATUS_ACTIONS = [
    NOTE                 = "note",
  ]

  embedded_in :edition

  field :requester_id, :type => Integer
  field :approver_id,  :type => Integer
  field :approved,     :type => DateTime
  field :comment,      :type => String
  field :request_type, :type => String
  field :created_at,   :type => DateTime, :default => lambda { Time.now }

  def friendly_description
    case request_type
    when CREATED
      "#{edition.container.class} created by #{requester.name}"
    when NEW_VERSION
      "New version \"#{edition.title}\" created by #{requester.name}"
    when FACT_CHECK_REQUESTED
      "A fact check for \"#{edition.title}\" was requested by #{requester.name}"
    when FACT_CHECK_RECEIVED
      "A fact check response for \"#{edition.title}\" was entered"
    when REVIEW_REQUESTED
      "A review and publish was requested by #{requester.name}"
    when REVIEWED
      "Reviewed by #{requester.name}. Not OK'd for publication"
    when OKAYED
      "OK'd for publication by #{requester.name}"
    when PUBLISHED
      "Published"
    when NOTE
      "Made a note"
    end
  end

  def requester
    @requester ||= User.first(conditions: {_id: self.requester_id})
  end

  def status_action?
    STATUS_ACTIONS.include?(request_type)
  end

  def to_s
    request_type.humanize.capitalize
  end
end
