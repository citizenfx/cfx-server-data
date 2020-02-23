<template>
  <v-app v-if="showInterface">
    <v-content>
      <v-container fluid fill-height>
        <v-layout align-center justify-center>
          <v-flex xs9>
            <v-card class="elevation-12">
              <v-system-bar window dark>
                mysql-async Explorer
                <v-spacer></v-spacer>
                <v-icon @click="close()">close</v-icon>
              </v-system-bar>
              <v-tabs
                v-model="active"
                color="primary"
                slider-color="secondary"
              >
                <v-tab ripple>
                  Time-resolved
                </v-tab>
                <v-tab ripple>
                  Resources
                </v-tab>
                <v-tab ripple>
                  Slowest Queries
                </v-tab>
                <v-tab-item>
                  <v-flex xs12 pa-2 style="height: 480px;">
                    <m-chart
                      id="time-graph"
                      :labels="timeLabels" 
                      :datasets="timeData"
                      height="540"
                    ></m-chart>
                  </v-flex>
                </v-tab-item>
                <v-tab-item>
                  <v-flex xs12 pa-2 style="height: 480px;">
                    <m-chart
                      id="resource-graph"
                      :labels="resourceLabels"
                      :datasets="resourceData"
                      height="540"
                    ></m-chart>
                  </v-flex>
                </v-tab-item>
                <v-tab-item>
                  <v-flex xs12 pa-2 style="height: 480px;">
                    <v-data-table
                      align-end
                      :headers="headers"
                      :items="slowqueries"
                      :rows-per-page-items="[7]"
                    >
                      <template v-slot:items="props">
                        <td>{{ props.item.resource }}</td>
                        <td>{{ props.item.sql }}</td>
                        <td>{{ props.item.queryTime }}</td>
                      </template>
                    </v-data-table>
                  </v-flex>
                </v-tab-item>
              </v-tabs>
              <v-footer dark color="black" height="28" style="min-height: 28px;">
              </v-footer>
            </v-card>
          </v-flex>
        </v-layout>
      </v-container>
    </v-content>
  </v-app>
</template>

<script>
import MChart from './components/MChart.vue';

export default {
  components: {
    MChart,
  },
  data() {
    return {
      showInterface: false,
      colorGraphLoad: {
        backgroundColor: [
          'rgba(54, 73, 93, 0.5)',
        ],
        borderColor: [
          '#36495d',
        ],
        borderWidth: 3,
      },
      colorGraphAvg: {
        backgroundColor: [
          'rgba(71, 183, 132, 0.5)',
        ],
        borderColor: [
          '#47b784',
        ],
        borderWidth: 3,
      },
      colorGraphCount: {
        backgroundColor: [
          'rgba(62, 128, 113, 0.5)',
        ],
        borderColor: [
          '#3e8071',
        ],
        borderWidth: 3,
      },
      resourceData: [],
      resourceLabels: [],
      timeLabels: [],
      timeData: [],
      slowqueries: [
        {
          resource: 'memes',
          sql: 'SELECT * FROM memes',
          queryTime: 5000,
        },
      ],
      headers: [
        {
          text: 'Resource',
          value: 'resource',
        },
        { 
          text: 'Query', 
          value: 'sql',
          sortable: false, 
        },
        { 
          text: 'Execution Time (ms)',
          value: 'queryTime',
        },
      ],
    };
  },
  destroyed() {
    window.removeEventListener('message', this.listener);
  },
  methods: {
    close() {
      fetch('http://mysql-async/close-explorer', {
        method: 'post',
        body: JSON.stringify({
          close: true,
        }),
      });
    },
    onToggleShow() {
      this.showInterface = !this.showInterface;
    },
    onSlowQueryData({ slowQueries }) {
      if (Array.isArray(slowQueries)) {
        this.slowqueries = slowQueries;
      }
    },
    onTimeData({ timeData }) {
      if (Array.isArray(timeData) && timeData.length === 3) {
        this.timeData = [
          Object.assign({}, this.colorGraphLoad, { label: 'Server Load (ms)' }, timeData[0]),
          Object.assign({}, this.colorGraphAvg, { label: 'Average Query Time (ms)' }, timeData[1]),
          Object.assign({}, this.colorGraphCount, { label: 'Query Count' }, timeData[2]),
        ];
        const labels = [];
        for (let i = timeData[0].data.length - 1; i > -1; i -= 1) {
          if (i !== 0) {
            labels.push(`-${i*5}min`);
          } else {
            labels.push('now');
          }
        }
        this.timeLabels = labels;
      }
    },
    onResourceData({ resourceData }) {
      if (Array.isArray(resourceData) && resourceData.length === 3) {
        this.resourceData = [
          Object.assign({}, this.colorGraphLoad, { label: 'Server Load (ms)' }, resourceData[0]),
          Object.assign({}, this.colorGraphAvg, { label: 'Average Query Time (ms)' }, resourceData[1]),
          Object.assign({}, this.colorGraphCount, { label: 'Query Count' }, resourceData[2]),
        ];
      }
    },
    onResourceLabels({ resourceLabels }) {
      this.resourceLabels = resourceLabels;
    },
  },
  mounted() {
    this.listener = window.addEventListener('message', (event) => {
      const item = event.data || event.detail;
      if (item.type) {
        if (this[item.type]) this[item.type](item);
      }
    });
  },
  name: 'app',
}
</script>

<style lang="stylus">
$body-font-family = 'Fira Sans', sans-serif;
@require '~vuetify/src/stylus/app.styl';

html
  overflow-y auto

.app-background, .theme--light.application
  background rgba(0, 0, 0, 0.5) !important

font-url(file)
  return './assets/fonts/' + file

webfont(family, file, style = 'normal', weight = 400)
  @font-face
    font-family family
    font-style style
    font-weight weight 
    src url(font-url(file + '.woff2')) format('woff2'),
        url(font-url(file + '.woff')) format('woff')

webfont('Fira Sans', 'fira-sans-v9-latin-regular')
webfont('Fira Sans', 'fira-sans-v9-latin-italic', italic)
webfont('Fira Sans', 'fira-sans-v9-latin-700', normal, 700)
</style>
