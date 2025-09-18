// assets/javascripts/discourse/components/lottery-form-modal.gjs
import { tracked } from "@glimmer/tracking";
import DModal from "discourse/components/d-modal";
import DButton from "discourse/components/d-button";
import DModalCancel from "discourse/components/d-modal-cancel";
import { useModal } from "discourse/lib/modal";

export default function LotteryFormModal(args, ctx) {
  const modal = useModal(ctx);

  class State {
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
    @tracked isSubmitting = false;
  }
  const state = new State();

  function updateField(name, e) {
    state.formData = { ...state.formData, [name]: e.target.value };
  }

  async function submitForm(e) {
    e?.preventDefault?.();
    state.isSubmitting = true;
    try {
      // TODO: 这里添加你的提交逻辑
      modal.close();
    } catch (err) {
      // 错误处理
    } finally {
      state.isSubmitting = false;
    }
  }

  function resetForm() {
    state.formData = {
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

  const backupStrategyOptions = [
    { value: "continue", label: "继续抽奖直到找到有效参与者" },
    { value: "reduce", label: "减少获奖人数" },
    { value: "cancel", label: "取消抽奖" }
  ];

  return <DModal title="创建抽奖活动" closeModal={modal.close}>
    {{
      body: <form onsubmit={submitForm}>
        <div class="form-group">
          <label>活动名称 *</label>
          <input
            type="text"
            value={state.formData.activity_name}
            oninput={e => updateField("activity_name", e)}
            maxlength="200"
            placeholder="请输入活动名称"
          />
        </div>
        <div class="form-group">
          <label>奖品说明 *</label>
          <input
            type="text"
            value={state.formData.prize_description}
            oninput={e => updateField("prize_description", e)}
            maxlength="1000"
            placeholder="请描述奖品内容"
          />
        </div>
        <div class="form-group">
          <label>奖品图片(可选)</label>
          <input
            type="url"
            value={state.formData.prize_image_url}
            oninput={e => updateField("prize_image_url", e)}
            placeholder="请输入图片URL"
          />
        </div>
        <div class="form-group">
          <label>开奖时间 *</label>
          <input
            type="datetime-local"
            value={state.formData.draw_time}
            oninput={e => updateField("draw_time", e)}
          />
        </div>
        <div class="form-group">
          <label>获奖人数 *</label>
          <input
            type="number"
            value={state.formData.winner_count}
            min="1"
            oninput={e => updateField("winner_count", e)}
          />
          <div class="form-help">这是随机抽奖时的获奖人数。如果您想按指定楼层开奖，请直接填写下面的'指定中奖楼层'项。</div>
        </div>
        <div class="form-group">
          <label>指定中奖楼层(可选)</label>
          <input
            type="text"
            value={state.formData.specific_floors}
            oninput={e => updateField("specific_floors", e)}
            placeholder="例如：8, 18, 28"
          />
          <div class="form-help">填写此项将覆盖随机抽奖。请在此填写具体的楼层号，用英文逗号分隔，例如：8, 18, 28。</div>
        </div>
        <div class="form-group">
          <label>参与门槛 *</label>
          <input
            type="number"
            value={state.formData.participation_threshold}
            min="0"
            oninput={e => updateField("participation_threshold", e)}
          />
          <div class="form-help">参与抽奖所需的最小楼层数</div>
        </div>
        <div class="form-group">
          <label>后备策略 *</label>
          <select
            value={state.formData.backup_strategy}
            onchange={e => updateField("backup_strategy", e)}
          >
            {backupStrategyOptions.map(({ value, label }) =>
              <option
                value={value}
                selected={state.formData.backup_strategy === value}
              >{label}</option>
            )}
          </select>
        </div>
        <div class="form-group">
          <label>补充说明(可选)</label>
          <textarea
            rows="3"
            maxlength="2000"
            value={state.formData.additional_notes}
            oninput={e => updateField("additional_notes", e)}
            placeholder="活动的额外说明..."
          />
        </div>
      </form>,
      footer: <>
        <DButton action={resetForm} disabled={state.isSubmitting} class="btn-default">重置</DButton>
        <DModalCancel close={modal.close} />
        <DButton action={submitForm} disabled={state.isSubmitting} class="btn-primary">
          {state.isSubmitting ? "创建中..." : "创建抽奖"}
        </DButton>
      </>
    }}
  </DModal>;
}
