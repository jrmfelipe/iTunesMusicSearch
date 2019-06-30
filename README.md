# iTunesMusicSearch

Issue found when using iTunes Search API
================================
Using paging by adding "offset"  parameter to the URL request will sometime give duplicate result.
* Link 1:   https://itunes.apple.com/search?term=work&offset=0&limit=10
* Link 2:   https://itunes.apple.com/search?term=work&offset=11&limit=10
* Link 3:   https://itunes.apple.com/search?term=work&offset=21&limit=10

Link 2 and 3 will be used when retrieving page 2 and 3 respectively. Result  in link 2 for items 8,9,10  (Link 2) will be duplicated in the results in link 3

A workaround was added.

Developer Note
============
* The code contains the core functional requirement.
* Uses auto-layout and works on landscape mode 
* Universal app. 
* No 3rd party library was added to the project. 
* App will fetch 25 results at a time
* Tested on iPhone Xs and iPhone/iPad Simulators

To be honest I'm fairly new on using swift,  been reading/studying more about swift. Initially created the application using MVC architecture due to the fact that I haven't use MVVM architecture. My goal was to submit a working application even if I have to use MVC instead on MVVM. Upon completion of the app in MVC, I did more research on how MVVM works and how it can be applied in this application. I was able to convert the app from MVC to MVVM and saw the benefits of MVVM over MVC, the code is a lot more organized, the view controller code size is a lot smaller. I was able to develop/implement code a lot faster. I should have aim for MVVM from the start, lesson learned :)

For sure that I finish the option component as a personal project, more exposure and applying what I've learned is always a good way to gain more experience. It will also allow me to explore swift full potential.

