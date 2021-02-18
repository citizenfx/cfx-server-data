document.addEventListener('DOMContentLoaded', function () {
    new Vue({
        el: '#loadingscreen',
        data: () => {
            return {
                changelog: null,
                status: 'Waiting for server',
                percentage: 0,
                initSessionLookup: {},
                currentTipIndex: 0,
                tips: null,
            }
        },
        methods: {
            nextTip() {
                this.currentTipIndex = (this.currentTipIndex + 1) >= this.randomizedTips.length ? 0 : this.currentTipIndex + 1;
            },
        },
        computed: {
            currentTip() {
                if (this.randomizedTips === null) {
                    return 'Toxicity is never the solution. Be kind and stay friendly'
                }

                return this.randomizedTips[this.currentTipIndex];
            }
        },
        created() {
            this.changelog = changelog_generated;
            this.randomizedTips = _.shuffle(tips);

            window.addEventListener('message', (event) => {
                if (event.data !== undefined && event.data.eventName !== undefined) {
                    switch (event.data.eventName) {
                        case 'onLogLine':
                            this.status = event.data.message;
                            break;
                        case 'loadProgress':
                            this.percentage = (event.data.loadFraction * 100).toFixed(2) || -1;
                            break;
                        case 'initFunctionInvoking':
                            this.status = 'Loading ' + event.data.name;
                            break;
                        case 'initFunctionInvoked':
                            this.status = 'Loaded ' + event.data.name;
                            break;
                        default:
                            // DEBUG
                            // console.debug(event.data.eventName || event.data);
                            // console.debug(event.data);
                            break;
                    }
                } else {
                    // DEBUG
                    // console.error('unknown');
                    // console.debug(event);
                }
            });
        },
        mounted() {
            setInterval(() => {
                this.nextTip();
            }, 4000);

            addEventListener("mousemove", (event) => {
                let cursor = document.getElementById("cursor");
                cursor.style.left = event.pageX - 7;
                cursor.style.top = event.pageY;
            });
        }
    });
});
