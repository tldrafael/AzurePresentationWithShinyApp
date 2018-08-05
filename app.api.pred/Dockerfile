FROM tldrafael/toledoshiny:latest

RUN rm -rf /srv/shiny-server/*

WORKDIR /home/shiny/
RUN mkdir models songs
RUN chown -R shiny:shiny /home/shiny

COPY . /srv/shiny-server/
COPY env.list .Renviron
CMD shiny-server