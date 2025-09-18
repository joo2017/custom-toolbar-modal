// discourse/plugins/your-plugin/discourse/components/lottery-form-modal.gjs
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
      additional_notes: "",
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
    // ...你的提交逻辑...
    modal.close();
    state.isSubmitting = false;
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
      additional_notes: "",
    };
  }

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
        {/* ...同理其它表单项 ... */}
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
