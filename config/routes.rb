# frozen_string_literal: true

DiscourseSubtopic::Engine.routes.draw do
  post "/create" => "subtopics#create"
end

Discourse::Application.routes.append do
  mount ::DiscourseSubtopic::Engine, at: "/discourse-subtopic"
end