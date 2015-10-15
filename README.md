# Salt-Stack

This is an attempt to understand Salt Stack and it's use in configuration management. I will try to install nginx onto a remote machine using Salt.

For more information, visit https://docs.saltstack.com/en/latest/


##Installation

I used 2 VM's from AWS, and I installed the Salt-master on one and the Salt-minion on the other. Check out this link for help with installation of Salt:
https://docs.saltstack.com/en/latest/topics/installation/

##Configuring the Salt Master
In order to configure the salt master we will need to add a directory for holding our config files first.

    root@master:~# mkdir -p /salt/states/base

Next, edit the /etc/salt/master configuration file,

    root@master:~# vi /etc/salt/master

and search for **file_roots**. Once you find it, uncomment it and make this change,

    file_roots:
    base:
      - /salt/states/base

This change helps Salt know where to look for the config files. Once all this is done, restart the salt-master service.

    root@master:~# service salt-master restart

##Configuring the Salt Minion

We have to edit the /etc/salt/minion configuration file,

    root@minion:~# vi /etc/salt/minion

and find the **master** line. Make the following change to it,

    master: yourMasterIpAddress

which will enable the Minion to talk to the Master(Gru - for all Despicable Me fans). Once that is done, restart the service.

    root@minion:~# service salt-minion restart

##Enabling communication between the Minions and the Master

Once the Minion service is restarted, it will try to talk to the Master. In order for the communication to work, the Master has to accept the keys from the Minions it wants to talk to.

*Note: If you haven't already, check if you can ping the Master from the Minion. By default, AWS does not allow this to happen. If the ping is unsuccessful, the following steps will not work. You will need to make changes to your AWS Instances so that they can ping each other.*

In the **Master** VM, run the following command,

    root@master:~# salt-key -L

This should display a list something like this,

    **Accepted Keys:**
    **Unaccepted Keys:**
    <<your minion ID>>
    **Rejected Keys:**

To accept your Minion's key, run this command: (This will accept just the Minion with the particular ID)

    root@master:~# salt-key -a <<minion ID>>

or to accept all keys,

    root@master:~# salt-key -A

Once the Minion key is accepted, you can test the connection with the following command,

    root@master:~# salt '*' test.ping

This will ping all Minions, and in turn they will reply back with a *True* status if they are able to communicate.

##Setting up the configuration files(in Master VM)

If you recall, */salt/states/base* was the base directory we had created earlier in the Master VM.

Since each state in salt needs a sub-directory in the respective environment, I will create a folder inside this directory,

    root@master:~# mkdir /salt/states/base/nginxState

Inside this folder, I will create the **init.sls** file, which holds the State configuration we need to run in our Minions.

    root@master:~# vi /salt/states/base/nginx/init.sls

Add the following code to this file:

    nginx:
      pkg:
        - installed
      service:
        - running
        
This tells Salt to install nginx as a Package, and also check that the nginx service is running after installation.

Once this is done, we need to tell the master which Minions are to be transported to this state. For that, we create another file, called **top.sls**,

root@master:~# vi /salt/states/base/top.sls

Add the following code to it:

    base:
      '*':
        - nginxState

This is like an Inventory file(if you have used Ansible). This tells the Salt master to make all Minions reach the **nginxState**. Do note that this name should correspond to the Sub-directory created in the previous step(where we placed the init.sls file).

*Note: We can also specify a certain Minion ID in place of the * above, if we want only a specific Minion to reach the nginxState.*

##Running Salt

Once all the configuration is done, we need to execute this command from the **Master** VM:

    root@master:~# salt '*' state.highstate
  
This should print a detailed message, which will be executing 2 tasks, first it will install nginx, and second it will make sure that the service is running.

#####References:

http://bencane.com/2013/09/03/getting-started-with-saltstack-by-example-automatically-installing-nginx/
