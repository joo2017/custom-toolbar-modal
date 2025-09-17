// components/my-modal.gjs
import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import DModal from "discourse/components/d-modal";
import DButton from "discourse/components/d-button";

export default class MyModal extends Component {
  @tracked inputValue = "";
  @tracked isSubmitting = false;

  @action
  async handleSubmit() {
    this.isSubmitting = true;
    try {
      await this.processForm();
      this.args.closeModal({ success: true });
    } catch (error) {
      this.flash = error.message;
    } finally {
      this.isSubmitting = false;
    }
  }

  <template>
    <DModal @title="Form Modal" @closeModal={{@closeModal}} @flash={{this.flash}}>
      <:body>
        <form {{on "submit" this.handleSubmit}}>
          {{input value=this.inputValue placeholder="Enter value"}}
        </form>
      </:body>
      <:footer>
        <DButton 
          @action={{this.handleSubmit}} 
          @disabled={{this.isSubmitting}}
          @icon={{if this.isSubmitting "spinner" "check"}}
          class="btn-primary">
          Submit
        </DButton>
        <DModalCancel @close={{@closeModal}} />
      </:footer>
    </DModal>
  </template>
}
