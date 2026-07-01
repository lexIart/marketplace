import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["main", "thumb"]

  select(event) {
    this.mainTarget.src = event.currentTarget.dataset.src
    this.thumbTargets.forEach(t => {
      t.classList.remove("ring-2", "ring-gray-900", "ring-offset-1")
      t.classList.add("opacity-70")
    })
    event.currentTarget.classList.add("ring-2", "ring-gray-900", "ring-offset-1")
    event.currentTarget.classList.remove("opacity-70")
  }
}
