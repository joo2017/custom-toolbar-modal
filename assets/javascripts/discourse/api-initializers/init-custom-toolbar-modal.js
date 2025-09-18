// assets/javascripts/discourse/api-initializers/init-custom-toolbar-modal.js
import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "init-custom-toolbar-modal",
  initialize() {
    withPluginApi("0.8.31", (api) => {
      api.onToolbarCreate((toolbar) => {
        toolbar.addButton({
          title: "创建抽奖",
          id: "lottery-button",
          group: "extras", 
          icon: "gift",
          action: () => {
            // 修复：使用正确的服务获取方式
            const modalService = api.container.lookup("service:modal");
            const appEvents = api.container.lookup("service:app-events");
            
            // 导入模态框组件
            import("../components/lottery-form-modal").then((module) => {
              modalService.show(module.default, {
                model: {
                  appEvents,
                  toolbarEvent: toolbar
                }
              });
            }).catch((error) => {
              console.error("Failed to load lottery modal:", error);
            });
          }
        });
      });
    });
  }
};
