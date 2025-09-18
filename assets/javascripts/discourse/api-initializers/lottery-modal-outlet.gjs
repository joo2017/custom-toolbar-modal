// assets/javascripts/discourse/api-initializers/lottery-modal-outlet.gjs
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
        @tracked toolbarEvent = null;
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
        showModal(data) {
          this.toolbarEvent = data.toolbarEvent;
          this.modalIsVisible = true;
        }

        @action
        closeModal() {
          this.modalIsVisible = false;
          this.resetForm();
        }

        @action
        updateField(fieldName, event) {
          this.formData = {
            ...this.formData,
            [fieldName]: event.target.value
          };
          
          // 清除字段错误
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
            // 前端验证
            const errors = this.validateForm();
            if (Object.keys(errors).length > 0) {
              this.validationErrors = errors;
              return;
            }

            console.log("提交数据:", this.formData);
            
            // 构建并插入BBCode
            const lotteryBBCode = this.buildLotteryBBCode();
            
            if (this.toolbarEvent && this.toolbarEvent.addText) {
              this.toolbarEvent.addText(lotteryBBCode);
            }
            
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
          
          if (this.formData.participation_threshold < 0) {
            errors.participation_threshold = "参与门槛不能小于0";
          }
          
          return errors;
        }

        buildLotteryBBCode() {
          const params = [];
          
          if (this.formData.activity_name) {
            params.push(`name="${this.formData.activity_name}"`);
          }
          if (this.formData.prize_description) {
            params.push(`prize="${this.formData.prize_description}"`);
          }
          if (this.formData.prize_image_url) {
            params.push(`image="${this.formData.prize_image_url}"`);
          }
          if (this.formData.draw_time) {
            params.push(`draw-time="${this.formData.draw_time}"`);
          }
          if (this.formData.winner_count) {
            params.push(`winner-count="${this.formData.winner_count}"`);
          }
          if (this.formData.specific_floors) {
            params.push(`floors="${this.formData.specific_floors}"`);
          }
          if (this.formData.participation_threshold) {
            params.push(`threshold="${this.formData.participation_threshold}"`);
          }
          if (this.formData.backup_strategy) {
            params.push(`strategy="${this.formData.backup_strategy}"`);
          }
          if (this.formData.additional_notes) {
            params.push(`notes="${this.formData.additional_notes}"`);
          }
          
          return `[lottery ${params.join(' ')}]\n[/lottery]`;
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
                        class="form-control {{if this.validationErrors.participation_threshold 'error'}}"
                        value={{this.formData.participation_threshold}}
                        min="0"
                        {{on "input" (fn this.updateField "participation_threshold")}}
                      />
                      {{#if this.validationErrors.participation_threshold}}
                        <div class="validation-error">{{this.validationErrors.participation_threshold}}</div>
                      {{/if}}
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
                            selected={{if (eq this.formData.backup_strategy option.value) "selected"}}
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
          {{/if}}
        </template>
      });
    });
  }
};
