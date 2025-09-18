// assets/javascripts/discourse/components/lottery-form-modal.gjs
import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { eq } from "truth-helpers";
import DModal from "discourse/components/d-modal";
import DButton from "discourse/components/d-button";
import DModalCancel from "discourse/components/d-modal-cancel";

export default class LotteryFormModal extends Component {
  @service modal;
  @service appEvents;
  
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

  constructor() {
    super(...arguments);
    // 确保模态框正确初始化
    this.appEvents = this.args.model?.appEvents || this.appEvents;
  }

  get backupStrategyOptions() {
    return [
      { value: "continue", label: "继续抽奖直到找到有效参与者" },
      { value: "reduce", label: "减少获奖人数" },
      { value: "cancel", label: "取消抽奖" }
    ];
  }

  @action
  updateField(fieldName, event) {
    if (!event?.target) return;
    
    this.formData = {
      ...this.formData,
      [fieldName]: event.target.value
    };
  }

  @action
  async submitForm(event) {
    event?.preventDefault();
    
    if (this.isSubmitting) return;
    
    this.isSubmitting = true;
    this.validationErrors = {};
    
    try {
      // 基础验证
      const errors = this.validateForm();
      if (Object.keys(errors).length > 0) {
        this.validationErrors = errors;
        return;
      }

      console.log("提交数据:", this.formData);
      
      // TODO: 实际的API调用
      // const response = await ajax('/lottery/events', {
      //   type: 'POST',
      //   data: { lottery_event: this.formData }
      // });
      
      // 模拟成功
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      this.appEvents.trigger("alert-display", {
        type: "success", 
        message: "抽奖活动创建成功！"
      });
      
      this.closeModal();
      
    } catch (error) {
      console.error("提交失败:", error);
      this.appEvents.trigger("alert-display", {
        type: "error",
        message: "创建失败，请重试"
      });
    } finally {
      this.isSubmitting = false;
    }
  }

  @action
  closeModal() {
    this.modal.close();
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
    <DModal 
      @title="创建抽奖活动" 
      @closeModal={{this.closeModal}} 
      class="lottery-form-modal"
    >
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
                奖品图片 <span class="optional">(可选)</span>
              </label>
              <input
                type="url"
                class="form-control"
                value={{this.formData.prize_image_url}}
                placeholder="请输入图片URL"
                {{on "input" (fn this.updateField "prize_image_url")}}
              />
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
                class="form-control {{if this.validationErrors.winner_count 'error'}}"
                value={{this.formData.winner_count}}
                min="1"
                {{on "input" (fn this.updateField "winner_count")}}
              />
              {{#if this.validationErrors.winner_count}}
                <div class="validation-error">{{this.validationErrors.winner_count}}</div>
              {{/if}}
              <div class="form-help">
                这是随机抽奖时的获奖人数。如果您想按指定楼层开奖，请直接填写下面的'指定中奖楼层'项。
              </div>
            </div>

            <div class="form-group">
              <label class="form-label">
                指定中奖楼层 <span class="optional">(可选)</span>
              </label>
              <input
                type="text"
                class="form-control"
                value={{this.formData.specific_floors}}
                placeholder="例如：8, 18, 28"
                {{on "input" (fn this.updateField "specific_floors")}}
              />
              <div class="form-help">
                （可选）填写此项将覆盖随机抽奖。请在此填写具体的楼层号，用英文逗号分隔，例如：8, 18, 28。
              </div>
            </div>

            <div class="form-group">
              <label class="form-label">
                参与门槛 <span class="required">*</span>
              </label>
              <input
                type="number"
                class="form-control"
                value={{this.formData.participation_threshold}}
                min="0"
                {{on "input" (fn this.updateField "participation_threshold")}}
              />
              <div class="form-help">参与抽奖所需的最小楼层数</div>
            </div>

            <div class="form-group">
              <label class="form-label">
                后备策略 <span class="required">*</span>
              </label>
              <select
                class="form-control"
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

            <div class="form-group">
              <label class="form-label">
                补充说明 <span class="optional">(可选)</span>
              </label>
              <textarea
                class="form-control"
                rows="3"
                placeholder="活动的额外说明..."
                {{on "input" (fn this.updateField "additional_notes")}}
                maxlength="2000"
              >{{this.formData.additional_notes}}</textarea>
            </div>
          </form>
        </div>
      </:body>

      <:footer>
        <DButton
          @action={{this.resetForm}}
          @disabled={{this.isSubmitting}}
          class="btn-default"
        >
          重置
        </DButton>

        <DModalCancel @close={{this.closeModal}} />

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
      </:footer>
    </DModal>
  </template>
}
