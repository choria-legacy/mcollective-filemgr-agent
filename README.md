#MCollective File Manager Agent

This agent let you touch files, delete files or retrieve a bunch of stats about a file.

##Installation
Follow the [basic plugin install guide](http://projects.puppetlabs.com/projects/mcollective-plugins/wiki/InstalingPlugins)

##Usage

To get the status of a file:

```
% mco rpc filemgr status file=/etc/puppet/puppet.conf
Determining the amount of hosts matching filter for 2 seconds .... 1

 * [ ============================================================> ] 1 / 1


dev1.example.com:
   Modification time: 1289650072
         Change time: Wed Nov 17 00:29:17 +0000 2010
         Change time: 1289953757
                Name: /etc/puppet/puppet.conf
               Owner: 0
         Access time: 1291150379
               Group: 0
                Size: 385
         Access time: Tue Nov 30 20:52:59 +0000 2010
             Present: 1
                Type: file
                Mode: 100644
   Modification time: Sat Nov 13 12:07:52 +0000 2010
                 MD5: 91b8793f2a467aa5d28f6371d3622090
              Status: present


Finished processing 1 / 1 hosts in 71.65 ms
```

You can similarly touch and remove a file using those named actions.
