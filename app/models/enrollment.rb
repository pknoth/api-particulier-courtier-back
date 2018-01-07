# frozen_string_literal: true

class Enrollment < ApplicationRecord
  # legacy for tests
  DOCUMENT_TYPES = %w[
    Document::CNILVoucher
    Document::CertificationResults
    Document::FranceConnectCompliance
    Document::LegalBasis
  ].freeze

  resourcify
  has_many :subscriptions
  has_many :scopes
  has_many :fields, as: :fieldable
  def all_fields
    all_fields = ->(acc, o) {
      return acc.flatten if o.fields.empty?
      acc << o.fields.to_a
      acc << o.fields.map { |e| all_fields.call(acc, e) }
      acc.flatten
    }
    all_fields.call([], self).uniq
  end
  has_many :document_types

  validate :applicant_validation
  # before_save :clean_json
  after_save :applicant_workflow

  private

  # def agreement_validation
  #   return if agreement

  #   errors.add(:agreement, "Vous devez accepter les conditions d'utilisation")
  # end

  def applicant_validation # rubocop:disable Metrics/AbcSize
    return unless applicant_changed? && can_sign_convention?

    errors.add(:applicant, "Vous devez renseigner l'Email") unless applicant['email'].present?
    errors.add(:applicant, 'Vous devez renseigner la Fonction') unless applicant['position'].present?
    errors.add(:applicant, 'Vous devez accepter la convention') unless applicant['agreement'].present?
  end

  def applicant_workflow
    if applicant&.fetch('email', nil).present? &&
       can_sign_convention?
      sign_convention!
    end
  end
end
