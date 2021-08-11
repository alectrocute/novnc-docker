FROM debian:buster

ENV LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=C.UTF-8 DISPLAY=:0.0

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
      bzip2 \
      gstreamer1.0-plugins-good \
      gstreamer1.0-pulseaudio \
      gstreamer1.0-plugins-bad \
      gstreamer1.0-tools \
      libglu1-mesa \
      libgtk2.0-0 \
      libncursesw5 \
      libopenal1 \
      libsdl-image1.2 \
      libsdl-ttf2.0-0 \
      libsdl1.2debian \
      libsndfile1 \
      novnc \
      pulseaudio \
      supervisor \
      ucspi-tcp \
      wget \
      x11vnc \
      nginx \
      xvfb;

ARG SRC_URL="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"

RUN wget -O /tmp/google-chrome.deb "${SRC_URL}"; \
    apt-get install -y --no-install-recommends /tmp/google-chrome.deb;

COPY chrome/policies.json /etc/opt/chrome/policies/managed/policies.json

# nginx
COPY nginx/nginx.conf /etc/nginx/nginx.conf

RUN rm -rf /var/lib/apt/lists/*

# Configure pulseaudio.
COPY pulseaudio/default.pa pulseaudio/client.conf /etc/pulse/

# Force vnc_lite.html to be used for novnc, to avoid having the directory listing page.
# Additionally, turn off the control bar. Finally, add a hook to start audio.
COPY novnc/webaudio.js /usr/share/novnc/core/
COPY novnc/index.html /usr/share/novnc/index.html
COPY novnc/style.css /usr/share/novnc/app/styles/lite.css

# RUN ln -s /usr/share/novnc/vnc_lite.html /usr/share/novnc/index.html \
#  && sed -i 's/display:flex/display:none/' /usr/share/novnc/app/styles/lite.css \
#  && sed -i "/import RFB/a \
#       import WebAudio from './core/webaudio.js'" \
#     /usr/share/novnc/vnc_lite.html \
#  && sed -i "/function connected(e)/a \
#       const stream_location = location.port && [80, 443].indexOf(location.port) ? 'ws://' + location.hostname + ':' + location.port + '/audio' : 'ws://' + location.hostname + '/audio'; \
#       var wa = new WebAudio(stream_location); \
#       document.getElementsByTagName('canvas')[0].addEventListener('keydown', e => { wa.start(); });" \
#     /usr/share/novnc/vnc_lite.html

# Configure supervisord.
COPY supervisord/supervisord.conf /etc/supervisor/supervisord.conf
ENTRYPOINT [ "supervisord", "-c", "/etc/supervisor/supervisord.conf" ]

# Run everything as standard user/group df.
RUN groupadd df \
 && useradd --create-home --gid df df
WORKDIR /home/df
USER df

COPY --chown=df chrome/preferences.json /home/df/.config/google-chrome/Default/Preferences