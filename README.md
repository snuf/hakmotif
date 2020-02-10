Simple Kernel testing for modules
=================================
An easy way to regression test and forward test kernel modules.
Content is placed in an S3 bucket. I use Minio locally at the moment..

Steps
=====
- Kernel-updater: Linux-stable puller, keeps track of the linux-stable and updates the tree we have stored in S3.
- Kernel-builder: Builds linux kernel packages for specified version off linux-stable, using the image stored in S3 as a base
- Module-builder: Builds a module against a specific set of headers taken from S3
- Module-tester: Installs a specified kernel on a host OS (on supported OSs). Fetches the kernel module sources from github, builds them against the specified kernel, or the default kernel. With the packaging strategy of the Linux variant Inserts the kernel module, and runs FIO tests.
