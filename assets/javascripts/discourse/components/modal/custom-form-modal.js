import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";

export default class CustomFormModal extends Component {
  @service modal;
  @tracked formTitle = "";
  @tracked formContent = "";
  @tracked formCategory = "general";
  @tracked isSubmitting = false;
  @tracked validationErrors = {};

  // 表单验证
  @action
  validateForm() {
    const errors = {};
    
    if (!this.formTitle.trim()) {
      errors.title = "标题不能为空";
    }
    
    if (!this.formContent.trim()) {
      errors.content = "内容不能为空";
    }
    
    this.validationErrors = errors;
    return Object.keys(errors).length === 0;
  }

  // 提交表单
  @action
  async submitForm() {
    if (!this.validateForm()) {
      return;
    }

    this.isSubmitting = true;

    try {
      // 构建要插入编辑器的内容
      const insertText = this.buildInsertText();
      
      // 获取工具栏事件并插入内容到编辑器
      const toolbarEvent = this.args.model.toolbarEvent;
      if (toolbarEvent && toolbarEvent.addText) {
        toolbarEvent.addText(insertText);
      }

      // 关闭模态框
      this.args.closeModal();
      
      // 可选：显示成功消息
      // this.appEvents.trigger("custom-form:submitted", { success: true });
      
    } catch (error) {
      console.error("提交表单时出错:", error);
      // 处理错误
    } finally {
      this.isSubmitting = false;
    }
  }

  // 构建插入文本
  buildInsertText() {
    let insertText = `## ${this.formTitle}\n\n`;
    insertText += `${this.formContent}\n\n`;
    insertText += `*分类: ${this.getCategoryDisplayName()}*\n\n`;
    return insertText;
  }

  // 获取分类显示名称
  getCategoryDisplayName() {
    const categories = {
      general: "常规",
      announcement: "公告",
      question: "问题", 
      tutorial: "教程"
    };
    return categories[this.formCategory] || "常规";
  }

  // 取消操作
  @action
  cancel() {
    this.args.closeModal();
  }

  // 重置表单
  @action
  resetForm() {
    this.formTitle = "";
    this.formContent = "";
    this.formCategory = "general";
    this.validationErrors = {};
  }

  // 处理输入更改
  @action
  updateTitle(event) {
    this.formTitle = event.target.value;
    // 清除相关验证错误
    if (this.validationErrors.title) {
      delete this.validationErrors.title;
      this.validationErrors = { ...this.validationErrors };
    }
  }

  @action
  updateContent(event) {
    this.formContent = event.target.value;
    // 清除相关验证错误
    if (this.validationErrors.content) {
      delete this.validationErrors.content;
      this.validationErrors = { ...this.validationErrors };
    }
  }

  @action
  updateCategory(event) {
    this.formCategory = event.target.value;
  }
}
