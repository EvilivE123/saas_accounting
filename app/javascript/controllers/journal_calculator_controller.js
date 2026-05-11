import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["totalDebit", "totalCredit", "statusBadge", "submitButton"]

  connect() {
    this.calculate()
    
    // Listen to additions/removals from the nested_form_controller
    this.element.addEventListener("nested-form:added", this.calculate.bind(this))
    this.element.addEventListener("nested-form:removed", this.calculate.bind(this))
  }

  calculate() {
    let debits = 0.0
    let credits = 0.0

    // Sum all visible debit inputs
    this.element.querySelectorAll('.debit-input').forEach(input => {
      if (input.closest('.nested-form-wrapper').style.display !== 'none') {
        debits += parseFloat(input.value) || 0
      }
    })

    // Sum all visible credit inputs
    this.element.querySelectorAll('.credit-input').forEach(input => {
      if (input.closest('.nested-form-wrapper').style.display !== 'none') {
        credits += parseFloat(input.value) || 0
      }
    })

    // Format and display to 2 decimal places
    const formattedDebits = debits.toFixed(2)
    const formattedCredits = credits.toFixed(2)

    this.totalDebitTarget.textContent = formattedDebits
    this.totalCreditTarget.textContent = formattedCredits

    // Validate the Accounting Equation
    if (formattedDebits === formattedCredits && debits > 0) {
      this.statusBadgeTarget.textContent = "Balanced"
      this.statusBadgeTarget.className = "badge bg-success"
      this.submitButtonTarget.disabled = false
    } else {
      this.statusBadgeTarget.textContent = "Unbalanced"
      this.statusBadgeTarget.className = "badge bg-danger"
      this.submitButtonTarget.disabled = true
    }
  }

  // Handle the Ajax Form Submission
  async submitAjax(event) {
    event.preventDefault()
    
    // Disable UI during submission
    this.submitButtonTarget.disabled = true
    this.submitButtonTarget.innerHTML = `<span class="spinner-border spinner-border-sm"></span> Processing...`
    document.getElementById("ajax-errors").innerHTML = ""

    const form = this.element
    const formData = new FormData(form) // Keep it as raw FormData

    try {
      const response = await fetch(form.action, {
        method: 'POST',
        headers: {
          "Accept": "application/json",
          "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
        },
        body: formData // Fetch will automatically set the correct Multipart boundary headers!
      })

      const result = await response.json()

      if (response.ok && result.success) {
        window.location.href = result.data.redirect_url
      } else {
        this.showErrors(result.errors)
        this.resetButton()
      }
    } catch (error) {
      this.showErrors(["A network error occurred. Please try again."])
      this.resetButton()
    }
  }

  showErrors(errors) {
    const errorContainer = document.getElementById("ajax-errors")
    errorContainer.innerHTML = errors.join("<br>")
  }

  resetButton() {
    this.submitButtonTarget.disabled = false
    this.submitButtonTarget.innerHTML = "Post Entry"
  }
}