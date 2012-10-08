require 'logical_model'
module ActivityStream
  class Activity < LogicalModel
    self.attribute_keys = [
        :id,
        :username,
        :account_name,
        :content,
        :generator,
        :verb,
        :target_id,
        :target_type,
        :object_id,
        :object_type,
        :created_at,
        :updated_at
    ]

    self.hydra = HYDRA
    self.use_ssl = (ENV['RACK_ENV']=="production")
    self.resource_path = "/v0/activities"
    self.use_api_key = true
    self.api_key_name = "app_key"
    self.api_key = API_KEY
    self.host  = HOST

    # this method should be overridden in each app.
    def local?
      false
    end

    def json_root
      'activity'
    end

    attr_accessor :cached_object
    def object
      if cached_object.present?
        cached_object
      elsif local?
        klass = self.object_type.camelize.constantize
        self.cached_object = klass.find(object_id) if klass.exists?(object_id)
      end
    end

    def local_deleted_object?
      local? && object.nil?
    end

    attr_accessor :cached_target
    def target
      if cached_target.present?
        cached_target
      elsif local?
        klass = target_type.camelize.constantize
        self.cached_target = klass.find(object_id) if klass.exists?(object_id)
      end
    end

  end
end