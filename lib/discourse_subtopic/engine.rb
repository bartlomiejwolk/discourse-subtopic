# frozen_string_literal: true

module ::DiscourseSubtopic
  class Engine < ::Rails::Engine
    engine_name PLUGIN_NAME
    isolate_namespace DiscourseSubtopic
    config.autoload_paths << File.join(config.root, "lib")
  end
end