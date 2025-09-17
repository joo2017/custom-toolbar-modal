// api-initializers/init-my-plugin.gjs
import { apiInitializer } from "discourse/lib/api";
import MyFormModal from "../components/my-form-modal";

export default apiInitializer((api) => {
  api.onToolbarCreate((toolbar) => {
    toolbar.addButton({
      id: "my-form-button",
      group: "extras",
      icon: "plus-circle",
      title: "my_plugin.toolbar.show_form",
      perform: (toolbarEvent) => {
        const modal = api.container.lookup("service:modal");
        modal.show(MyFormModal, {
          model: {
            toolbarEvent: toolbarEvent,
            insertText: toolbarEvent.addText,
            selectedText: toolbarEvent.getSelected()
          }
        });
      }
    });
  });
});
