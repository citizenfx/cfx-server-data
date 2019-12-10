Vue.component('suggestions', {
  template: '#suggestions_template',
  props: ['message', 'suggestions'],
  data() {
    return {};
  },
  computed: {
    currentSuggestions() {
      if (this.message === '') {
        return [];
      }
      const currentSuggestions = this.suggestions.filter((s) => {
        if (!s.name.startsWith(this.message)) {
          const suggestionSplitted = s.name.split(' ');
          const messageSplitted = this.message.split(' ');
          for (let i = 0; i < messageSplitted.length; i += 1) {
            if (i >= suggestionSplitted.length) {
              return i < suggestionSplitted.length + s.params.length;
            }
            if (suggestionSplitted[i] !== messageSplitted[i]) {
              return false;
            }
          }
        }
        return true;
      }).slice(0, CONFIG.suggestionLimit);

      currentSuggestions.forEach((s) => {
        // eslint-disable-next-line no-param-reassign
        s.disabled = !s.name.startsWith(this.message);

        s.params.forEach((p, index) => {
          const wType = (index === s.params.length - 1) ? '.' : '\\S';
          const regex = new RegExp(`${s.name} (?:\\w+ ){${index}}(?:${wType}*)$`, 'g');

          // eslint-disable-next-line no-param-reassign
          p.disabled = this.message.match(regex) == null;
        });
      });
      return currentSuggestions;
    },
  },
  methods: {},
});
