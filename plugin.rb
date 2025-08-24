# frozen_string_literal: true

# name: discourse-subtopic  
# about: Adds a 'Subtopic' button next to the Reply button that creates new related topics and links them back to the original
# version: 0.1.0
# authors: Claude Code AI
# url: https://github.com/discourse/discourse-subtopic

enabled_site_setting :discourse_subtopic_enabled

register_asset "stylesheets/discourse-subtopic.scss"

module ::DiscourseSubtopic
  PLUGIN_NAME = "discourse-subtopic"
end

require_relative "lib/discourse_subtopic/engine.rb"

after_initialize do
  
  # Add site settings to serializer
  if respond_to?(:add_to_serializer)
    add_to_serializer(:site, :discourse_subtopic_enabled) do
      SiteSetting.discourse_subtopic_enabled
    end
    
    # Add can_create_subtopic to topic detail serializer
    add_to_serializer(:topic_view, :can_create_subtopic) do
      scope.can_create_subtopic?(object.topic)
    end
  end

  module ::DiscourseSubtopic
    def self.create_subtopic!(original_topic, title, acting_user)
      ActiveRecord::Base.transaction do
        # Create new topic in same category as original
        subtopic = Topic.create!(
          title: ":yarn: #{title}",
          user: acting_user,
          category_id: original_topic.category_id,
          archetype: Archetype.default
        )

        # Copy tags from original topic if any exist
        if original_topic.tags.present?
          DiscourseTagging.tag_topic_by_names(subtopic, Guardian.new(acting_user), original_topic.tags.pluck(:name))
        end

        # Create first post in new topic
        post_creator = PostCreator.new(
          acting_user,
          topic_id: subtopic.id,
          raw: I18n.t("discourse_subtopic.first_post_content", 
            original_topic_title: original_topic.title,
            original_topic_url: "/t/#{original_topic.slug}/#{original_topic.id}")
        )
        first_post = post_creator.create

        # Create link back post in original topic
        link_post_creator = PostCreator.new(
          acting_user,
          topic_id: original_topic.id,
          raw: I18n.t("discourse_subtopic.link_post_content",
            subtopic_title: title,
            subtopic_url: "/t/#{subtopic.slug}/#{subtopic.id}")
        )
        link_post = link_post_creator.create

        # Update the subtopic's first post to link to the specific linking post
        if first_post && link_post
          updated_raw = first_post.raw.gsub(
            "/t/#{original_topic.slug}/#{original_topic.id}",
            "/t/#{original_topic.slug}/#{original_topic.id}/#{link_post.post_number}"
          )
          first_post.revise(acting_user, { raw: updated_raw })
        end

        # Store relationship in custom fields
        original_topic.custom_fields["subtopic_ids"] ||= []
        original_topic.custom_fields["subtopic_ids"] << subtopic.id
        original_topic.save!

        subtopic.custom_fields["parent_topic_id"] = original_topic.id
        subtopic.save!

        subtopic
      end
    end
  end

  # Add permissions check to Guardian
  add_to_class(:guardian, :can_create_subtopic?) do |topic|
    return false unless SiteSetting.discourse_subtopic_enabled
    return false unless authenticated?
    return false if topic.blank?
    return false if topic.private_message?
    return false if topic.closed?
    return false if topic.archived?
    
    # Can create subtopic if user can create topics in the category
    can_create_topic_on_category?(topic.category_id)
  end
end