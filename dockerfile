ARG DEV_USER=jack

FROM ubuntu:24.04

ARG DEV_USER

RUN apt-get update && apt-get install -y --no-install-recommends \
  curl \
  wget \
  tar \
  unzip \
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

# install helix
ENV HELIX_RELEASE=25.01.1
ENV HELIX_VERSION=25.1.1
RUN wget "https://github.com/helix-editor/helix/releases/download/${HELIX_RELEASE}/helix_${HELIX_VERSION}-1_amd64.deb" -O helix.deb && \
  dpkg -i helix.deb && \
  rm helix.deb

# set up dev profile and tools
RUN useradd -m -s "/opt/microsoft/powershell/7/pwsh" ${DEV_USER}
USER ${DEV_USER}

# rust tools
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/home/${DEV_USER}/.cargo/bin:${PATH}"

# python dev tools
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/home/${DEV_USER}/uv/bin:${PATH}"

# grammar and spelling tools
RUN cargo install harper-ls --locked

# cargo based tools
RUN cargo install zoxide --locked
RUN cargo install ripgrep

# powershell dev tools
USER root
RUN mkdir -p /opt/PowerShellTools
RUN wget "https://github.com/PowerShell/PowerShellEditorServices/releases/latest/download/PowerShellEditorServices.zip" -O pes.zip  && \
    unzip pes.zip -d /opt/PowerShellTools && \
    rm pes.zip
RUN chown -R ${DEV_USER}:${DEV_USER} /opt/PowerShellTools
USER ${DEV_USER}

# setup powershell profile
RUN curl -s https://ohmyposh.dev/install.sh | bash -s
ENV PATH=$PATH:/home/${DEV_USER}/.local/bin
COPY --chown=${DEV_USER}:${DEV_USER} profile.ps1 /home/${DEV_USER}/.config/powershell/Microsoft.PowerShell_profile.ps1

# helix config files
RUN mkdir -p /home/${DEV_USER}/.config/helix
COPY --chown=${DEV_USER}:${DEV_USER} helix/ /home/${DEV_USER}/.config/helix/
RUN hx -g fetch && hx -g build

# final items
USER ${DEV_USER}
WORKDIR /home/${DEV_USER}
ENTRYPOINT ["/opt/microsoft/powershell/7/pwsh", "-NoLogo"]
