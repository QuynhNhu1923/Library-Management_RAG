// app/javascript/controllers/status_form_controller.js
import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static targets = [
    "statusSelect",
    "adminNoteField",
    "actualReturnDateField",
    "actualBorrowDateField",
    "approvedDateField",
    "errorMessage"
  ]

  connect() {
    this.tForm = I18n.t("admin.borrow_requests.status_form_js")
    this.toggleFields()
  }

  toggleFields() {
    const status = this.statusSelectTarget.value
    console.log("statusSelect.value =", status)

    this.hideAll()

    if (status === "rejected") {
      this.show(this.adminNoteFieldTarget)
    } else if (status === "returned") {
      this.show(this.actualReturnDateFieldTarget)
    } else if (status === "borrowed") {
      this.show(this.actualBorrowDateFieldTarget)
    } else if (status === "approved") {
      this.show(this.approvedDateFieldTarget)
    }
  }

  validateForm(event) {
    const status = this.statusSelectTarget.value
    const currentStatus = this.statusSelectTarget.dataset.currentStatus

    // Trường hợp rejected -> bắt buộc admin_note
    if (status === "rejected") {
      const noteField = this.adminNoteFieldTarget.querySelector("textarea, input")
      if (!noteField || noteField.value.trim() === "") {
        this.showError(this.tForm.error.admin_note_required)
        event.preventDefault()
        return
      }
    }

    // approved / borrowed / returned -> validate date
    let dateField
    if (status === "returned") {
      dateField = this.actualReturnDateFieldTarget.querySelector("input")
    } else if (status === "borrowed") {
      dateField = this.actualBorrowDateFieldTarget.querySelector("input")
    } else if (status === "approved") {
      dateField = this.approvedDateFieldTarget.querySelector("input")
    }

    this.clearError()
  }

  hideAll() {
    this.adminNoteFieldTarget.classList.add("d-none")
    this.actualReturnDateFieldTarget.classList.add("d-none")
    this.actualBorrowDateFieldTarget.classList.add("d-none")
    this.approvedDateFieldTarget.classList.add("d-none")
    this.clearError()
  }

  show(element) {
    element.classList.remove("d-none")
  }

  showError(message) {
    this.errorMessageTarget.textContent = message
    this.errorMessageTarget.classList.remove("d-none")
  }

  clearError() {
    this.errorMessageTarget.textContent = ""
    this.errorMessageTarget.classList.add("d-none")
  }
}
