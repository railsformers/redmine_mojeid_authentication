require 'redmine'
require 'mojeid'

Rails.configuration.to_prepare do
  gem 'mojeid'
end

# patches
require_dependency 'patches'

# hooks
require_dependency 'hooks'

RAILS_DEFAULT_LOGGER.info 'Starting MojeIdAuthentication plugin for RedMine'

Redmine::Plugin.register :redmine_mojeid_authentication do
  name 'Redmine Mojeid Authentication plugin'
  author 'Richard Riman of Railsformers s.r.o.'
  description 'This plugin is an authentication extension for MojeID service (http://www.mojeid.cz/).'
  version '0.0.1'
  url 'https://github.com/railsformers/redmine_mojeid_authentication'
  author_url 'https://github.com/richardriman'
  requires_redmine :version_or_higher => '1.2.0'


end
