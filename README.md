# Discourse Subtopic Plugin

This plugin adds a "Subtopic" button next to the Reply button at the end of topics, allowing users to create new related topics that are automatically linked back to the original discussion.

## Features

- **Subtopic Button**: Adds a "Subtopic" button next to the Reply button in topic footers
- **Modal Interface**: Clean modal dialog for entering the new subtopic title  
- **Automatic Linking**: Creates cross-references between the original topic and subtopic
- **Permission Checks**: Respects Discourse's existing permission system
- **Category Inheritance**: New subtopics inherit the category and tags from the parent topic

## How it Works

1. **Button Display**: The Subtopic button appears next to the Reply button for users who can create topics in the current category
2. **Topic Creation**: Clicking the button opens a modal where users can enter a title for the new subtopic
3. **Cross-Linking**: 
   - The new subtopic gets a first post that links back to the original topic
   - The original topic gets a new post linking to the subtopic 
4. **Navigation**: After creation, users are automatically navigated to the new subtopic

## Implementation Details

### Backend Components
- `plugin.rb` - Main plugin configuration and business logic
- `app/controllers/discourse_subtopic/subtopics_controller.rb` - API endpoint for creating subtopics
- `config/routes.rb` - Routing configuration  
- `config/settings.yml` - Plugin settings

### Frontend Components  
- `assets/javascripts/discourse/initializers/discourse-subtopic.js` - Registers the topic footer button
- `assets/javascripts/discourse/components/modal/create-subtopic.gjs` - Modal component for creating subtopics
- `assets/stylesheets/discourse-subtopic.scss` - Styling for the modal and button

### Translations
- `config/locales/client.en.yml` - Frontend translations
- `config/locales/server.en.yml` - Backend translations for generated content

## Installation

1. Add the plugin to your Discourse installation
2. Rebuild your Discourse instance
3. The plugin is enabled by default via the `discourse_subtopic_enabled` site setting

## Permission Requirements

Users can create subtopics if they:
- Are authenticated
- Can create topics in the current category  
- The topic is not private, closed, or archived

## Technical Architecture

The plugin follows Discourse's standard plugin architecture:
- Uses the topic footer button registration system
- Implements proper Guardian permission checks
- Creates topics using Discourse's PostCreator service
- Stores relationships via custom fields
- Uses Discourse's modal system for the UI