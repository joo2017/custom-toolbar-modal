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
            // 动态导入组件
            import("../components/lottery-form-modal").then((module) => {
              api.container.lookup("service:modal").show(module.default);
            });
          }
        });
      });
    });
  }
};
