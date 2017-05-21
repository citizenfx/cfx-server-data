Vue.component('message', {
  template: '#message_template',
  data() {
    return {};
  },
  computed: {
    textEscaped() {
      let s = '';
      if (this.template) {
        s = this.colorize(this.template);
      } else {
        s = this.colorize(this.templates[this.templateId]);
      }
      return s.replace(/{(\d+)}/g, (match, number) => {
        const argEscaped = this.args[number] != undefined ? this.escape(this.args[number]) : match
        if (number == 0 && this.color) {
          //color is deprecated, use templates or ^1 etc.
          return this.colorizeOld(argEscaped);
        }
        return argEscaped;
      });
    },
  },
  methods: {
    colorizeOld(str) {
      return `<strong style="color: rgb(${this.color[0]}, ${this.color[1]}, ${this.color[2]})">${str}</strong>`
    },
    colorize(str) {
      const s = "<span>" + (str.replace(/\^([0-9]+)/g, (str, color) => `</span><span class="color-${color}">`)) + "</span>";
      return s.replace(/<span[^>]*><\/span[^>]*>/g, '');
    },
    escape(unsafe) {
      return String(unsafe)
       .replace(/&/g, '&amp;')
       .replace(/</g, '&lt;')
       .replace(/>/g, '&gt;')
       .replace(/"/g, '&quot;')
       .replace(/'/g, '&#039;');
    },
  },
  props: {
    templates: {
      type: Object,
    },
    args: {
      type: Array,
    },
    template: {
      type: String,
      default: null,
    },
    templateId: {
      type: String,
      default: CONFIG.defaultTemplateId,
    },
    multiline: {
      type: Boolean,
      default: false,
    },
    color: { //deprecated
      type: Array,
      default: false,
    },
  },
});
