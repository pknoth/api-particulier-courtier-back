# frozen_string_literal: true

FactoryGirl.define do
  factory :enrollment do
    name 'test'
    document_types do
      %w[
      Document::CNILVoucher
      Document::CertificationResults
      Document::FranceConnectCompliance
      Document::LegalBasis
      ].map do |document_type|
        FactoryGirl.build(:document_type, name: document_type, human_name: document_type)
      end
    end
    # service_provider name: 'test'
    # scopes number_of_tax_shares: false, tax_address: false,
    #        non_wadge_income: false, family_situation: false, support_payments: false,
    #        deficit: false, housing_tax: false, total_gross_income: false,
    #        world_income: false
    # legal_basis comment: nil, attachment: nil
    # service_description main: nil, deployment_date: nil, seasonality: nil,
    #                     max_charge: nil
    # agreement true
    # fields
  end
end
