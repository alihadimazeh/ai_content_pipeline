import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source", "button"]

  copy() {
    navigator.clipboard.writeText(this.sourceTarget.innerText).then(() => {
      const original = this.buttonTarget.innerText
      this.buttonTarget.innerText = "Copied!"
      setTimeout(() => { this.buttonTarget.innerText = original }, 2000)
    })
  }
}
