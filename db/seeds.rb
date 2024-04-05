# frozen_string_literal: true

if !Rails.env.production? || ENV.fetch("SEED", nil)
  organization = Decidim::Organization.first
  participatory_processes = Decidim::ParticipatoryProcess.where(organization: organization)

  unless participatory_processes.count.positive?
    puts "No participatory processes found. Skipping seeds for decidim_anonymous_codes..."
    return
  end
  print "Creating seeds for decidim_anonymous_codes...\n" unless Rails.env.test?

  admin = Decidim::User.where(admin: true).first
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
        puts "Component #{component.id} updated for allowing answers and unregistered users"
      end

      on(:invalid) do
        puts "ERROR: Component #{component.id} not updated for allowing answers and unregistered users"
      end
    end

    survey = Decidim::Surveys::Survey.find_by(component: component)
    next unless survey

    group = Decidim.traceability.create!(
      Decidim::AnonymousCodes::Group,
      admin,
      {
        title: { en: "Group for Survey #{survey.id}" },
        organization: organization,
        expires_at: 1.week.from_now,
        active: rand(2).zero?,
        max_reuses: rand(3),
        resource: survey
      },
      visibility: "admin-only"
    )
    total = rand(1..25)
    total.times do
      Decidim::AnonymousCodes::Token.create!(token: Decidim::AnonymousCodes.token_generator, group: group)
    end
    puts "Created #{total} tokens for survey #{survey.id}"
  end
end
