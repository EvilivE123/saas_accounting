import { Controller } from "@hotwired/stimulus"
// Import Chart.js
import Chart from 'chart.js/auto'

export default class extends Controller {
  static values = {
    type: String, // 'line', 'bar', 'doughnut'
    data: Object
  }

  connect() {
    this.renderChart()
  }

  disconnect() {
    if (this.chart) {
      this.chart.destroy()
    }
  }

  renderChart() {
    const ctx = this.element.getContext('2d')

    this.chart = new Chart(ctx, {
      type: this.typeValue,
      data: this.dataValue,
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            position: this.typeValue === 'doughnut' ? 'right' : 'top',
          }
        }
      }
    })
  }
}
