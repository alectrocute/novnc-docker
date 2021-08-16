export default class WebAudio {
    constructor(url) {
        console.log("init", url)
        this.connected = false;

        this.audioEnabledButton = document.getElementById("audio-enabled");
        this.audioDisabledButton = document.getElementById("audio-disabled");
        this.audioEnabledButton.style = "display: none;"
    }

    connect() {
        console.log("connect")
        let el = document.createElement("audio");
        el.src = "/audio/audio.mp3"
        el.controls = true;
        el.autoplay = false;
        document.getElementById("controls").appendChild(el)
        el.play()
    }

    start() {
        console.log("start")
        // this.context = new(window.AudioContext ||
        //     window.webkitAudioContext)()
        this.connect()
        this.audioEnabledButton.style = "display: flex;"
        this.audioDisabledButton.style = "display: none;"
        this.audioEnabledButton.addEventListener("click", () => {
            // this.socket.close()
        }, true)
    }

    // whenever data arrives in our websocket this is called.
    websocketDataArrived(e) {
        this.connected = true;
        this.source = this.context.createBufferSource();
        if (e.data && e.data.length < 1) return;
        console.log(e.data)
        this.context.decodeAudioData(e.data, (data) => {
            this.source.buffer = data;
            this.source.connect(this.context.destination);
            this.source.noteOn(0);
        }, (err) => {
            console.error(err)
        })

    }
}