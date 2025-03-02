FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
  curl \
  wget \
  apt-utils \
  build-essential \
  tmux \
  git \
  && rm -rf /var/lib/apt/lists/*

# powershell setup (this is an isolated block and can be reused for other images)
RUN apt-get update && apt-get install -y --no-install-recommends \
  wget \
  apt-transport-https \
  software-properties-common \
  && rm -rf /var/lib/apt/lists/*

RUN wget -q https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb && \
  dpkg -i packages-microsoft-prod.deb && \
  rm packages-microsoft-prod.deb && \
  apt-get update && \
  apt-get install -y powershell

# Define environment variables for Helix release folder and file version
ENV HELIX_RELEASE=25.01.1
ENV HELIX_VERSION=25.1.1

# Download and install Helix using wget with the confirmed URL
RUN wget "https://github.com/helix-editor/helix/releases/download/${HELIX_RELEASE}/helix_${HELIX_VERSION}-1_amd64.deb" -O helix.deb && \
  dpkg -i helix.deb && \
  rm helix.deb

# set up dev profile and tools
RUN useradd -ms /usr/bin/pwsh jack
USER jack
WORKDIR /home/jack/dev
