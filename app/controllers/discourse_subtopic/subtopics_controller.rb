# frozen_string_literal: true

class DiscourseSubtopic::SubtopicsController < ::ApplicationController
  requires_plugin DiscourseSubtopic::PLUGIN_NAME

  def create
    # Debug logging
    Rails.logger.info "Subtopic create request received with params: #{params.inspect}"
    
    unless params[:topic_id].present?
      return render_json_error("Missing topic_id parameter")
    end
    
    unless params[:title].present?
      return render_json_error("Missing title parameter") 
    end

    original_topic = Topic.find(params[:topic_id].to_i)
    guardian.ensure_can_create_subtopic!(original_topic)

    title = params[:title].to_s.strip
    if title.blank?
      return render_json_error("Title cannot be empty")
    end
    
    if title.length < SiteSetting.min_topic_title_length
      return render_json_error("Title too short (minimum #{SiteSetting.min_topic_title_length} characters)")
    end
    
    if title.length > SiteSetting.max_topic_title_length
      return render_json_error("Title too long (maximum #{SiteSetting.max_topic_title_length} characters)")
    end

    subtopic = DiscourseSubtopic.create_subtopic!(original_topic, title, current_user)

    render json: { 
      id: subtopic.id,
      slug: subtopic.slug,
      title: subtopic.title,
      url: subtopic.relative_url
    }
  rescue StandardError => e
    Rails.logger.error "Subtopic creation error: #{e.message}\n#{e.backtrace.join('\n')}"
    render_json_error(e.message)
  end
end