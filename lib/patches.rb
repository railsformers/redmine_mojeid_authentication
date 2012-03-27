require_dependency 'user'

module UserPatch
  def self.included(base) # :nodoc:
    base.class_eval do
      validates_uniqueness_of :mojeid_identity_url
    end
  end
end
