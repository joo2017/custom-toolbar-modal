import { withPluginApi } from "discourse/lib/plugin-api";
import CustomToolbarModal from "../components/custom-toolbar-modal"; // 注意相对路径

export default {
  name: "custom-toolbar-modal",
  initialize() {
    withPluginApi("0.12.0", api => {
      if (!api.container.lookup("site-settings:main").custom_toolbar_modal_enabled) return;

      api.onToolbarCreate(toolbar => {
        toolbar.addButton({
          id: "custom_modal",
          group: "extras",
          icon: "plus", // 改成任何喜欢的icon
          title: "Custom Modal",
          perform: () => {
            const modalService = api.container.lookup("service:modal");
            modalService.show(CustomToolbarModal);
          }
        });
      });
    });
  }
};
