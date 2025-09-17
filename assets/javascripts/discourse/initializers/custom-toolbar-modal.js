import { withPluginApi } from "discourse/lib/plugin-api";

function initializeCustomToolbarModal(api) {
  // 动态导入模态框组件，使用相对路径
  const loadModal = async () => {
    try {
      // 使用动态导入来避免路径问题
      const { default: CustomFormModal } = await import("../components/modal/custom-form-modal");
      return CustomFormModal;
    } catch (error) {
      console.error("Failed to load custom form modal:", error);
      return null;
    }
  };

  api.onToolbarCreate((toolbar) => {
    toolbar.addButton({
      id: "custom-form-modal-button",
      group: "extras",
      icon: "plus",
      title: "打开自定义表单",
      ariaLabel: "打开自定义表单",
      perform: async (toolbarEvent) => {
        try {
          const CustomFormModal = await loadModal();
          if (!CustomFormModal) {
            console.error("Custom form modal not loaded");
            return;
          }

          const modal = api.container.lookup("service:modal");
          modal.show(CustomFormModal, {
            model: {
              toolbarEvent: toolbarEvent,
            }
          });
        } catch (error) {
          console.error("Error showing modal:", error);
        }
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
