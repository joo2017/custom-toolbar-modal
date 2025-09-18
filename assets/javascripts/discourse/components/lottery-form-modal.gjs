// assets/javascripts/discourse/components/lottery-modal-wrapper.gjs
import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { on } from "@ember/modifier";
import { fn } from "@ember/helper";
import DModal from "discourse/components/d-modal";
import DButton from "discourse/components/d-button";
import DModalCancel from "discourse/components/d-modal-cancel";

export default class LotteryModalWrapper extends Component {
  @service appEvents;
  
  @tracked modalIsVisible = false;
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
    this.resetForm();
  }

  @action
  updateField(fieldName, event) {
    if (!event?.target) return;
    
    this.formData = {
      ...this.formData,
      [fieldName]: event.target.value
    };
    
    if (this.validationErrors[fieldName]) {
      this.validationErrors = {
        ...this.validationErrors,
        [fieldName]: null
      };
    }
  }

  @action
  async submitForm(event) {
    event?.preventDefault();
    
    if (this.isSubmitting) return;
    
    this.isSubmitting = true;
    this.validationErrors = {};
    
    try {
      const errors = this.validateForm();
      if (Object.keys(errors).length > 0) {
        this.validationErrors = errors;
        return;
      }

      console.log("提交数据:", this.formData);
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      this.closeModal();
      
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
    this.validationErrors = {};
  }

  validateForm() {
    const errors = {};
    
    if (!this.formData.activity_name?.trim()) {
      errors.activity_name = "活动名称不能为空";
    }
    
    if (!this.formData.prize_description?.trim()) {
      errors.prize_description = "奖品说明不能为空";
    }
    
    if (!this.formData.draw_time) {
      errors.draw_time = "开奖时间不能为空";
    } else {
      const drawTime = new Date(this.formData.draw_time);
      if (drawTime <= new Date()) {
        errors.draw_time = "开奖时间必须是未来时间";
      }
    }
    
    if (this.formData.winner_count < 1) {
      errors.winner_count = "获奖人数必须大于0";
    }
    
    return errors;
  }

  <template>
    {{#if this.modalIsVisible}}
      <DModal @title="创建抽奖活动" @closeModal={{this.closeModal}} class="lottery-form-modal">
        <:body>
          <div class="lottery-form-container">
            <form {{on "submit" this.submitForm}}>
              
              <div class="form-group">
                <label class="form-label">
                  活动名称 <span class="required">*</span>
                </label>
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

              <div class="form-group">
                <label class="form-label">
                  奖品说明 <span class="required">*</span>
                </label>
                <input
                  type="text"
                  class="form-control {{if this.validationErrors.prize_description 'error'}}"
                  value={{this.formData.prize_description}}
                  placeholder="请描述奖品内容"
                  {{on "input" (fn this.updateField "prize_description")}}
                  maxlength="1000"
                />
                {{#if this.validationErrors.prize_description}}
                  <div class="validation-error">{{this.validationErrors.prize_description}}</div>
                {{/if}}
              </div>

              <div class="form-group">
                <label class="form-label">
                  开奖时间 <span class="required">*</span>
                </label>
                <input
                  type="datetime-local"
                  class="form-control {{if this.validationErrors.draw_time 'error'}}"
                  value={{this.formData.draw_time}}
                  {{on "input" (fn this.updateField "draw_time")}}
                />
                {{#if this.validationErrors.draw_time}}
                  <div class="validation-error">{{this.validationErrors.draw_time}}</div>
                {{/if}}
              </div>

              <div class="form-group">
                <label class="form-label">
                  获奖人数 <span class="required">*</span>
                </label>
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
          <DButton
            @action={{this.resetForm}}
            @disabled={{this.isSubmitting}}
            class="btn-default"
            @translatedLabel="重置"
          />
          <DModalCancel @close={{this.closeModal}} />
          <DButton
            @action={{this.submitForm}}
            @disabled={{this.isSubmitting}}
            class="btn-primary"
            @translatedLabel={{if this.isSubmitting "创建中..." "创建抽奖"}}
          />
        </:footer>
      </DModal>
    {{/if}}
  </template>
}
