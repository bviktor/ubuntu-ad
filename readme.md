# Scripts for Active Directory integration on Ubuntu

These scripts help you automate the task of integrating an Ubuntu workstation with Active Directory, including:

* AD authentication with cached credentials, so that the colleague can use the workstation (laptop) at home, too
* AD sudo rules that are also cached
* Full disk encryption that you can unlock with an USB key, but which also has a recovery key stored in AD in case the USB key gets lost/stolen

Things you need to do before using these scripts:

* Read the Vault-Tec Archives article carefully: [Integrating Ubuntu with Active Directory](http://vault-tec.info/post/132414642261/integrating-ubuntu-with-active-directory).
* Follow the instructions of the article, especially regarding the initial setup of Ubuntu and the extension of the AD schema.
* Format a thumb drive with **ext2** filesystem, label it as **KEY** and mount it under your username, i.e. **/media/your.username/KEY**.
* Become root with **sudo -i** and cd to **/root**.
* Clone this repo there, i.e. **/root/ubuntu-ad**.
* Replace all occurences of **ad.foobar.com** and **AD.FOOBAR.COM** with your actual domain name in **ad.sh**, preserving the case.
* Replace all occurences of **/dev/sda3** with your actual partition name for encrpytion on **fde.sh**.

Yeah, there are quite a few things to take care of, but then it will save you _a lot_ of time, trust me.
