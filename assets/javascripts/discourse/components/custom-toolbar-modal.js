import { withPluginApi } from "discourse/lib/plugin-api";
import CustomFormModal from "../components/modal/custom-form-modal";

function initializeCustomToolbarModal(api) {
  api.onToolbarCreate((toolbar) => {
    toolbar.addButton({
      id: "custom-form-modal-button",
      group: "extras", // 可选: "inline", "block", "extras"
      icon: "plus", // Font Awesome 图标名称
      title: "打开自定义表单", // 悬停提示文本
      ariaLabel: "打开自定义表单",
      perform: (toolbarEvent) => {
        // 获取模态框服务
        const modal = api.container.lookup("service:modal");
        
        // 显示模态框，传递工具栏事件以便后续操作
        modal.show(CustomFormModal, {
          model: {
            toolbarEvent: toolbarEvent, // 传递工具栏事件用于插入内容
          }
        });
      }
    });
  });
}

export default {
  name: "custom-toolbar-modal-initializer",
  
  initialize(container) {
    withPluginApi("1.8.0", initializeCustomToolbarModal);
  }
};
