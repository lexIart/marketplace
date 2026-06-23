import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  addRow() {
    const index = Date.now()
    const html = `<div class="spec-row">
      <input type="text" placeholder="Название" data-action="input->specifications#syncName" data-index="${index}">
      <input type="text" name="product[specifications][__new_${index}]" placeholder="Значение" data-value-for="${index}">
      <button type="button" data-action="click->specifications#removeRow">Удалить</button>
    </div>`
    this.containerTarget.insertAdjacentHTML("beforeend", html)
  }

  syncName(event) {
    const index = event.target.dataset.index
    const valueInput = this.containerTarget.querySelector(`[data-value-for="${index}"]`)
    if (valueInput) {
      valueInput.name = `product[specifications][${event.target.value}]`
    }
  }

  removeRow(event) {
    event.target.closest(".spec-row").remove()
  }
}
