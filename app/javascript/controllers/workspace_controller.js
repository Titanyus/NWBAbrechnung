import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { focusSection: String }
  connect() {
    this.dispatch("changed")
    if (this.focusSectionValue) this.element.querySelector(`#${CSS.escape(this.focusSectionValue)}`)?.focus({ preventScroll: true })
  }
}
