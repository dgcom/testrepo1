# Creating simple RPM files

Install rpm toolset

    sudo yum install -y rpmdevtools rpmlint

Create empty folder tree

    rpmdev-setuptree
    
Create template .spec file

    rpmdev-newspec testrpm

Modify .spec file to add functionality
Check .spec file for errors

    rpmlint ~/rpmbuild/SPECS/testpkg.spec
    
Build package    

    rpmbuild -bb ~/rpmbuild/SPECS/testpkg.spec

Install package

    sudo rpm -iv testrpm-1.0-1.el7.x86_64.rpm

Uninstall package

    sudo rpm -ev testrpm

# Links
[How to create a Linux RPM package | Enable Sysadmin](https://www.redhat.com/sysadmin/create-rpm-package)
[How to create an rpm package - LinuxConfig.org](https://linuxconfig.org/how-to-create-an-rpm-package)
[Scriptlets :: Fedora Docs](https://docs.fedoraproject.org/en-US/packaging-guidelines/Scriptlets/#_syntax)
