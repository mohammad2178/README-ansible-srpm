#
# Build mock and local RPM versions of tools for ansible
#

# Assure that sorting is case sensitive
LANG=C

# Requires compat-nettle32
MOCKS+=epel-7-x86_64
MOCKS+=epel-8-x86_64

MOCKCFGS+=$(MOCKS)

SPEC := `ls *.spec`

all:: $(MOCKS)

.PHONY: getsrc
getsrc::
	spectool -g $(SPEC)

srpm:: src.rpm

#.PHONY:: src.rpm
src.rpm:: Makefile
	@rm -rf rpmbuild
	@rm -f $@
	@echo "Building SRPM with $(SPEC)"
	rpmbuild --define '_topdir $(PWD)/rpmbuild' \
		--define '_sourcedir $(PWD)' \
		-bs $(SPEC) --nodeps
	mv rpmbuild/SRPMS/*.src.rpm src.rpm

.PHONY: build
build:: src.rpm
	rpmbuild --define '_topdir $(PWD)/rpmbuild' \
		--rebuild $?

.PHONY: $(MOCKS)
$(MOCKS):: src.rpm
	@if [ -e $@ -a -n "`find $@ -name \*.rpm 2>/dev/null`" ]; then \
		echo "	Skipping RPM populated $@"; \
	else \
		echo "Actally building $? in $@"; \
		rm -rf $@; \
		mock -q -r /etc/mock/$@.cfg \
		     --resultdir=$(PWD)/$@ \
		     $?; \
	fi

mock:: $(MOCKS)

clean::
	rm -rf */
	rm -f *.out
	rm -f *.rpm

realclean distclean:: clean
