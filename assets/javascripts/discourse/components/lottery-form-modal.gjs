// discourse/plugins/xxx/discourse/components/lottery-form-modal.gjs
import DModal from "discourse/components/d-modal";
import DButton from "discourse/components/d-button";
import DModalCancel from "discourse/components/d-modal-cancel";
import { useModal } from "discourse/lib/modal";
import { tracked } from "@glimmer/tracking";

export default function LotteryFormModal(args, ctx) {
  const modal = useModal(ctx);

  class State {
    @tracked formData = { /* ... */ };
    @tracked isSubmitting = false;
  }
  const state = new State();

  function updateField(name, e) {
    state.formData = { ...state.formData, [name]: e.target.value };
  }
  function submitForm(e) { /* ... */ }
  function resetForm() { /* ... */ }

  const backupStrategyOptions = [
    { value: "continue", label: "继续抽奖直到找到有效参与者" },
    { value: "reduce", label: "减少获奖人数" },
    { value: "cancel", label: "取消抽奖" }
  ];

  return <DModal title="创建抽奖活动" closeModal={modal.close}>
    {{
      body: <form onsubmit={submitForm}>
        <input
          type="text"
          value={state.formData.activity_name}
          oninput={e => updateField("activity_name", e)}
        />
        {/* 其余控件同理 */}
        <select
          value={state.formData.backup_strategy}
          onchange={e => updateField("backup_strategy", e)}
        >
          {backupStrategyOptions.map(option =>
            <option value={option.value}>{option.label}</option>
          )}
        </select>
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
