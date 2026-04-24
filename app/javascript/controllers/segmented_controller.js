import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.update()
  }

  update() {
    this.element.querySelectorAll("label").forEach(label => {
      const radio = label.querySelector("input[type=radio]")
      const btn = label.querySelector(".segmented-btn")
      if (btn) btn.classList.toggle("on", radio.checked)
    })
  }
}
