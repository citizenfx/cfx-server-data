window.MESSAGE = {
  template: '#message_template',
  data() {
    return {};
  },
  computed: {
    textEscaped() {
      return this.template.replace(/{(\d+)}/g, (match, number) => {
        return this.args[number] != undefined ? this.escapeHtml(this.args[number]) : match
      });
    },
  },
  created() {

  },
  methods: {
    escapeHtml(unsafe) {
      return unsafe
       .replace(/&/g, '&amp;')
       .replace(/</g, '&lt;')
       .replace(/>/g, '&gt;')
       .replace(/"/g, '&quot;')
       .replace(/'/g, '&#039;');
    },
  },
  props: {
    args: {

    },
    template: {
      type: String,
      default: window.CONFIG.defaultTemplate,
    },
    multiline: {
      type: Boolean,
      default: false,
    },

    color: {
      type: String,
    },
  },
};
