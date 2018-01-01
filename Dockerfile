FROM ubuntu:16.04

ENV USERNAME haskell
ENV HOME /home/$USERNAME
ENV PROJECTS_DIR $HOME/projects
ENV PATH $HOME/.local/bin:$PATH
ENV DISPLAY :0

RUN apt-get update && apt-get install -y --no-install-recommends \
		wget \
		apt-transport-https \
		ca-certificates \
		curl \
		fakeroot \
		gconf2 \
		gconf-service \
		git \
		gvfs-bin \
		libasound2 \
		libcap2 \
		libgconf-2-4 \
		libgtk2.0-0 \
		libnotify4 \
		libnss3 \
		libxkbfile1 \
		libxss1 \
		libxtst6 \
		libgl1-mesa-glx \
		libgl1-mesa-dri \
		python \
		xdg-utils && \
		apt-get clean 
RUN wget -qO- https://packagecloud.io/AtomEditor/atom/gpgkey | apt-key add -
RUN sh -c 'echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" > /etc/apt/sources.list.d/atom.list'
RUN apt-get update && apt-get install -y atom && apt-get clean

RUN wget -qO- https://get.haskellstack.org/ | sh

RUN useradd -ms /bin/bash $USERNAME
WORKDIR $HOME

USER $USERNAME
RUN mkdir $PROJECTS_DIR
WORKDIR $PROJECTS_DIR
VOLUME ["$HOME/.stack","$HOME/.atom","$HOME/.local/bin","$PROJECTS_DIR"]

CMD stack setup && \
	stack install stylish-haskell && \
	stack install ghc-mod && \
	apm install language-haskell ide-haskell ide-haskell-cabal haskell-ghc-mod autocomplete-haskell && \
	atom -f