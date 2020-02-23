import Vue from 'vue';
import '../ui/plugins/vuetify';
import App from '../ui/Nui.vue';

Vue.config.productionTip = false;

new Vue({
  render(h) { return h(App); },
}).$mount('#app');
