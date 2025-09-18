import { useState } from "discourse/widgets/hooks";
import DModal from "discourse/components/d-modal";
import DButton from "discourse/components/d-button";
import DModalCancel from "discourse/components/d-modal-cancel";

export default function LotteryFormModal({ closeModal }) {
  const [formData, setFormData] = useState({
    activity_name: "",
    prize_description: "",
    prize_image_url: "",
    draw_time: "",
    winner_count: 1,
    specific_floors: "",
    participation_threshold: 1,
    backup_strategy: "continue",
    additional_notes: "",
  });

  const [validationErrors, setValidationErrors] = useState({});
  const [isSubmitting, setIsSubmitting] = useState(false);

  const backupStrategyOptions = [
    { value: "continue", label: "继续抽奖直到找到有效参与者" },
    { value: "reduce", label: "减少获奖人数" },
    { value: "cancel", label: "取消抽奖" }
  ];

  function updateField(field) {
    return (e) => {
      setFormData({ ...formData, [field]: e.target.value });
      setValidationErrors({ ...validationErrors, [field]: undefined });
    };
  }

  function validateForm() {
    const errors = {};
    if (!formData.activity_name.trim()) errors.activity_name = "活动名称不能为空";
    if (!formData.prize_description.trim()) errors.prize_description = "奖品说明不能为空";
    if (!formData.draw_time) errors.draw_time = "开奖时间不能为空";
    else if (new Date(formData.draw_time) <= new Date()) errors.draw_time = "开奖时间必须是未来时间";
    if (formData.winner_count < 1) errors.winner_count = "获奖人数必须大于0";
    if (formData.participation_threshold < 0) errors.participation_threshold = "参与门槛不能小于0";
    return errors;
  }

  async function submitForm(e) {
    e?.preventDefault();
    if (isSubmitting) return;
    setIsSubmitting(true);

    const errors = validateForm();
    if (Object.keys(errors).length > 0) {
      setValidationErrors(errors);
      setIsSubmitting(false);
      return;
    }

    try {
      // 模拟 API 调用
      await new Promise((r) => setTimeout(r, 1000));
      // 关闭 modal 并告知已提交
      closeModal?.({ submitted: true });
    } catch (e) {
      // 失败反馈
      // 可以用 alert() 或 setValidationErrors({ general: '出错了' })
    } finally {
      setIsSubmitting(false);
    }
  }

  function resetForm() {
    setFormData({
      activity_name: "",
      prize_description: "",
      prize_image_url: "",
      draw_time: "",
      winner_count: 1,
      specific_floors: "",
      participation_threshold: 1,
      backup_strategy: "continue",
      additional_notes: "",
    });
    setValidationErrors({});
  }

  return (
    <DModal title="创建抽奖活动" closeModal={closeModal} class="lottery-form-modal">
      {{
        body: (
          <form onsubmit={submitForm} class="lottery-form-container">
            {/* 活动名称 */}
            <div class="form-group">
              <label class="form-label">
                活动名称 <span class="required">*</span>
              </label>
              <input
                type="text"
                class={`form-control${validationErrors.activity_name ? " error" : ""}`}
                value={formData.activity_name}
                placeholder="请输入活动名称"
                oninput={updateField("activity_name")}
                maxlength={200}
              />
              {validationErrors.activity_name && (
                <div class="validation-error">{validationErrors.activity_name}</div>
              )}
            </div>
            {/* 奖品说明 */}
            <div class="form-group">
              <label class="form-label">
                奖品说明 <span class="required">*</span>
              </label>
              <input
                type="text"
                class={`form-control${validationErrors.prize_description ? " error" : ""}`}
                value={formData.prize_description}
                placeholder="请描述奖品内容"
                oninput={updateField("prize_description")}
                maxlength={1000}
              />
              {validationErrors.prize_description && (
                <div class="validation-error">{validationErrors.prize_description}</div>
              )}
            </div>
            {/* 奖品图片 */}
            <div class="form-group">
              <label class="form-label">
                奖品图片 <span class="optional">(可选)</span>
              </label>
              <input
                type="url"
                class="form-control"
                value={formData.prize_image_url}
                placeholder="请输入图片URL"
                oninput={updateField("prize_image_url")}
              />
            </div>
            {/* 开奖时间 */}
            <div class="form-group">
              <label class="form-label">
                开奖时间 <span class="required">*</span>
              </label>
              <input
                type="datetime-local"
                class={`form-control${validationErrors.draw_time ? " error" : ""}`}
                value={formData.draw_time}
                oninput={updateField("draw_time")}
              />
              {validationErrors.draw_time && (
                <div class="validation-error">{validationErrors.draw_time}</div>
              )}
            </div>
            {/* 获奖人数 */}
            <div class="form-group">
              <label class="form-label">
                获奖人数 <span class="required">*</span>
              </label>
              <input
                type="number"
                class={`form-control${validationErrors.winner_count ? " error" : ""}`}
                value={formData.winner_count}
                min={1}
                oninput={updateField("winner_count")}
              />
              {validationErrors.winner_count && (
                <div class="validation-error">{validationErrors.winner_count}</div>
              )}
              <div class="form-help">
                这是随机抽奖时的获奖人数。如果您想按指定楼层开奖，请直接填写下面的“指定中奖楼层”项。
              </div>
            </div>
            {/* 指定中奖楼层 */}
            <div class="form-group">
              <label class="form-label">
                指定中奖楼层 <span class="optional">(可选)</span>
              </label>
              <input
                type="text"
                class="form-control"
                value={formData.specific_floors}
                placeholder="例如：8,18,28"
                oninput={updateField("specific_floors")}
              />
              <div class="form-help">
                （可选）填写此项将覆盖随机抽奖。请在此填写具体的楼层号，用英文逗号分隔，例如：8,18,28。
              </div>
            </div>
            {/* 参与门槛 */}
            <div class="form-group">
              <label class="form-label">
                参与门槛 <span class="required">*</span>
              </label>
              <input
                type="number"
                class={`form-control${validationErrors.participation_threshold ? " error" : ""}`}
                value={formData.participation_threshold}
                min={0}
                oninput={updateField("participation_threshold")}
              />
              {validationErrors.participation_threshold && (
                <div class="validation-error">{validationErrors.participation_threshold}</div>
              )}
              <div class="form-help">参与抽奖所需的最小楼层数</div>
            </div>
            {/* 后备策略 */}
            <div class="form-group">
              <label class="form-label">
                后备策略 <span class="required">*</span>
              </label>
              <select
                class="form-control"
                value={formData.backup_strategy}
                onchange={updateField("backup_strategy")}
              >
                {backupStrategyOptions.map((option) => (
                  <option value={option.value}>{option.label}</option>
                ))}
              </select>
            </div>
            {/* 补充说明 */}
            <div class="form-group">
              <label class="form-label">
                补充说明 <span class="optional">(可选)</span>
              </label>
              <textarea
                class="form-control"
                rows={3}
                placeholder="活动的额外说明..."
                value={formData.additional_notes}
                oninput={updateField("additional_notes")}
                maxlength={2000}
              />
            </div>
          </form>
        ),
        footer: (
          <>
            <DButton action={resetForm} disabled={isSubmitting} class="btn-default">
              重置
            </DButton>
            <DModalCancel close={closeModal} />
            <DButton type="submit" action={submitForm} disabled={isSubmitting} class="btn-primary">
              {isSubmitting ? "创建中..." : "创建抽奖"}
            </DButton>
          </>
        ),
      }}
    </DModal>
  );
}
