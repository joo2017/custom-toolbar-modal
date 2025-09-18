// assets/javascripts/discourse/api-initializers/init-custom-toolbar-modal.js
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
            const modalService = api.container.lookup("service:modal");
            modalService.show(LotteryFormModal, {
              model: {
                toolbarEvent: toolbar
              }
            });
          }
        });
      });
    });
  }
};
