import { LightningElement } from 'lwc';

export default class TestPath extends LightningElement {
  handleComplete() {
    const activeStage = this.template.querySelector(".stage.active");
    const nextStage = activeStage.nextElementSibling;

    if (nextStage && nextStage.classList.contains("stage")) {
      activeStage.classList.remove("active");
      nextStage.classList.add("active");
    }
  }

  connectedCallback() {
    this.template.addEventListener("click", (event) => {
      if (event.target.classList.contains("complete-button")) {
        this.handleComplete();
      }
    });
  }
}