import { Application } from "@hotwired/stimulus"
const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }

// Global Utility: Configure default headers for Fetch API / Ajax calls
document.addEventListener("turbo:load", () => {
  const csrfMetaTag = document.querySelector("meta[name='csrf-token']");
  if (csrfMetaTag) {
    window.ajaxHeaders = {
      // REMOVED "Content-Type": "application/json" 
      // Setting a global JSON content type breaks standard FormData uploads.
      "Accept": "application/json",
      "X-CSRF-Token": csrfMetaTag.content
    };
  }
});