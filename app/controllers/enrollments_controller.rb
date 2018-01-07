# frozen_string_literal: true

class EnrollmentsController < ApplicationController
  before_action :set_enrollment, only: %i[show convention update trigger destroy]

  # GET /enrollments
  def index
    @enrollments = enrollments_scope

    render json: @enrollments
  end

  # GET /enrollments/1
  def show
    render json: @enrollment.to_json(
      include: {
        scopes: {},
        document_types: {},
        fields: {
          methods: :type,
          include: {
            fields: { methods: :type }
          }
        }
      }
    )
  end

  private

  def set_enrollment
    @enrollment = enrollments_scope.find_by(name: params[:id])
  end

  def enrollments_scope
    Enrollment.all
  end
end
