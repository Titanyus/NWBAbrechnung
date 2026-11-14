import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { meterUrl: String }

  connect() {
    this.applyMode("customer")
    this.applyMode("connection")
    this.meterChanged()
  }

  modeChanged(event) {
    const group = event.target.dataset.group
    this.applyMode(group)
    if (group === "connection") this.refreshMeter()
  }

  applyMode(group) {
    const value = this.element.querySelector(`input[name="contract_draft[${group}_mode]"]:checked`)?.value
    this.element.querySelectorAll(`fieldset[data-draft-group="${group}"]`).forEach(fieldset => {
      fieldset.hidden = fieldset.dataset.draftChoice !== value
      fieldset.disabled = fieldset.hidden
    })
  }

  customerSelected(event) {
    this.element.querySelector("#draft_customer_selected").value = event.target.value
    this.element.querySelector("#draft-customer-search").requestSubmit()
  }

  connectionSelected(event) {
    this.element.querySelector("#draft_connection_selected").value = event.target.value
    this.element.querySelector("#draft-connection-search").requestSubmit()
    this.refreshMeter()
  }

  refreshMeter() {
    const previousChoice = this.element.querySelector("#draft_new_meter")
    if (previousChoice) {
      previousChoice.checked = false
      previousChoice.disabled = true
      this.meterChanged()
    }
    const url = new URL(this.meterUrlValue, location.origin)
    const mode = this.element.querySelector('input[name="contract_draft[connection_mode]"]:checked')?.value
    if (mode === "new") url.searchParams.set("new_connection", "1")
    else {
      const id = this.element.querySelector("#draft_connection_id")?.value
      if (id) url.searchParams.set("connection_id", id)
    }
    this.element.querySelector("#draft_meter").src = url.href
  }

  loaded(event) {
    if (event.target.id === "draft_meter") this.meterChanged()
  }

  meterChanged() {
    const fields = this.element.querySelector("fieldset[data-meter-fields]")
    if (!fields) return
    const enabled = this.element.querySelector("#draft_new_meter")?.checked
    fields.hidden = !enabled
    fields.disabled = !enabled
  }
}
