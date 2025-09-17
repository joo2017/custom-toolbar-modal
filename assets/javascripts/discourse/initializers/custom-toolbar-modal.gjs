import { withPluginApi } from "discourse/lib/plugin-api";
import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import DModal from "discourse/components/d-modal";
import DButton from "discourse/components/d-button";
import { on } from "@ember/modifier";  // 👈 关键：导入 on 修饰符
import { eq } from "truth-helpers";

// 定义模态框组件
class CustomFormModal extends Component {
  @service modal;
  @tracked formTitle = "";
  @tracked formContent = "";
  @tracked formCategory = "general";
  @tracked isSubmitting = false;
  @tracked validationErrors = {};

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

  @action
  async submitForm() {
    if (!this.validateForm()) {
      return;
    }

    this.isSubmitting = true;

    try {
      const insertText = this.buildInsertText();
      const toolbarEvent = this.args.model.toolbarEvent;
      
      if (toolbarEvent && toolbarEvent.addText) {
        toolbarEvent.addText(insertText);
      }

      this.args.closeModal();
      
    } catch (error) {
      console.error("提交表单时出错:", error);
    } finally {
      this.isSubmitting = false;
    }
  }

  buildInsertText() {
    let insertText = `## ${this.formTitle}\n\n`;
    insertText += `${this.formContent}\n\n`;
    insertText += `*分类: ${this.getCategoryDisplayName()}*\n\n`;
    return insertText;
  }

  getCategoryDisplayName() {
    const categories = {
      general: "常规",
      announcement: "公告",
      question: "问题", 
      tutorial: "教程"
    };
    return categories[this.formCategory] || "常规";
  }

  @action
  cancel() {
    this.args.closeModal();
  }

  @action
  resetForm() {
    this.formTitle = "";
    this.formContent = "";
    this.formCategory = "general";
    this.validationErrors = {};
  }

  @action
  updateTitle(event) {
    this.formTitle = event.target.value;
    if (this.validationErrors.title) {
      delete this.validationErrors.title;
      this.validationErrors = { ...this.validationErrors };
    }
  }

  @action
  updateContent(event) {
    this.formContent = event.target.value;
    if (this.validationErrors.content) {
      delete this.validationErrors.content;
      this.validationErrors = { ...this.validationErrors };
    }
  }

  @action
  updateCategory(event) {
    this.formCategory = event.target.value;
  }

  <template>
    <DModal 
      @title="自定义内容表单" 
      @closeModal={{@closeModal}} 
      class="custom-form-modal"
    >
      <:body>
        <div class="custom-form-container">
          {{! 标题输入 }}
          <div class="form-group">
            <label for="form-title" class="form-label">
              标题 <span class="required">*</span>
            </label>
            <input 
              type="text" 
              id="form-title"
              class="form-control {{if this.validationErrors.title 'error'}}"
              value={{this.formTitle}}
              placeholder="请输入标题..."
              {{on "input" this.updateTitle}}
              maxlength="100"
            />
            {{#if this.validationErrors.title}}
              <div class="validation-error">{{this.validationErrors.title}}</div>
            {{/if}}
          </div>

          {{! 分类选择 }}
          <div class="form-group">
            <label for="form-category" class="form-label">分类</label>
            <select 
              id="form-category"
              class="form-control"
              {{on "change" this.updateCategory}}
            >
              <option value="general" selected={{eq this.formCategory "general"}}>常规</option>
              <option value="announcement" selected={{eq this.formCategory "announcement"}}>公告</option>
              <option value="question" selected={{eq this.formCategory "question"}}>问题</option>
              <option value="tutorial" selected={{eq this.formCategory "tutorial"}}>教程</option>
            </select>
          </div>

          {{! 内容输入 }}
          <div class="form-group">
            <label for="form-content" class="form-label">
              内容 <span class="required">*</span>
            </label>
            <textarea 
              id="form-content"
              class="form-control {{if this.validationErrors.content 'error'}}"
              rows="6"
              placeholder="请输入内容..."
              {{on "input" this.updateContent}}
            >{{this.formContent}}</textarea>
            {{#if this.validationErrors.content}}
              <div class="validation-error">{{this.validationErrors.content}}</div>
            {{/if}}
            <div class="form-help">支持 Markdown 格式</div>
          </div>

          {{! 预览区域 }}
          {{#if (and this.formTitle this.formContent)}}
            <div class="form-group preview-section">
              <label class="form-label">预览</label>
              <div class="preview-content">
                <h3>{{this.formTitle}}</h3>
                <p>{{this.formContent}}</p>
                <small><em>分类: {{this.getCategoryDisplayName}}</em></small>
              </div>
            </div>
          {{/if}}
        </div>
      </:body>

      <:footer>
        <div class="modal-footer-buttons">
          {{! 重置按钮 }}
          <DButton 
            @action={{this.resetForm}}
            @disabled={{this.isSubmitting}}
            class="btn-default"
          >
            重置
          </DButton>

          {{! 取消按钮 }}
          <DButton 
            @action={{this.cancel}}
            @disabled={{this.isSubmitting}}
            class="btn-default"
          >
            取消
          </DButton>

          {{! 提交按钮 }}
          <DButton 
            @action={{this.submitForm}}
            @disabled={{or this.isSubmitting (not (and this.formTitle this.formContent))}}
            class="btn-primary"
          >
            {{#if this.isSubmitting}}
              提交中...
            {{else}}
              插入内容
            {{/if}}
          </DButton>
        </div>
      </:footer>
    </DModal>

    <style>
      .custom-form-modal {
        max-width: 600px;
      }

      .custom-form-container .form-group {
        margin-bottom: 1.5rem;
      }

      .custom-form-container .form-label {
        display: block;
        font-weight: bold;
        margin-bottom: 0.5rem;
        color: var(--primary);
      }

      .custom-form-container .required {
        color: var(--danger);
      }

      .custom-form-container .form-control {
        width: 100%;
        padding: 0.75rem;
        border: 1px solid var(--primary-low-mid);
        border-radius: 4px;
        background: var(--secondary);
        color: var(--primary);
        font-size: 14px;
      }

      .custom-form-container .form-control:focus {
        outline: none;
        border-color: var(--tertiary);
        box-shadow: 0 0 0 2px var(--tertiary-low);
      }

      .custom-form-container .form-control.error {
        border-color: var(--danger);
      }

      .custom-form-container .validation-error {
        color: var(--danger);
        font-size: 12px;
        margin-top: 0.25rem;
      }

      .custom-form-container .form-help {
        font-size: 12px;
        color: var(--primary-medium);
        margin-top: 0.25rem;
      }

      .custom-form-container .preview-section {
        border-top: 1px solid var(--primary-low);
        padding-top: 1rem;
      }

      .custom-form-container .preview-content {
        background: var(--primary-very-low);
        padding: 1rem;
        border-radius: 4px;
        border: 1px solid var(--primary-low);
      }

      .custom-form-container .preview-content h3 {
        margin: 0 0 0.5rem 0;
        color: var(--primary);
      }

      .custom-form-container .preview-content p {
        margin: 0 0 0.5rem 0;
      }

      .modal-footer-buttons {
        display: flex;
        gap: 0.5rem;
        justify-content: flex-end;
      }
    </style>
  </template>
}

// 初始化插件
function initializeCustomToolbarModal(api) {
  api.onToolbarCreate((toolbar) => {
    toolbar.addButton({
      id: "custom-form-modal-button",
      group: "extras",
      icon: "plus",
      title: "打开自定义表单",
      ariaLabel: "打开自定义表单",
      perform: (toolbarEvent) => {
        const modal = api.container.lookup("service:modal");
        modal.show(CustomFormModal, {
          model: {
            toolbarEvent: toolbarEvent,
          }
        });
      }
    });
  });
}

export default {
  name: "custom-toolbar-modal-initializer",
  
  initialize() {
    withPluginApi("1.8.0", initializeCustomToolbarModal);
  }
};
