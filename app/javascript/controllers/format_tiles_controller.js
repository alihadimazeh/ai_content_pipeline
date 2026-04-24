import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggle(event) {
    event.preventDefault()
    const tile = event.currentTarget
    const checkbox = tile.querySelector("input[type=checkbox]")
    const isChecked = tile.dataset.checked === "true"

    checkbox.checked = !isChecked
    tile.dataset.checked = (!isChecked).toString()
  }
}
