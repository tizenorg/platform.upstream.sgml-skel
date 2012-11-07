Name:           sgml-skel
Version:        0.6
Release:        0
License:        GPL-2.0+
Summary:        Helper Scripts for the SGML System
Group:          Productivity/Publishing/SGML
# URL:
Source0:        http://www.suse.de/~ke/%{name}/%{name}-%{version}.tar.bz2
# :pserver:anoncvs@sources.redhat.com:/cvs/docbook-tools
Source1:        docbook-tools/sgml-common/bin/install-catalog.in
Source2:        edit-xml-catalog.sh
Patch0:         sgml-skel-regcat.diff
Patch1:         sgml-skel-regcat2.diff
Patch2:         sgml-skel-edit-cat.diff
BuildRequires:  automake
BuildRequires:  libxml2-tools
Requires(pre):  /bin/awk
Requires(pre):  /bin/chmod
Requires(pre):  /bin/mv
Requires:       libxml2-tools
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildArch:      noarch

%description
These scripts will help prepare and maintain parts of an SGML system.

%define sgmldir %{_datadir}/sgml
%define INSTALL install -m755 -s
%define INSTALL_SCRIPT install -m755
%define INSTALL_DIR install -d -m755
%define INSTALL_DATA install -m644

%prep
%setup -q
%patch0 -p 1
%patch1 -p 1
# # cp -p $RPM_SOURCE_DIR/%{name}-README.SuSE .
cp %{SOURCE1} .
cp %{SOURCE2} .
%patch2 -p 0

%build
# CFLAGS="%{optflags}"
autoreconf -i -f
./configure --prefix=%{_prefix} --infodir=%{_infodir} \
  --datadir=%{_datadir} --mandir=%{_mandir} \
  --build $RPM_ARCH-%vendor-linux

%install
%make_install
%{INSTALL_SCRIPT} install-catalog.in %{buildroot}%{_bindir}/install-catalog
%{INSTALL_SCRIPT} edit-xml-catalog.sh \
  %{buildroot}%{_bindir}/edit-xml-catalog
ln -sf sgml2xmlcat.sh %{buildroot}%{_bindir}/sgmlcat2x.sh
ln -sf install-catalog %{buildroot}%{_bindir}/install-catalog.sh
%{INSTALL_DIR} %{buildroot}%{sgmldir}
%{INSTALL_DIR} %{buildroot}%{_sysconfdir}/{sgml,xml}
%{INSTALL_DIR} %{buildroot}%{_localstatedir}/lib/sgml
touch %{buildroot}%{_sysconfdir}/sgml/catalog
xmlcatalog --noout --create %{buildroot}%{_sysconfdir}/xml/tizen-catalog.xml
xmlcatalog --noout --create %{buildroot}%{_sysconfdir}/xml/catalog
xmlcatalog --noout --add  "nextCatalog" "tizen-catalog.xml" "tizen-catalog.xml" \
  %{buildroot}%{_sysconfdir}/xml/catalog

%files
%defattr(-, root, root)
%doc AUTHORS COPYING NEWS README*
%ghost %{_sysconfdir}/sgml/catalog
%ghost %{_sysconfdir}/xml/tizen-catalog.xml
%config %verify(not md5 size mtime) %{_sysconfdir}/xml/catalog
%dir %{_sysconfdir}/sgml
%dir %{_sysconfdir}/xml
%{_bindir}/*
%dir %{_localstatedir}/lib/sgml

%changelog
