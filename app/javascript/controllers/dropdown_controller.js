import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dropdown"
export default class extends Controller {
    connect() {
        // Tự động khởi tạo lại Bootstrap Dropdown khi HTML vừa xuất hiện
        if (typeof bootstrap !== 'undefined' && bootstrap.Dropdown) {
            const toggleEl = this.element.querySelector('[data-bs-toggle="dropdown"]')
            if (toggleEl) {
                this.dropdownInstance = bootstrap.Dropdown.getOrCreateInstance(toggleEl)
            }
        }
    }

    toggle(event) {
        // Ngăn chặn lỗi nhảy trang và ép menu bật/tắt thủ công nếu khởi tạo tự động lỗi
        if (this.dropdownInstance) {
            event.preventDefault()
            this.dropdownInstance.toggle()
        }
    }

    disconnect() {
        // Hủy instance khi rời trang để tránh rò rỉ bộ nhớ
        if (this.dropdownInstance) {
            this.dropdownInstance.dispose()
        }
    }
}