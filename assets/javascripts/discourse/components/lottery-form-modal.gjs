import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { eq } from "truth-helpers";
import DModal from "discourse/components/d-modal";
import DButton from "discourse/components/d-button";
import DModalCancel from "discourse/components/d-modal-cancel";

export default class LotteryFormModal extends Component {
  @tracked formData = {
    activity_name: "",
    prize_description: "",
    prize_image_url: "",
    draw_time: "",
    winner_count: 1,
    specific_floors: "",
    participation_threshold: 1,
    backup_strategy: "continue",
    additional_notes: ""
  };

  @tracked validationErrors = {};
  @tracked isSubmitting = false;

  get backupStrategyOptions() {
    return [
      { value: "continue", label: "继续抽奖直到找到有效参与者" },
      { value: "reduce", label: "减少获奖人数" },
      { value: "cancel", label: "取消抽奖" }
    ];
  }

  @action
  updateField(fieldName, event) {
    if (event && event.target) {
      this.formData[fieldName] = event.target.value;
    }
  }

  @action
  async submitForm(event) {
    if (event) {
      event.preventDefault();
    }
    
    this.isSubmitting = true;
    
    try {
      console.log("提交数据:", this.formData);
      if (this.args.closeModal) {
        this.args.closeModal();
      }
    } catch (error) {
      console.error("提交失败:", error);
    } finally {
      this.isSubmitting = false;
    }
  }

  @action
  resetForm() {
    this.formData = {
      activity_name: "",
      prize_description: "",
      prize_image_url: "",
      draw_time: "",
      winner_count: 1,
      specific_floors: "",
      participation_threshold: 1,
      backup_strategy: "continue",
      additional_notes: ""
    };
  }

  @action
  cancel() {
    if (this.args.closeModal) {
      this.args.closeModal();
    }
  }

  <template>
    <DModal 
      @title="创建抽奖活动"
      @closeModal={{@closeModal}}
      class="lottery-form-modal"
    >
      <:body>
        <div class="lottery-form-container">
          <form {{on "submit" this.submitForm}}>
            <!-- 你的表单内容保持不变 -->
            <!-- ... -->
            
            {{! 后备策略 - 修复下拉菜单 }}
            <div class="form-group">
              <label class="form-label">后备策略 <span class="required">*</span></label>
              <select
                class="form-control"
                value={{this.formData.backup_strategy}}
                {{on "change" (fn this.updateField "backup_strategy")}}
              >
                {{#each this.backupStrategyOptions as |option|}}
                  <option
                    value={{option.value}}
                    selected={{eq this.formData.backup_strategy option.value}}
                  >
                    {{option.label}}
                  </option>
                {{/each}}
              </select>
            </div>
          </form>
        </div>
      </:body>

      <:footer>
        <div class="modal-footer-buttons">
          <DButton
            @action={{this.resetForm}}
            @disabled={{this.isSubmitting}}
            class="btn-default"
          >
            重置
          </DButton>

          <DModalCancel @close={{this.cancel}} />

          <DButton
            @action={{this.submitForm}}
            @disabled={{this.isSubmitting}}
            class="btn-primary"
          >
            {{#if this.isSubmitting}}
              创建中...
            {{else}}
              创建抽奖
            {{/if}}
          </DButton>
        </div>
      </:footer>
    </DModal>
  </template>
}
