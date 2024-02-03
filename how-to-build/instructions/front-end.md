## IN THE BEGINNING...

There was a raspberry pi 4 that was left over from on of the IoT PoCs I did at work. This particular one have travelled all the way from Plano, Tx to HBVU, Se. It was purchased by a former employer and given to me as I worked on the subsequyent employer trying to helps afore mentioned former employer.  

I decided to use it to serve as the front end to the hbvu cloud. Not something one would do if one was expecting to serve a lot of traffic.  

I deployed nginx as a proxy server (using defaults) and later Maria Db to back up my k3s Cluster. This is what i did:  
  
 ``` bash  
$ sudo apt install nginx 

$ sudo apt install mariadb-server && sudo mysql_secure_installation 
(Answer Y to everything and change the root PWD)
  
	MariaDB [(none)]> ALTER USER 'root'@'localhost' IDENTIFIED BY '<SOME MORE SECURE PWD>';

$ sudo mysql -u root -p
	MariaDB [(none)]> CREATE USER 'lucarv'@'%' IDENTIFIED BY '<SOME SECURE ish PWD>';
    MariaDB [(none)]> GRANT ALL PRIVILEGES ON *.* TO 'lucarv'@'%';
    MariaDB [(none)]> FLUSH PRIVILEGES;
    MariaDB [(none)]> quit;
 ```