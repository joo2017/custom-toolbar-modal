import { withPluginApi } from "discourse/lib/plugin-api";
import LotteryFormModal from "../components/lottery-form-modal";

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
            // 使用现代模态框API
            api.container.lookup("service:modal").show(LotteryFormModal);
          }
        });
      });
    });
  }
};
