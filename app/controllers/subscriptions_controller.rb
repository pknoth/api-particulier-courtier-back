# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  before_action :authenticate!
  before_action :set_enrollment
  before_action :set_subscription, only: %i[show convention update trigger destroy]

  # GET /subscriptions
  def index
    @subscriptions = subscriptions_scope

    render json: @subscriptions.map { |e| serialize(e) }
  end

  # GET /subscriptions/1
  def show
    render json: serialize(@subscription)
  end

  # GET /subscriptions/1/convention
  def convention
    authorize @subscription, :convention?
    @filename = 'convention.pdf'
  end

  # POST /subscriptions
  def create
    @subscription = subscriptions_scope.new(subscription_params)

    authorize @subscription, :create?

    if @subscription.fill_application
      current_user.add_role(:applicant, @subscription)
      render json: @subscription, status: :created, location: enrollment_subscription_url(@enrollment, @subscription)
    else
      render json: @subscription.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /subscriptions/1
  def update
    @subscription.attributes = subscription_params
    authorize @subscription, :update?
    if @subscription.save
      render json: serialize(@subscription)
    else
      render json: @subscription.errors, status: :unprocessable_entity
    end
  end

  # PATCH /subscription/1/trigge
  def trigger
    authorize @subscription, "#{event_param}?".to_sym

    if @subscription.send(event_param.to_sym)
      current_user.add_role(event_param.as_event_personified.to_sym, @subscription)
      render json: serialize(@subscription)
    else
      render status: :unprocessable_entity, json: @subscription.errors
    end
  end

  # DELETE /subscriptions/1
  def destroy
    @subscription.destroy
  end

  def serialize(subscription)
    subscription.as_json(
     include: {
       enrollment: {},
       answers: {},
       documents: { methods: [:name] },
       scope_subscriptions: {},
       messages: { methods: [:sender] }
     },
      methods: enrollment_fields
    ).merge('acl' => Hash[
      SubscriptionPolicy.acl_methods.map do |method|
        [method.to_s.delete('?'), SubscriptionPolicy.new(current_user, subscription).send(method)]
      end
    ])
  end

  private

  def set_enrollment
    @enrollment = Enrollment.find_by(name: params[:enrollment_id])
  end

  def set_subscription
    @enrollment ||= Subscription.find(params[:id]).enrollment
    @subscription = subscriptions_scope.find(params[:id])
  end

  def subscriptions_scope
    subscriptions = if @enrollment
                      Subscription.where(enrollment: @enrollment)
                    else
                      Subscription.all
                    end
    SubscriptionPolicy::Scope.new(current_user, subscriptions).resolve
  end

  def subscription_params
    fields = []
    fields << enrollment_fields
    fields << { service_provider: {} }
    params.fetch(:subscription, {}).permit(
      *fields, documents_attributes: [:attachment_type, :attachment]
    )
  end

  def enrollment_fields
    fields = []
    @enrollment.all_fields.concat(@enrollment.scopes).each do |field|
      fields << field.name.to_sym if field.name
    end if @enrollment
    fields
  end

  def event_param
    event = params[:event]
    raise EventNotPermitted unless Subscription.state_machine.events.map(&:name).include?(event)
    event
  end

  class EventNotPermitted < StandardError; end

  rescue_from EventNotPermitted do
    render status: :bad_request, json: {
      message: ['event not permitted']
    }
  end
end
