Name:           testrpm
Version:        1.0
Release:        1%{?dist}
Summary:        Test package

License:        None
#URL:            http://loclahost/
#Source0:        

#BuildRequires:  
Requires:       bash

%description
Test package

#%prep
#%setup -q


%build


%install


%files

%post
if [ "$1" = 1 ]; then
    mkdir /etc/testpkg
    echo Test Install > /etc/testpkg/config
fi

%postun
if [ "$1" = 0 ] && [ -f /etc/testpkg/config ] ; then
    rm -r /etc/testpkg
fi

%changelog
* Fri Feb 19 2021 D
- First version
