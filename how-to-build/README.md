# SELF HOSTING AT HBVU  

Like most of other geeks I know, I have gone through and never really recycled a number of computers, desktops and laptops alike. They all ended up in a corner of an attic or garage. They were just there gathering dust and waiting to be disposed of. Which is a hertbreaking thing to do, because they are still perfectly functional.  
So I decided to just powered tham all up and start on a journey of self hosting.  
There are about amillion blogs that explain and even proclaim the benefits of self hosting. I am not going to do that. I am just going to document my journey and the steps I took to get to where I am now.  

## The Hardware  
  
I had a bunch of old HP desktops and laptops and a couple of Raspberry Pi's, and even a Fujitsu laptop with a broken screen (why onearth did I ever keep it...).

## Clustering  
  
I had some experience with ProxMox through an earlier project at work, so I decided to use that to give the pile of old computer junk a layer of abstaction that would allow me to manage them as a cluster.  
Like I have done many times before, I created an USB bootable stick with a ProxMox ISO image. Then I proceeded to boot the old junk and was amused by the different choice of keys I had to press to force the machines to boot from the USB stick. But once this hurdle could be overcome, the process is fairly straight forward and it is very well-documented at inumerous blogposts on Medium and elsewhere.  

## Host OS  
  
Despite have no familiarity with immutable OS, I decided to go with Flatcar Linux. I had read about it and it seemed like a good fit for my needs. It was surprisingly easy to get it to work and it actually booted really quickly.  
[flatcar](how-to-build/flatcar.md)  


## The K3S Cluster  
[k3s](how-to-build/k3s.md)  

  
