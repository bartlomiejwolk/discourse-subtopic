import { withPluginApi } from "discourse/lib/plugin-api";
import CreateSubtopic from "../components/modal/create-subtopic";

export default {
  name: "discourse-subtopic",

  initialize() {
    withPluginApi("1.0.0", (api) => {
      const siteSettings = api.container.lookup("site-settings:main");
      
      console.log("🧶 SUBTOPIC JS: Plugin initializing...");
      console.log("🧶 SUBTOPIC JS: discourse_subtopic_enabled =", siteSettings.discourse_subtopic_enabled);
      console.log("🧶 SUBTOPIC JS: discourse_subtopic_hide_subtopics =", siteSettings.discourse_subtopic_hide_subtopics);
      
      if (!siteSettings.discourse_subtopic_enabled) {
        console.log("🧶 SUBTOPIC JS: Plugin disabled, exiting");
        return;
      }

      // Register the subtopic button
      api.registerTopicFooterButton({
        id: "subtopic",
        icon: "plus",
        label: "discourse_subtopic.create_subtopic.title",
        title: "discourse_subtopic.create_subtopic.help",
        classNames: ["create-subtopic"],
        priority: 250,
        displayed() {
          const currentUser = api.getCurrentUser();
          return currentUser !== null;
        },
        action() {
          const modal = api.container.lookup("service:modal");
          const topic = this.get ? this.get("topic") : this.topic;
          
          modal.show(CreateSubtopic, {
            model: {
              topic: topic,
            },
          });
        },
      });

      // Add yarn topic visibility toggle if hiding is enabled  
      if (siteSettings.discourse_subtopic_hide_subtopics) {
        console.log("🧶 SUBTOPIC JS: Adding yarn topic toggle functionality");
        
        // Add toggle button to the DOM after page loads
        api.onPageChange(() => {
          const router = api.container.lookup("service:router");
          const currentRoute = router.currentRoute;
          
          // Remove any existing toggle button
          const existingButton = document.querySelector('.yarn-toggle-btn');
          if (existingButton) {
            existingButton.remove();
          }
          
          // Only show on discovery routes (topic lists)
          if (!currentRoute || !currentRoute.name || !currentRoute.name.includes("discovery")) {
            return;
          }
          
          // Find the navigation area to add our button
          const navPrimary = document.querySelector('.navigation-controls');
          if (!navPrimary) return;
          
          const queryParams = currentRoute.queryParams || {};
          const showingYarn = queryParams.show_yarn_topics === "true";
          
          // Create toggle button
          const toggleBtn = document.createElement('button');
          toggleBtn.className = 'btn btn-default yarn-toggle-btn' + (showingYarn ? ' active' : '');
          toggleBtn.textContent = '🧶 ' + (showingYarn ? 'Hide Subtopics' : 'Show Subtopics');
          toggleBtn.title = showingYarn ? 'Hide Subtopics' : 'Show Only Subtopics';
          
          toggleBtn.addEventListener('click', (e) => {
            e.preventDefault();
            console.log("🧶 Button clicked, current showingYarn:", showingYarn);
            
            const currentPath = window.location.pathname;
            const urlParams = new URLSearchParams(window.location.search);
            
            if (showingYarn) {
              // Currently showing yarn topics, go back to default (hide yarn)
              urlParams.delete('show_yarn_topics');
              console.log("🧶 Removing show_yarn_topics parameter");
            } else {
              // Currently hiding yarn topics, show only yarn topics
              urlParams.set('show_yarn_topics', 'true');
              console.log("🧶 Setting show_yarn_topics=true");
            }
            
            const newUrl = currentPath + (urlParams.toString() ? '?' + urlParams.toString() : '');
            console.log("🧶 Navigating to:", newUrl);
            
            window.location.href = newUrl;
          });
          
          // Add button to navigation
          navPrimary.appendChild(toggleBtn);
        });
      }
    });
  },
};