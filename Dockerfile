FROM ubuntu:18.04

# User Name
ARG USERNAME=yoichiro6642

# Install Dependencies
RUN apt-get update && \
    apt-get install -y build-essential wget curl zip apt-transport-https lsb-release software-properties-common && \
# Azure CLI
    AZ_REPO=$(lsb_release -cs) && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | tee /etc/apt/sources.list.d/azure-cli.list && \
    apt-key --keyring /etc/apt/trusted.gpg.d/Microsoft.gpg adv --keyserver packages.microsoft.com --recv-keys BC528686B50D79E339D3721CEB3E94ADBE1229CF && \
    apt-get update && \
    apt-get install -y azure-cli && \
# .Net Core Runtime
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.asc.gpg && \
    mv microsoft.asc.gpg /etc/apt/trusted.gpg.d/ && \
    wget -q https://packages.microsoft.com/config/ubuntu/18.04/prod.list && \
    mv prod.list /etc/apt/sources.list.d/microsoft-prod.list && \
    chown root:root /etc/apt/trusted.gpg.d/microsoft.asc.gpg && \
    chown root:root /etc/apt/sources.list.d/microsoft-prod.list && \
    apt-get update && \
    apt-get install -y aspnetcore-runtime-2.2 && \
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && \
    mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg && \
    sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-$(lsb_release -cs)-prod $(lsb_release -cs) main" > /etc/apt/sources.list.d/dotnetdev.list' && \
    apt-get update && \
    apt-get install -y azure-functions-core-tools && \
# .Net Core SDK
    wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    add-apt-repository universe && \
    apt-get update && \
    apt-get install -y dotnet-sdk-2.2 && \
    rm -f packages-microsoft-prod.deb && \
# Azure Functions Core Tools
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && \
    mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg && \
    sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-$(lsb_release -cs)-prod $(lsb_release -cs) main" > /etc/apt/sources.list.d/dotnetdev.list' && \
    apt-get update && \
    apt-get install -y azure-functions-core-tools && \
# JDK 8
    apt-get install -y openjdk-8-jdk

# Add a new user
RUN groupadd --gid 1000 $USERNAME && useradd -u 1000 -g 1000 -s /bin/bash -d /home/$USERNAME -m $USERNAME
USER $USERNAME

WORKDIR /home/$USERNAME

# SDKMAN, gradle, maven, Spring Boot
RUN curl -s "https://get.sdkman.io" | bash && \
    /bin/bash -l -c 'source "$HOME/.sdkman/bin/sdkman-init.sh"; sdk install gradle 5.1.1; sdk install maven 3.6.0; sdk install springboot 2.1.1.RELEASE'

# Install nodebrew and NodeJS 8
RUN curl -L git.io/nodebrew | perl - setup && \
    /home/$USERNAME/.nodebrew/current/bin/nodebrew install-binary v8.15.0 && \
    /home/$USERNAME/.nodebrew/current/bin/nodebrew use v8.15.0 && \
    /bin/bash -l -c 'echo "export PATH=$HOME/.nodebrew/current/bin:$PATH" >> $HOME/.bashrc'

# Prepare working directory
WORKDIR /home/$USERNAME/project

VOLUME /home/$USERNAME/project

CMD ["/bin/bash"]
