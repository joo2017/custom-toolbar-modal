import { apiInitializer } from "discourse/lib/api";
import LotteryFormModal from "../components/lottery-form-modal";

export default apiInitializer("0.8.31", (api) => {
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
