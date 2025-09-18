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
            const appEvents = api.container.lookup("service:app-events");
            appEvents.trigger("lottery:show-modal", {
              toolbarEvent: toolbar
            });
          }
        });
      });
    });
  }
};
