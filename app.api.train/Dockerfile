FROM tldrafael/toledoshiny:latest

RUN R -e 'install.packages("jsonlite", repos="https://cran-r.c3sl.ufpr.br/")'

RUN rm -rf /srv/shiny-server/*

WORKDIR /home/shiny/
RUN mkdir models
RUN chown -R shiny:shiny /home/shiny
COPY . /srv/shiny-server/

COPY env.list .Renviron
CMD shiny-server