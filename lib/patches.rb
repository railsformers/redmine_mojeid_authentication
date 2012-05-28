require_dependency 'principal'
require_dependency 'user'

module UserPatch
  def self.included(base) # :nodoc:
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      validates_uniqueness_of :mojeid_identity_url, :allow_nil => true
    end
  end
end

# add module to User
User.send(:include, UserPatch)
