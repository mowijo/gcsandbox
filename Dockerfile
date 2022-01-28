FROM ubuntu:20.04

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y nano vim tmux build-essential cmake inotify-tools
RUN mkdir /sandbox
RUN useradd -ms /bin/bash sandman
RUN chown -R sandman:sandman /sandbox
USER sandman
WORKDIR /sandbox

RUN echo set -g mouse on > ~/.tmux.conf

RUN echo "#include <stdio.h>\n\nint main(int, char**)\n{\n   return 0;\n}\n" > main.cpp
RUN echo "cmake_minimum_required (VERSION 2.0.0)\nproject (sandbox)\n\nadd_executable (sandbox main.cpp)\nTARGET_LINK_LIBRARIES( sandbox pthread m)\n" > CMakeLists.txt
RUN cmake .
RUN make

CMD tmux new-session -d 'while inotifywait -qq -e close_write main.cpp; do make && clear && ./sandbox ; done'   \; split-window -h 'nano main.cpp' \; attach-session -d


