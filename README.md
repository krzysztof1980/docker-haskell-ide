# docker-haskell-ide
Dockerized development environment for Haskell, contains [Stack](https://docs.haskellstack.org/en/stable/README/) and [Atom-Haskell IDE](https://atom-haskell.github.io/) with standard Haskell-packages installed.

# Building the image
Clone this repository, cd to the directory docker-haskell-ide and run:
```
sudo docker build -t krzysztof1980/docker-haskell-ide .
```

# Running Atom-Haskell
I describe how to run it on Linux with X-server running. For more detais, see [this StackOverflow answer](https://stackoverflow.com/questions/25281992/alternatives-to-ssh-x11-forwarding-for-docker-containers/25334301#25334301), for another operating systems you can try [this one](https://stackoverflow.com/questions/16296753/can-you-run-gui-apps-in-a-docker-container/36190462#36190462). For alternative method, take a look at [mviereck/x11docker](https://github.com/mviereck/x11docker) - I did not test this project, but it claims to offer more security.

1. The method uses X11 socket to connect the docker container to the X-server running on host. Because of security policies, you may need to execute `xhost +si:localuser:$USER` in your terminal. 
1. The docker container is meant to be ephemeral, so to not loose any installed Stack packages and atom settings, you will bind mount several directories, that you need to create now:
    1. /home/haskell/.atom - this is where Atom stores its instance data (configurations, installed packages and simal things)
    1. /home/haskell/.stack - this is where Stack stores its data, for example packages that it installs, or the compiler
    1. /home/haskell/.local/bin - this is where Stack saves packages that it built
    1. /home/haskell/projects - this is where your projects reside
    For each of those directories, create corresponding ones on your host. For example locations, see the sample `docker run`-command provided in step 4. 
1. As described [here](https://atom-haskell.github.io/installation/installing-binary-dependencies/), ghc-mod does not not support GHC (Haskell compiler) in the version 8.2 yet (at least as I write this down). Therefore, you need to provide Stack a resolver, that installs the version 8.0. Download the file stack.yaml from this repository and copy it to .stack/global-project/stack.yaml. The exact location depends on what directory you choose to map /home/haskell/.stack to: given example command provided in the next step, it would be ${HOME}/.stack/global-project/stack.yaml.
1. Run the container. Example command could look like this:
    ```
    sudo docker run -d \
                    -v /tmp/.X11-unix/:/tmp/.X11-unix/ \
                    -v ${HOME}/.haskell-ide-docker:/home/haskell/.atom \
                    -v ${HOME}/.stack:/home/haskell/.stack 
                    -v ${HOME}/.local/bin:/home/haskell/.local/bin 
                    -v ${HOME}/dev/projects/haskell:/home/haskell/projects \
                    --rm \
                    krzysztof1980/haskell-ide
    ```
    Notice, that the first volume definition needs to be provided as given, the next 4 definitions can have their first parts chosen by you, because they define directories on your host, that the directories in the docker container, that I described in previous step, will be mapped to.
1. When the container is started, it tells stack to build some binary dependencies for Atom Haskell, as described [here](https://atom-haskell.github.io/installation/installing-binary-dependencies/). On further runs, it does not cost any time, because stack recognizes, that there is nothing to do. What may slow down the startup time a little is installation of Atom packages. To prevent this, you can overwrite the command from Dockerfile - just append `atom -f` to your docker run command.

# Credits
The part of my Dockerfile that installs Atom is based on https://github.com/jamesnetherton/docker-atom-editor. 
