class Subscription < ApplicationRecord
  resourcify

  belongs_to :enrollment
  has_many :documents
  accepts_nested_attributes_for :documents
  has_many :messages
  has_many :answers
  has_many :scope_subscriptions

  delegate :fields, to: :enrollment

  # Note convention on events "#{verb}_#{what}" (see CoreAdditions::String#as_event_personified)
  state_machine :state, initial: 'initial' do # rubocop:disable Metrics/BlockLength
    state 'filled_application' do
      validate :fields_validation

      def fields_validation
        enrollment&.all_fields.each do |field|
          next unless field.required?

          unless answers.to_a.find { |e| e.field_id == field.id }
            errors[:base] << "#{field.human_name} doit être rempli"
          end
        end
      end
    end
    state 'waiting_for_approval' do
      validate :document_validation

      def document_validation
        enrollment.document_types.each do |document_type|
          unless documents.where(document_type: document_type).present?
            errors.add(:documents, "Vous devez envoyer le document : #{document_type.human_name}")
          end
        end
      end
    end

    state 'application_approved'
    state 'application_ready'
    state 'deployed'

    after_transition any => any do |subscription, transition|
      message = Message.create(content: I18n.t("models.subscription.event.#{transition.event}"))
      subscription.attach_message(message)
    end

    event 'fill_application' do
      transition 'initial' => 'filled_application'
    end
    event 'complete_application' do
      transition %w[filled_application completed_application] => 'waiting_for_approval'
    end

    event 'send_application' do
      transition 'completed_application' => 'waiting_for_approval'
    end

    event 'refuse_application' do
      transition %w[filled_application waiting_for_approval] => 'filled_application'
    end

    event 'approve_application' do
      transition %w[filled_application completed_application waiting_for_approval] => 'application_approved'
    end

    event 'sign_convention' do
      transition 'application_approved' => 'application_ready'
    end

    event 'deploy' do
      transition 'application_ready' => 'deployed'
    end
  end

  def attach_message(message)
    messages << message
  end

  def respond_to_missing?(method, include_private = false)
    if method.to_s =~ /\=/
      field = enrollment&.all_fields&.find { |e| e.name == method.to_s.delete('=') }
      scope = enrollment&.scopes&.find { |e| e.name == method.to_s.delete('=') }
      return super unless field || scope
      return true
    end

    field = enrollment&.all_fields&.find { |e| e.name == method.to_s }
    scope = enrollment&.scopes&.find { |e| e.name == method.to_s }
    return true if field || scope

    super
  end

  def method_missing(method, *args, &block)
    if method.to_s =~ /\=/
      field = enrollment&.all_fields&.find { |e| e.name == method.to_s.delete('=') }
      scope = enrollment&.scopes&.find { |e| e.name == method.to_s.delete('=') }
      return answers.build(field: field, content: args[0]) if field
      return scope_subscriptions.build(
        scope: scope,
        selected: args[0]
      ) if scope
      return super
    end

    field = enrollment&.all_fields&.find { |e| e.name == method.to_s }
    scope = enrollment&.scopes&.find { |e| e.name == method.to_s }

    return answers.to_a.find { |e| e.field_id == field.id }&.content if field
    return scope_subscriptions.to_a.find { |e| e.scope_id == scope.id }&.selected if scope

    super
  end
end
