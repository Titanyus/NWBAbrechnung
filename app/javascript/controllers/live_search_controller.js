import { Controller } from "@hotwired/stimulus"

// One coordinator for every search form. Results remain server-rendered Turbo frames.
export default class extends Controller {
  connect() { this.searches = new Map() }

  disconnect() {
    this.searches.forEach(state => { clearTimeout(state.timer) })
  }

  searchForm(element) {
    const form = element.form || element.closest("form")
    return form?.hasAttribute("data-live-search") ? form : null
  }

  state(form) {
    const frame = form.dataset.turboFrame
    if (!this.searches.has(frame)) this.searches.set(frame, { version: 0 })
    return this.searches.get(frame)
  }

  input(event) {
    if (event.isComposing) return
    const form = this.searchForm(event.target)
    if (!form || !event.target.matches('input:not([type=hidden]):not([type=submit]),textarea')) return
    this.schedule(form, 300)
  }

  change(event) {
    const form = this.searchForm(event.target)
    if (form && event.target.matches('select,input[type=date],input[type=checkbox],input[type=radio]')) this.schedule(form, 0)
  }

  schedule(form, delay) {
    const state = this.state(form)
    state.version++
    clearTimeout(state.timer)
    state.timer = setTimeout(() => {
      if (form.isConnected && form.checkValidity()) form.requestSubmit()
    }, delay)
  }

  request(event) {
    const form = this.searchForm(event.target)
    if (!form) {
      // Explicit links such as reset/pagination supersede a pending text search.
      const state = this.searches.get(event.target.id)
      if (state) {
        clearTimeout(state.timer)
        state.version++
        state.requestVersion = state.version
        state.focus = null
        state.url = event.detail.url.href
      }
      return
    }
    const state = this.state(form)
    clearTimeout(state.timer)
    state.requestVersion = state.version
    state.url = event.detail.url.href
    state.formId = form.id
    const input = document.activeElement
    state.focus = input.form === form && input.id ? { id: input.id, start: input.selectionStart, end: input.selectionEnd } : null
  }

  response(event) {
    const form = this.searchForm(event.target)
    const state = this.searches.get(form?.dataset.turboFrame || event.target.id)
    const response = event.detail.fetchResponse.response
    const url = response.url
    if (state && response.redirected && new URL(url).origin === location.origin) {
      event.preventDefault()
      window.Turbo.visit(url)
      return
    }
    if (state && (state.requestVersion !== state.version || state.url !== url)) event.preventDefault()
  }

  beforeRender(event) {
    const state = this.searches.get(event.target.id)
    if (state && state.requestVersion !== state.version) event.detail.render = () => {}
  }

  afterRender(event) {
    const state = this.searches.get(event.target.id)
    if (!state || state.requestVersion !== state.version || !state.focus) return
    const active = document.activeElement
    if (active && active !== document.body && active !== document.documentElement && !event.target.contains(active)) return
    const field = document.getElementById(state.focus.id)
    if (field && field.form?.id === state.formId) {
      field.focus({ preventScroll: true })
      if (typeof state.focus.start === "number") field.setSelectionRange(state.focus.start, state.focus.end)
    }
  }
}
