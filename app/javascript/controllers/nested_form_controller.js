import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["template"]
  static values = { wrapperSelector: String }

  add(e) {
    e.preventDefault()
    const content = this.templateTarget.innerHTML
    const newId = new Date().getTime()
    const newContent = content.replace(/NEW_RECORD/g, newId)
    this.templateTarget.insertAdjacentHTML('beforebegin', newContent)
    this.dispatch("added")
  }

  remove(e) {
    e.preventDefault()
    const wrapper = e.target.closest(this.wrapperSelectorValue)
    if (wrapper.dataset.newRecord === "true") {
      wrapper.remove()
    } else {
      wrapper.style.display = 'none'
      const hiddenInput = wrapper.querySelector("input[name*='_destroy']")
      if (hiddenInput) hiddenInput.value = "1"
    }
    this.dispatch("removed")
  }
}
