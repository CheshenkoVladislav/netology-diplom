FROM nginx:stable

RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

RUN rm /usr/share/nginx/html/index.html
COPY index.html /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]