import { Controller } from "@hotwired/stimulus"

const STORAGE_KEY = "nwb.appearance.v1"
const PRESETS = {
  billenhausen: { light: "#cea449", dark: "#cea449" },
  emerald: { light: "#146b55", dark: "#6ee7b7" },
  ocean: { light: "#1d4ed8", dark: "#93c5fd" },
  slate: { light: "#475569", dark: "#cbd5e1" }
}
const HEX = /^#[0-9a-f]{6}$/i
const rgb = (hex) => hex.slice(1).match(/../g).map((value) => parseInt(value, 16))
const luminance = (hex) => rgb(hex).map((channel) => {
  const value = channel / 255
  return value <= 0.04045 ? value / 12.92 : ((value + 0.055) / 1.055) ** 2.4
}).reduce((sum, value, index) => sum + value * [0.2126, 0.7152, 0.0722][index], 0)
const contrast = (a, b) => {
  const values = [luminance(a), luminance(b)].sort((x, y) => y - x)
  return (values[0] + 0.05) / (values[1] + 0.05)
}

export default class extends Controller {
  static targets = ["preset", "mode", "accent", "status"]

  connect() {
    this.state = { preset: "billenhausen", mode: "light", accent: null }
    try {
      const saved = JSON.parse(localStorage.getItem(STORAGE_KEY))
      if (saved && Object.hasOwn(PRESETS, saved.preset)) this.state.preset = saved.preset
      if (saved && ["light", "dark"].includes(saved.mode)) this.state.mode = saved.mode
      if (saved && typeof saved.accent === "string" && HEX.test(saved.accent)) this.state.accent = saved.accent
    } catch { /* Storage can be unavailable; the default still works. */ }
    this.apply()
  }

  changePreset() {
    this.state.preset = this.presetTarget.value
    this.state.accent = null
    this.save()
  }

  changeMode() {
    this.state.mode = this.modeTarget.value
    this.save()
  }

  changeAccent() {
    if (!HEX.test(this.accentTarget.value)) return
    this.state.accent = this.accentTarget.value
    this.save()
  }

  reset() {
    this.state = { preset: "billenhausen", mode: "light", accent: null }
    this.save()
  }

  save() {
    this.apply()
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(this.state))
      if (this.hasStatusTarget) this.statusTarget.textContent = "Darstellung in diesem Browser gespeichert."
    } catch {
      if (this.hasStatusTarget) this.statusTarget.textContent = "Darstellung aktiv. Dieser Browser erlaubt keine dauerhafte Speicherung."
    }
  }

  apply() {
    const root = document.documentElement
    root.dataset.colorMode = this.state.mode
    root.dataset.colorPreset = this.state.preset
    const accent = this.state.accent || PRESETS[this.state.preset][this.state.mode]
    const text = contrast(accent, "#ffffff") >= contrast(accent, "#000000") ? "#ffffff" : "#000000"
    root.style.removeProperty("--page")
    let computed = getComputedStyle(root)
    if (this.state.mode === "light") {
      const surface = rgb(computed.getPropertyValue("--surface").trim())
      const ink = rgb(computed.getPropertyValue("--text").trim())
      const page = "#" + surface.map((channel, index) => Math.round(channel * 0.92 + ink[index] * 0.08).toString(16).padStart(2, "0")).join("")
      root.style.setProperty("--page", page)
      computed = getComputedStyle(root)
    }
    const backgrounds = ["--page", "--surface"].map((name) => computed.getPropertyValue(name).trim())
    const destination = this.state.mode === "dark" ? 255 : 0
    let link = accent
    // Move only the text/link color until it contrasts with both page surfaces.
    for (let step = 1; step <= 100 && backgrounds.some((bg) => contrast(link, bg) < 4.5); step++) {
      link = "#" + rgb(accent).map((channel) => Math.round(channel + (destination - channel) * step / 100).toString(16).padStart(2, "0")).join("")
    }
    root.style.setProperty("--accent", accent)
    root.style.setProperty("--accent-text", text)
    root.style.setProperty("--link", link)
    root.style.setProperty("--focus", link)
    if (this.hasPresetTarget) this.presetTarget.value = this.state.preset
    if (this.hasModeTarget) this.modeTarget.value = this.state.mode
    if (this.hasAccentTarget) this.accentTarget.value = accent
  }
}
