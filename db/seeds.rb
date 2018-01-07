legal_basis = Field.new(
  type: 'Field::Section',
  label: "Veuillez transmettre le fondement juridique sur lequel s'appuie votre demande d'utilisation des données DGFIP",
  fields: [
    Field.new(
      name: 'legal_basis_comment',
      type: 'Field::Text'
    )
  ]
)
service_description = Field.new(
  type: 'Field::Section',
  label: 'Description de votre service',
  fields: [
    Field.new(
      type: 'Field::Text',
      label: 'Décrivez brièvement votre service ainsi que l’utilisation prévue des données transmises par l’API Impôt Particulier :',
      name: 'service_description_description'
    ),
    Field.new(
      type: 'Field::Date',
      label: 'Quelle est la date estimée de mise en production de votre branchement à l’API ?',
      name: 'service_description_deploy_date'
    )
  ]
)
agreement = Field.new(type: 'Field::Section', fields: [
  Field.new(
    name: 'agreement',
    human_name: 'Agreement',
    label: 'En cochant cette case, je certifie que les informations saisies, notamment le fondement juridique indiqué, sont correctes. Je m’engage à exploiter les données DGFIP dans le cadre réglementaire adapté. Je m’engage à fournir les résultats de l’homologation de mon service selon le référentiel RGS dans un délai de ---.',
    type: 'Field::Boolean',
    required: true
  )
])

scopes = []
scopes << number_of_tax_shares = Scope.new(
  name: 'number_of_tax_shares',
  human_name: 'RFR et nombre de parts fiscales
'
)
scopes << Scope.new(
  name: 'tax_address',
  human_name: 'Adresse fiscale de taxation à l\'IR'
)
scopes << Scope.new(
  name: 'non_wadge_income',
  human_name: 'Revenus non salariaux'
)
scopes << Scope.new(
  name: 'family_situation',
  human_name: 'Situation de la famille et détail du nombre de personnes à charge'
)
scopes << Scope.new(
  name: 'support_payments',
  human_name: 'Montant des pensions alimentaires reçues'
)
scopes << Scope.new(
  name: 'deficit',
  human_name: 'Existance de déficit sur l\'année de revenus'
)
scopes << Scope.new(
  name: 'housing_tax',
  human_name: 'Données de taxe d\'habitation principale'
)
scopes << Scope.new(
  name: 'total_gross_income',
  human_name: 'Revenu Brut Global / Déficit Brut Global'
)
scopes << Scope.new(
  name: 'world_income',
  human_name: 'Montant des revenus mondiaux'
)

document_types = []
document_types << DocumentType.new(
    name: 'Document::CNILVoucher',
    human_name: 'Récipissé CNIL'
)
document_types << DocumentType.new(
    name: 'Document::CertificationResults',
    human_name: "Résultats d'homologuation"
)
document_types << DocumentType.new(
    name: 'Document::FranceConnectCompliance',
    human_name: 'Déclaration CNIL de conformité FranceConnect'
)
document_types << DocumentType.new(
    name: 'Document::LegalBasis',
    human_name: 'Base légale'
)

dgfip = Enrollment.create!(
  name: 'dgfip',
  human_name: 'DGFIP',
  service_provider_type: 'ServiceProvider::FranceConnect',
  description: "L'enrôlement auprès des scopes de la DGFIP",
  fields: [
    legal_basis,
    service_description,
    agreement,
  ],
  scopes: scopes,
  document_types: document_types
)

cnamts = Enrollment.where(
  name: 'cnamts',
  human_name: 'CNAMTS',
  service_provider_type: 'ServiceProvider::FranceConnect',
  description: "L'enrôlement auprès des scopes de la CNAMTS"
).first_or_create
