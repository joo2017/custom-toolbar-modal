import { withPluginApi } from "discourse/lib/plugin-api";
import { h } from "virtual-dom";

export default {
  name: "custom-toolbar-modal",

  initialize() {
    withPluginApi("0.12.0", api => {
      api.onToolbarCreate(toolbar => {
        toolbar.addButton({
          id: "custom_modal",
          group: "extras",
          icon: "plus", // 可替换成你喜欢的图标
          perform: () => {
            // 用 modal 服务弹出模态窗口
            import("discourse/components/custom-toolbar-modal").then(module => {
              const { default: CustomToolbarModal } = module;
              // 获取 modal service 并显示
              const container = api.container;
              const modalService = container.lookup("service:modal");
              modalService.show(CustomToolbarModal);
            });
          }
        });
      });
    });
  }
};
