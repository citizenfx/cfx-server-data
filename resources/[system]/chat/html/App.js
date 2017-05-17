window.APP = {
  template: '#app_template',
  name: 'app',
  data() {
    return {
      showInput: false,
      showWindow: false,
      suggestions: [],
      message: '',
      messages: [],
      oldMessages: [],
      oldMessagesIndex: -1,
    };
  },
  destroyed() {
    clearInterval(this.focusTimer);
    window.removeEventListener('message', this.listener);
  },
  mounted() {
    axios.post('http://betterchat/loaded', {});
    this.listener = window.addEventListener('message', (event) => {
      const item = event.data || event.detail; //'detail' is for debuging via browsers
      if (this[item.type]) {
        this[item.type](item);
      }
    });
  },
  watch: {
    messages() {
      if (this.showWindowTimer) {
        clearTimeout(this.showWindowTimer);
      }
      this.showWindow = true;
      this.showWindowTimer = setTimeout(() => {
        if (!this.showInput) {
          this.showWindow = false;
        }
      }, window.CONFIG.fadeTimeout);

      const messagesObj = this.$refs.messages;
      this.$nextTick(() => {
        messagesObj.scrollTop = messagesObj.scrollHeight;
      });
    },
  },
  methods: {
    ON_OPEN() {
      this.showInput = true;
      this.showWindow = true;
      if (this.showWindowTimer) {
        clearTimeout(this.showWindowTimer);
      }
      this.focusTimer = setInterval(() => {
        if (this.$refs.input) {
          this.$refs.input.focus();
        } else {
          clearInterval(this.focusTimer);
        }
      }, 100);
    },
    ON_MESSAGE(data) {
      this.messages.push(data.message);
    },
    ON_SUGGESTION_ADD(data) {
      const suggestion = data.suggestion;
      if (!suggestion.params) {
        suggestion.params = [];
      }
      this.suggestions.push(suggestion);
    },
    ON_SUGGESTION_REMOVE() {
    },
    keyUp() {
      this.resize();
    },
    keyDown(e) {
      if (e.which === 38 || e.which === 40) {
        e.preventDefault();
        this.moveOldMessageIndex(e.which === 38);
      }
    },
    moveOldMessageIndex(up) {
      if (up && this.oldMessages.length > this.oldMessagesIndex + 1) {
        this.oldMessagesIndex += 1;
        this.message = this.oldMessages[this.oldMessagesIndex];
      } else if (!up && this.oldMessagesIndex - 1 >= 0) {
        this.oldMessagesIndex -= 1;
        this.message = this.oldMessages[this.oldMessagesIndex];
      } else if (!up && this.oldMessagesIndex - 1 === -1) {
        this.oldMessagesIndex = -1;
        this.message = '';
      }
    },
    resize() {
      const input = this.$refs.input;
      input.style.height = '5px';
      input.style.height = `${input.scrollHeight + 2}px`;
    },
    addLine() {
      this.message += '\n';
      this.resize();
    },
    send(e) {
      if (e.shiftKey || this.message === '') {
        return;
      }
      axios.post('http://betterchat/chatResult', {
        message: this.message,
      });
      this.oldMessages.unshift(this.message);
      this.message = '';
      this.showInput = false;

      this.showWindowTimer = setTimeout(() => {
        this.showWindow = false;
      }, window.CONFIG.fadeTimeout);
    },
    hideInput(canceled) {
      if (canceled) {
        axios.post('http://betterchat/chatResult', {
          canceled,
        });
      }
      this.showInput = false;
      clearInterval(this.focusTimer);

      this.showWindowTimer = setTimeout(() => {
        this.showWindow = false;
      }, window.CONFIG.fadeTimeout);
    },
  },
  components: {
    Message: window.MESSAGE,
    Suggestions: window.SUGGESTIONS,
  },
};

window.emulate_open = () => {
  window.dispatchEvent(new CustomEvent('message', {
    detail: {
      type: 'ON_OPEN',
    },
  }));
};

window.emulate_suggestion = (name, help, params = []) => {
  window.dispatchEvent(new CustomEvent('message', {
    detail: {
      type: 'ON_SUGGESTION_ADD',
      suggestion: {
        name,
        help,
        params,
      },
    },
  }));
};

window.emulate_message = (message) => {
  window.dispatchEvent(new CustomEvent('message', {
    detail: {
      type: 'ON_MESSAGE',
      message,
    },
  }));
};
