import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DModal from "discourse/components/d-modal";
import DModalCancel from "discourse/components/d-modal-cancel";
import DButton from "discourse/components/d-button";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";

export default class CreateSubtopic extends Component {
  @service router;
  @tracked title = "";
  @tracked loading = false;

  get topic() {
    return this.args.model.topic;
  }

  get buttonDisabled() {
    return this.loading || this.title.trim().length === 0;
  }

  @action
  updateTitle(event) {
    this.title = event.target.value;
  }

  @action
  async createSubtopic() {
    if (this.buttonDisabled) {
      return;
    }

    this.loading = true;

    const requestData = {
      topic_id: this.topic.id,
      title: this.title.trim(),
    };

    try {
      const result = await ajax("/discourse-subtopic/create", {
        method: "POST",
        data: requestData,
      });
      
      // Navigate to the new subtopic
      this.router.transitionTo("topicBySlugOrId", result.slug);
      this.args.closeModal();
    } catch (error) {
      popupAjaxError(error);
    } finally {
      this.loading = false;
    }
  }

  <template>
    <DModal
      @title={{i18n "discourse_subtopic.create_subtopic.modal_title"}}
      @closeModal={{@closeModal}}
      class="create-subtopic-modal"
    >
      <:body>
        <div class="create-subtopic-form">
          <label for="subtopic-title">
            {{i18n "discourse_subtopic.create_subtopic.title_label"}}
          </label>
          <input
            id="subtopic-title"
            type="text"
            class="subtopic-title-input"
            placeholder={{i18n "discourse_subtopic.create_subtopic.title_placeholder"}}
            value={{this.title}}
            {{on "input" this.updateTitle}}
            maxlength="255"
            autofocus
          />
          <div class="subtopic-info">
            {{i18n "discourse_subtopic.create_subtopic.info" topic_title=this.topic.title}}
          </div>
        </div>
      </:body>
      <:footer>
        <DButton
          @action={{this.createSubtopic}}
          @disabled={{this.buttonDisabled}}
          @isLoading={{this.loading}}
          @icon="plus"
          @label="discourse_subtopic.create_subtopic.create_button"
          class="btn-primary"
        />
        <DButton
          @action={{@closeModal}}
          @label="cancel"
          class="btn-default"
        />
      </:footer>
    </DModal>
  </template>
}