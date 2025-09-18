import { useForm } from "discourse/lib/form";
import DModal from "discourse/components/d-modal";
import DButton from "discourse/components/d-button";
import DModalCancel from "discourse/components/d-modal-cancel";

export default function LotteryFormModal(args, ctx) {
  const form = useForm({
    activity_name: "",
    prize_description: "",
    prize_image_url: "",
    draw_time: "",
    winner_count: 1,
    specific_floors: "",
    participation_threshold: 1,
    backup_strategy: "continue",
    additional_notes: ""
  });

  const backupStrategyOptions = [
    { value: "continue", label: "继续抽奖直到找到有效参与者" },
    { value: "reduce", label: "减少获奖人数" },
    { value: "cancel", label: "取消抽奖" }
  ];

  async function handleSubmit(e) {
    e.preventDefault();
    form.setSubmitting(true);
    try {
      // 提交逻辑
      args.closeModal();
    } catch (err) {
      // 错误处理
    } finally {
      form.setSubmitting(false);
    }
  }

  return <DModal title="创建抽奖活动" closeModal={args.closeModal}>
    {{
      body:
        <form onsubmit={handleSubmit}>
          <input
            type="text"
            value={form.data.activity_name}
            oninput={e => form.update("activity_name", e.target.value)}
            placeholder="请输入活动名称"
            required
            maxLength="200"
          />
          {/* 其他输入项同理，全部用 value/oninput 写 */}
          <select
            value={form.data.backup_strategy}
            onchange={e => form.update("backup_strategy", e.target.value)}
          >
            {backupStrategyOptions.map(option =>
              <option value={option.value}>{option.label}</option>
            )}
          </select>
          <textarea
            value={form.data.additional_notes}
            oninput={e => form.update("additional_notes", e.target.value)}
            maxLength="2000"
            placeholder="活动的额外说明..."
            rows={3}
          />
          {/* 其它控件... */}
          <DButton
            type="button"
            action={form.reset}
            disabled={form.submitting}
            class="btn-default"
          >重置</DButton>
          <DModalCancel close={args.closeModal} />
          <DButton
            type="submit"
            disabled={form.submitting}
            class="btn-primary"
          >{form.submitting ? "创建中..." : "创建抽奖"}</DButton>
        </form>,
    }}
  </DModal>;
}
