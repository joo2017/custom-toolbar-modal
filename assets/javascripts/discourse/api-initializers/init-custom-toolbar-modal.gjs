// assets/javascripts/discourse/api-initializers/init-custom-toolbar-modal.gjs
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";

class LotteryFormModal extends Component {
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
    { value: "continue", label: "当开奖时人数不足，继续开奖" },
    { value: "cancel", label: "当开奖时人数不足，取消活动" }
  ];

  @action
  async submitForm(event) {
    event?.preventDefault();
    
    if (!this.validateForm()) return;
    
    this.isSubmitting = true;
    
    try {
      const toolbarEvent = this.args.model.toolbarEvent;
      const postId = this.extractPostId(toolbarEvent);
      
      const response = await ajax("/lottery_events", {
        type: "POST",
        data: {
          post_id: postId,
          lottery_event: this.formData
        }
      });
      
      // 刷新帖子内容
      if (toolbarEvent && toolbarEvent.refreshPost) {
        toolbarEvent.refreshPost();
      }
      
      this.args.closeModal({ success: true, lottery_event: response });
      
    } catch (error) {
      this.handleError(error);
    } finally {
      this.isSubmitting = false;
    }
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
    } else if (new Date(this.formData.draw_time) <= new Date()) {
      errors.draw_time = "开奖时间必须是未来时间";
    }
    
    if (!this.formData.winner_count || this.formData.winner_count < 1) {
      errors.winner_count = "获奖人数必须大于0";
    }
    
    if (this.formData.participation_threshold < 0) {
      errors.participation_threshold = "参与门槛不能为负数";
    }
    
    this.validationErrors = errors;
    return Object.keys(errors).length === 0;
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

            {{! 奖品说明 }}
            <div class="form-group">
              <label class="form-label">奖品说明 <span class="required">*</span></label>
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

            {{! 奖品图片 }}
            <div class="form-group">
              <label class="form-label">奖品图片 <span class="optional">(可选)</span></label>
              <input 
                type="url"
                class="form-control"
                value={{this.formData.prize_image_url}}
                placeholder="请输入图片URL"
                {{on "input" (fn this.updateField "prize_image_url")}}
              />
            </div>

            {{! 开奖时间 }}
            <div class="form-group">
              <label class="form-label">开奖时间 <span class="required">*</span></label>
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

            {{! 获奖人数 }}
            <div class="form-group">
              <label class="form-label">获奖人数 <span class="required">*</span></label>
              <input 
                type="number"
                class="form-control {{if this.validationErrors.winner_count 'error'}}"
                value={{this.formData.winner_count}}
                min="1"
                {{on "input" (fn this.updateField "winner_count")}}
              />
              <div class="form-help">这是随机抽奖时的获奖人数。如果您想按指定楼层开奖，请直接填写下面的'指定中奖楼层'项。</div>
              {{#if this.validationErrors.winner_count}}
                <div class="validation-error">{{this.validationErrors.winner_count}}</div>
              {{/if}}
            </div>

            {{! 指定中奖楼层 }}
            <div class="form-group">
              <label class="form-label">指定中奖楼层 <span class="optional">(可选)</span></label>
              <input 
                type="text"
                class="form-control"
                value={{this.formData.specific_floors}}
                placeholder="例如：8, 18, 28"
                {{on "input" (fn this.updateField "specific_floors")}}
              />
              <div class="form-help">（可选）填写此项将覆盖随机抽奖。请在此填写具体的楼层号，用英文逗号分隔，例如：8, 18, 28。</div>
            </div>

            {{! 参与门槛 }}
            <div class="form-group">
              <label class="form-label">参与门槛 <span class="required">*</span></label>
              <input 
                type="number"
                class="form-control {{if this.validationErrors.participation_threshold 'error'}}"
                value={{this.formData.participation_threshold}}
                min="0"
                {{on "input" (fn this.updateField "participation_threshold")}}
              />
              <div class="form-help">参与抽奖所需的最小楼层数</div>
            </div>

            {{! 后备策略 }}
            <div class="form-group">
              <label class="form-label">后备策略 <span class="required">*</span></label>
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

            {{! 补充说明 }}
            <div class="form-group">
              <label class="form-label">补充说明 <span class="optional">(可选)</span></label>
              <textarea 
                class="form-control"
                rows="3"
                value={{this.formData.additional_notes}}
                placeholder="活动的额外说明..."
                {{on "input" (fn this.updateField "additional_notes")}}
                maxlength="2000"
              ></textarea>
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
