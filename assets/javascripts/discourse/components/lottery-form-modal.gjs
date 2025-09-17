import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
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

  backupStrategyOptions = [
    { value: "continue", label: "继续抽奖直到找到有效参与者" },
    { value: "reduce", label: "减少获奖人数" },
    { value: "cancel", label: "取消抽奖" }
  ];

  @action
  updateField(fieldName, event) {
    this.formData[fieldName] = event.target.value;
  }

  @action
  async submitForm(event) {
    event.preventDefault();
    this.isSubmitting = true;
    
    try {
      // 这里添加你的提交逻辑
      console.log("提交数据:", this.formData);
      // 提交成功后关闭模态框
      this.args.closeModal();
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
    this.args.closeModal();
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
            {{! 活动名称 }}
            <div class="form-group">
              <label class="form-label">活动名称 <span class="required">*</span></label>
              <input
                type="text"
                class="form-control {{if this.validationErrors.activity_name 'error'}}"
                value={{this.formData.activity_name}}
                placeholder="请输入活动名称"
                {{on "input" (fn this.updateField "activity_name")}}
                maxlength="200"
              />
              {{#if this.validationErrors.activity_name}}
                <div class="validation-error">{{this.validationErrors.activity_name}}</div>
              {{/if}}
            </div>

            {{! 你的其他表单字段... }}
            {{! 为了简洁，我只展示一个字段，其他字段保持原样 }}

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
