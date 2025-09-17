import { withPluginApi } from "discourse/lib/plugin-api";
import LotteryFormModal from "discourse/plugins/custom-toolbar-modal/discourse/components/lottery-form-modal";

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
            api.container.lookup("service:modal").show(LotteryFormModal);
          }
        });
      });
    });
  }
};
