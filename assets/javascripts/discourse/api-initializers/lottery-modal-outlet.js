// assets/javascripts/discourse/api-initializers/lottery-modal-outlet.js
import { withPluginApi } from "discourse/lib/plugin-api";
import LotteryModalWrapper from "discourse/plugins/custom-toolbar-modal/discourse/components/lottery-modal-wrapper";

export default {
  name: "lottery-modal-outlet",
  initialize() {
    withPluginApi("0.8.31", (api) => {
      api.renderInOutlet("above-main-container", LotteryModalWrapper);
    });
  }
};
