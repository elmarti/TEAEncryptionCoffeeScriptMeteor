How to run the project 
#if you haven't installed meteor
#linux 
curl https://install.meteor.com/ | sh
#windows 
https://www.meteor.com/install

#then do the following in the terminal or cmd 
meteor create informationsecurity 
cd project 
rm -f informationsecurity.js informationsecurity.html informationsecurity.css
#now that the directory is empty, paste in their place is.html and is.coffee from my project folder

#ensure all meteor packages, along with my additional ones are installed
meteor add autopublish blaze-html-templates coffeescript ecmascript es5-shim insecure jquery meteor-base mobile-experience mongo mrt:bootstrap-3 mrt:bootstrap-growl session standard-minifiers tracker
#to run project at localhost:3000
meteor
#to run at particular port (port 80 for example)
meteor --port 80