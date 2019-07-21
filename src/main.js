import Vue from 'vue'
import Wedding from './Wedding.vue'

var axios = require('axios');
axios.defaults.baseURL = 'https://xiehuangbaobao:8081/rest'
// 将API方法绑定到全局
Vue.prototype.$axios = axios;
Vue.config.productionTip = false;
/* eslint-disable no-new */
new Vue({
  el: '#app',
  render: h => h(Wedding)
});