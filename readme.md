# Readme

## How to install
   `python(3) docker_compose_with_secrets [options]` -d is good for testing 

## How to Run

Use the following command to start a container:
   `docker run -p 5900:5900 --mount type=bind,source=<folder to share>,target=<Place on container> <image name or tag(I think?)`
   
## Other usefull docker stuff
   `docker images` list all images
   `docker rmi (docker images -a -q)` remove all unused images
   

## To Do

   [*] add git keys to GH on run
   [ ] Change https pull files to ssh
   [ ] git add . git commit -m "some message on save of .files" git push file 
       watcher program (periodically poll for repo changes)
   [ ] Make additions to bash RC in another file and touch to end rather than ovewiritng it
   [ ] inception pull in DevSetup repo to be able to tweak and push locally
   [ ] add user to dockerfile
   [ ] Do security of vnc and perhaps no vnc
   [ ] setup read in 
   [ ] Do everything else I want with it automated to push to the repo so I make my 
       environment how I want and it keeps it updated online
   [ ] Spawning new windows per GH branch
