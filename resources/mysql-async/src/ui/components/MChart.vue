<template>
  <canvas :id="id" :width="width" :height="height"></canvas>
</template>

<script>
import Chart from 'chart.js';

Chart.defaults.global.defaultFontFamily = "'Fira Sans', 'sans-serif'";

export default {
  data() {
    return {
      myChart: null,
    };
  },
  methods: {
    createChart(chartId) {
      const ctx = document.getElementById(chartId);
      this.myChart = new Chart(ctx, {
        type: this.type,
        data: {
          labels: this.labels,
          datasets: this.datasets,
        },
        options: {
          responsive: true,
          lineTension: 1,
          scales: {
            yAxes: [{
              ticks: {
                beginAtZero: true,
              },
            }],
          },
        }
      });
    },
    arraysEqual(a, b) {
      if (a === b) return true;
      if (a === null || b === null) return false;
      if (a.length != b.length) return false;

      for (var i = 0; i < a.length; ++i) {
        if (a[i] !== b[i]) return false;
      }
      return true;
    },
  },
  props: {
    id: {
      type: String,
      default: 'line-chart',
    },
    type: {
      type: String,
      default: 'line',
    },
    datasets: {
      type: Array,
      default: () => [],
    },
    labels: {
      type: Array,
      default: () => [],
    },
    height: {
      type: Number,
      default: 400,
    },
    width: {
      type: Number,
      default: 1600,
    },
  },
  mounted() {
    this.createChart(this.id);
  },
  watch: {
    datasets() {
      if (this.myChart) {
        this.myChart.data.datasets = this.datasets;
        this.myChart.update();
      }
    },
    labels() {
      if (this.myChart) {
        if (!this.arraysEqual(this.myChart.data.labels, this.labels)) {
          this.myChart.data.labels = this.labels;
          this.myChart.update(0);
        }
      }
    },
  },
}
</script>
