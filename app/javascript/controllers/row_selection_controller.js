import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["row", "edit", "selected"]

  select(event) {
    const row = event.target.closest("tr[data-edit-url]")
    if (!row || (event.type === "click" && event.target.closest("a,button,input[type=submit],form"))) return
    const radio = row.querySelector('input[type=radio]')
    radio.checked = true
    this.rowTargets.forEach(item => item.setAttribute("aria-selected", String(item === row)))
    this.selectedTargets.forEach(input => { input.value = radio.value })
    if (this.hasEditTarget) {
      this.editTarget.href = row.dataset.editUrl
      this.editTarget.setAttribute("aria-disabled", "false")
      this.editTarget.tabIndex = 0
    }
  }

  keyboard(event) {
    if (!["ArrowUp", "ArrowDown"].includes(event.key) || event.target.type !== "radio") return
    event.preventDefault()
    const radios = this.rowTargets.map(row => row.querySelector('input[type=radio]'))
    const index = radios.indexOf(event.target)
    const next = radios[Math.max(0, Math.min(radios.length - 1, index + (event.key === "ArrowDown" ? 1 : -1)))]
    next.focus()
    next.click()
  }
}
