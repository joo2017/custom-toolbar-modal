// assets/javascripts/discourse/api-initializers/lottery-modal-outlet.js
import { withPluginApi } from "discourse/lib/plugin-api";
import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { on } from "@ember/modifier";
import { fn } from "@ember/helper";
import DModal from "discourse/components/d-modal";
import DButton from "discourse/components/d-button";
import DModalCancel from "discourse/components/d-modal-cancel";

export default {
  name: "lottery-modal-outlet",
  initialize() {
    withPluginApi("0.8.31", (api) => {
      api.renderInOutlet("above-main-container", class extends Component {
        @service appEvents;
        @tracked modalIsVisible = false;
        @tracked formData = {
          activity_name: "",
          prize_description: "",
          draw_time: "",
          winner_count: 1
        };

        constructor() {
          super(...arguments);
          this.appEvents.on("lottery:show-modal", this, this.showModal);
        }

        willDestroy() {
          super.willDestroy();
          this.appEvents.off("lottery:show-modal", this, this.showModal);
        }

        @action
        showModal() {
          this.modalIsVisible = true;
        }

        @action
        closeModal() {
          this.modalIsVisible = false;
        }

        @action
        updateField(fieldName, event) {
          this.formData = {
            ...this.formData,
            [fieldName]: event.target.value
          };
        }

        @action
        async submitForm(event) {
          event?.preventDefault();
          console.log("提交数据:", this.formData);
          this.closeModal();
        }

        <template>
          {{#if this.modalIsVisible}}
            <DModal @title="创建抽奖活动" @closeModal={{this.closeModal}} class="lottery-form-modal">
              <:body>
                <div class="lottery-form-container">
                  <form {{on "submit" this.submitForm}}>
                    
                    <div class="form-group">
                      <label>活动名称</label>
                      <input
                        type="text"
                        class="form-control"
                        value={{this.formData.activity_name}}
                        placeholder="请输入活动名称"
                        {{on "input" (fn this.updateField "activity_name")}}
                      />
                    </div>

                    <div class="form-group">
                      <label>奖品说明</label>
                      <input
                        type="text"
                        class="form-control"
                        value={{this.formData.prize_description}}
                        placeholder="请描述奖品内容"
                        {{on "input" (fn this.updateField "prize_description")}}
                      />
                    </div>

                    <div class="form-group">
                      <label>开奖时间</label>
                      <input
                        type="datetime-local"
                        class="form-control"
                        value={{this.formData.draw_time}}
                        {{on "input" (fn this.updateField "draw_time")}}
                      />
                    </div>

                    <div class="form-group">
                      <label>获奖人数</label>
                      <input
                        type="number"
                        class="form-control"
                        value={{this.formData.winner_count}}
                        min="1"
                        {{on "input" (fn this.updateField "winner_count")}}
                      />
                    </div>

                  </form>
                </div>
              </:body>

              <:footer>
                <DModalCancel @close={{this.closeModal}} />
                <DButton @action={{this.submitForm}} class="btn-primary">创建抽奖</DButton>
              </:footer>
            </DModal>
          {{/if}}
        </template>
      });
    });
  }
};
