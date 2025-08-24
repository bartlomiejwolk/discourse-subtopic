import { withPluginApi } from "discourse/lib/plugin-api";
import CreateSubtopic from "../components/modal/create-subtopic";

export default {
  name: "discourse-subtopic",

  initialize() {
    withPluginApi("1.0.0", (api) => {
      if (!api.container.lookup("site-settings:main").discourse_subtopic_enabled) {
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

    });
  },
};