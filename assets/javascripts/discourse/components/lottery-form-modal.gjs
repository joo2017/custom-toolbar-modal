import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { hash } from "@ember/helper";
import DModal from "discourse/components/d-modal";
import DButton from "discourse/components/d-button";
import DModalCancel from "discourse/components/d-modal-cancel";
import Form from "discourse/components/form";

export default class LotteryFormModal extends Component {
  @tracked isSubmitting = false;

  get formData() {
    return {
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

  get backupStrategyOptions() {
    return [
      { value: "continue", label: "继续抽奖直到找到有效参与者" },
      { value: "reduce", label: "减少获奖人数" },
      { value: "cancel", label: "取消抽奖" }
    ];
  }

  @action
  async handleSubmit(data) {
    this.isSubmitting = true;
    
    try {
      console.log("提交数据:", data);
      // 这里添加你的提交逻辑
      
      // 提交成功后关闭模态框
      this.args.closeModal();
    } catch (error) {
      console.error("提交失败:", error);
    } finally {
      this.isSubmitting = false;
    }
  }

  <template>
    <DModal @title="创建抽奖活动" @closeModal={{@closeModal}}>
      <:body>
        <Form @data={{this.formData}} @onSubmit={{this.handleSubmit}} as |form|>
          
          <form.Field
            @name="activity_name"
            @title="活动名称"
            @validation="required"
            as |field|
          >
            <field.Input placeholder="请输入活动名称" maxlength="200" />
          </form.Field>

          <form.Field
            @name="prize_description"
            @title="奖品说明"
            @validation="required"
            as |field|
          >
            <field.Input placeholder="请描述奖品内容" maxlength="1000" />
          </form.Field>

          <form.Field
            @name="prize_image_url"
            @title="奖品图片"
            @description="(可选)"
            as |field|
          >
            <field.Input @type="url" placeholder="请输入图片URL" />
          </form.Field>

          <form.Field
            @name="draw_time"
            @title="开奖时间"
            @validation="required"
            as |field|
          >
            <field.Input @type="datetime-local" />
          </form.Field>

          <form.Field
            @name="winner_count"
            @title="获奖人数"
            @validation="required|integer"
            @helpText="这是随机抽奖时的获奖人数。如果您想按指定楼层开奖，请直接填写下面的'指定中奖楼层'项。"
            as |field|
          >
            <field.Input @type="number" min="1" />
          </form.Field>

          <form.Field
            @name="specific_floors"
            @title="指定中奖楼层"
            @description="(可选)"
            @helpText="填写此项将覆盖随机抽奖。请在此填写具体的楼层号，用英文逗号分隔，例如：8, 18, 28。"
            as |field|
          >
            <field.Input placeholder="例如：8, 18, 28" />
          </form.Field>

          <form.Field
            @name="participation_threshold"
            @title="参与门槛"
            @validation="required|integer"
            @helpText="参与抽奖所需的最小楼层数"
            as |field|
          >
            <field.Input @type="number" min="0" />
          </form.Field>

          <form.Field
            @name="backup_strategy"
            @title="后备策略"
            @validation="required"
            as |field|
          >
            <field.Select as |select|>
              {{#each this.backupStrategyOptions as |option|}}
                <select.Option @value={{option.value}}>
                  {{option.label}}
                </select.Option>
              {{/each}}
            </field.Select>
          </form.Field>

          <form.Field
            @name="additional_notes"
            @title="补充说明"
            @description="(可选)"
            as |field|
          >
            <field.Textarea 
              placeholder="活动的额外说明..." 
              maxlength="2000"
              @height={{120}}
            />
          </form.Field>

          <form.Actions>
            <DButton 
              @action={{form.reset}}
              @disabled={{this.isSubmitting}}
              class="btn-default"
            >
              重置
            </DButton>

            <DModalCancel @close={{@closeModal}} />

            <form.Submit @disabled={{this.isSubmitting}}>
              {{#if this.isSubmitting}}
                创建中...
              {{else}}
                创建抽奖
              {{/if}}
            </form.Submit>
          </form.Actions>

        </Form>
      </:body>
    </DModal>
  </template>
}
