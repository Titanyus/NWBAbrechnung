import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "detail"]
  static values = { url: String, query: Object }

  connect() {
    requestAnimationFrame(() => {
      this.listTarget.scrollTop = Number(this.listTarget.dataset.preservedScroll || 0)
      this.syncSelection()
    })
  }

  remember() { this.listTarget.dataset.preservedScroll = String(this.listTarget.scrollTop) }

  loaded(event) {
    if (event.target.id === "contract_detail") {
      this.deduplicate()
      this.detailTarget.scrollTop = 0
      this.syncSelection()
    } else if (event.target.id.startsWith("contracts_page_")) {
      this.deduplicate()
      this.syncSelection()
    }
  }

  deduplicate() {
    const seen = new Set()
    this.listTarget.querySelectorAll("[data-contract-item]").forEach(item => {
      if (seen.has(item.dataset.contractItem)) item.remove()
      else seen.add(item.dataset.contractItem)
    })
  }

  updated() { this.syncSelection() }

  syncSelection() {
    const record = this.detailTarget.querySelector("[data-contract-id]")
    if (!record) return
    const id = record.dataset.contractId
    this.listTarget.querySelectorAll("a[data-contract-id]").forEach(link => {
      if (link.dataset.contractId === id) link.setAttribute("aria-current", "page")
      else link.removeAttribute("aria-current")
    })
    this.element.querySelectorAll('input[name="selected_contract_id"]').forEach(input => { input.value = id })
    const row = this.listTarget.querySelector(`[data-contract-item="${CSS.escape(id)}"]`)
    if (row && record.dataset.contractName !== undefined) {
      row.querySelector("[data-row-name]").textContent = record.dataset.contractName
      row.querySelector("[data-row-meta]").textContent = record.dataset.contractMeta
      const badge = row.querySelector("[data-row-status] .status")
      badge.textContent = record.dataset.contractStatusLabel
      badge.className = `status status--${record.dataset.contractStatus === "active" ? "active" : "neutral"}`
    }
  }

  prepareLink(event) {
    const link = event.target.closest('a[data-turbo-frame="contract_detail"]')
    if (!link) return
    const url = new URL(link.href, location.origin)
    if (url.origin !== location.origin) return
    Object.entries(this.queryValue).forEach(([key, value]) => url.searchParams.set(key, value))
    if (url.pathname === this.urlValue + "/new") {
      const selected = this.detailTarget.querySelector("[data-contract-id]")?.dataset.contractId
      if (selected) url.searchParams.set("selected_contract_id", selected)
    }
    link.href = url.href
  }

  keyboard(event) {
    if (!["ArrowDown", "ArrowUp", "Home", "End"].includes(event.key)) return
    const current = event.target.closest("a[data-contract-id]")
    if (!current) return
    const links = [...this.listTarget.querySelectorAll("a[data-contract-id]")]
    const index = links.indexOf(current)
    const next = event.key === "Home" ? 0 : event.key === "End" ? links.length - 1 : Math.max(0, Math.min(links.length - 1, index + (event.key === "ArrowDown" ? 1 : -1)))
    event.preventDefault()
    links[next].focus()
  }
}
