// components/my-form-modal.gjs
import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { on } from "@ember/modifier";
import DModal from "discourse/components/d-modal";
import DButton from "discourse/components/d-button";
import DModalCancel from "discourse/components/d-modal-cancel";

export default class MyFormModal extends Component {
  @tracked formData = {
    title: "",
    content: "",
    category: null
  };
  @tracked errors = {};
  @tracked isSubmitting = false;

  @action
  updateField(field, event) {
    this.formData[field] = event.target.value;
    // Clear field error when user starts typing
    if (this.errors[field]) {
      delete this.errors[field];
    }
  }

  @action
  async submitForm(event) {
    event.preventDefault();
    
    if (this.isSubmitting) return;
    
    this.errors = {};
    this.isSubmitting = true;
    
    try {
      const result = await this.processSubmission();
      
      // Insert text into composer if provided
      if (this.args.model.insertText && result.text) {
        this.args.model.insertText(result.text);
      }
      
      this.args.closeModal(result);
    } catch (error) {
      this.errors = error.errors || { general: error.message };
    } finally {
      this.isSubmitting = false;
    }
  }

  @action
  handleKeydown(event) {
    if (event.key === "Escape") {
      this.args.closeModal();
    }
  }

  <template>
    <DModal 
      @title="Create Content" 
      @closeModal={{@closeModal}} 
      class="my-form-modal"
      {{on "keydown" this.handleKeydown}}
    >
      <:body>
        <form {{on "submit" this.submitForm}} class="form-horizontal">
          <div class="control-group">
            <label for="content-title">Title</label>
            <input 
              id="content-title"
              type="text"
              value={{this.formData.title}}
              {{on "input" (fn this.updateField "title")}}
              class={{if this.errors.title "error"}}
              placeholder="Enter title"
            />
            {{#if this.errors.title}}
              <span class="error-message">{{this.errors.title}}</span>
            {{/if}}
          </div>
          
          <div class="control-group">
            <label for="content-body">Content</label>
            <textarea 
              id="content-body"
              value={{this.formData.content}}
              {{on "input" (fn this.updateField "content")}}
              rows="6"
              class={{if this.errors.content "error"}}
              placeholder="Enter content"
            ></textarea>
          </div>
        </form>
      </:body>
      <:footer>
        <DButton 
          @action={{this.submitForm}}
          @disabled={{this.isSubmitting}}
          @icon={{if this.isSubmitting "spinner" "check"}}
          class="btn-primary"
        >
          {{if this.isSubmitting "Submitting..." "Create Content"}}
        </DButton>
        <DModalCancel @close={{@closeModal}} />
      </:footer>
    </DModal>
  </template>
}
