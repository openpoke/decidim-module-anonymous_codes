# frozen_string_literal: true

if !Rails.env.production? || ENV.fetch("SEED", nil)
  print "Creating seeds for decidim_anonymous_codes...\n" unless Rails.env.test?

  organization = Decidim::Organization.first
  admin = Decidim::User.where(admin: true).first
  participatory_processes = Decidim::ParticipatoryProcess.where(organization: organization)
  survey_components = Decidim::Component.where(manifest_name: "surveys", participatory_space: participatory_processes)
  survey_components.each do |component|
    form = OpenStruct.new(name: component.name, weight: component.weight, settings: component.settings, default_step_settings: component.default_step_settings,
                          step_settings: component.step_settings)
    form.step_settings.each do |key, _value|
      form.step_settings[key]["allow_answers"] = true
      form.step_settings[key]["allow_unregistered"] = true
    end
    Decidim::Admin::UpdateComponent.call(form, component, admin) do
      on(:ok) do
        puts "Component #{component.id} updated"
      end

      on(:invalid) do
        puts "ERROR: Component #{component.id} not updated"
      end
    end
  end

  [survey1, survey2].each do |survey|
    if survey.component.participatory_space.respond_to? :steps
      steps = survey.component.participatory_space.steps.pluck(:id)
      steps.each do |step|
        survey.component.attributes["settings"]["steps"] = { step.to_s => { "allow_answers" => true, "allow_unregistered" => true } }
      end
    else
      survey.component.attributes["settings"]["default_step"] = { "allow_answers" => true, "allow_unregistered" => true }
    end
    survey.save!
  end

  group1 = Decidim::AnonymousCodes::Group.create!(
    title: { en: "First Group" },
    organization: organization,
    expires_at: 1.week.from_now,
    active: true,
    max_reuses: 1,
    resource: survey1
  )

  group2 = Decidim::AnonymousCodes::Group.create!(
    title: { en: "Second Group" },
    organization: organization,
    expires_at: 1.week.from_now,
    active: true,
    max_reuses: 1,
    resource: survey2
  )

  5.times do
    Decidim::AnonymousCodes::Token.create!(token: Decidim::AnonymousCodes.token_generator, usage_count: 0, group: group1)
  end

  25.times do
    Decidim::AnonymousCodes::Token.create!(token: Decidim::AnonymousCodes.token_generator, usage_count: 0, group: group2)
  end
end
