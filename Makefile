# Work on the site in docs/.
#
#   make setup   install Ruby, build tools and the site's gems (asks for sudo)
#   make debug   serve the site with drafts and live reload on http://localhost:4000

SITE_DIR := docs

# Ubuntu 25.10+ defaults to sudo-rs, which Ansible can't drive; use the classic
# sudo (sudo.ws) when it is installed. See the header of setup-dev.yml.
BECOME_EXE := $(if $(wildcard /usr/bin/sudo.ws),-e ansible_become_exe=sudo.ws)

.PHONY: setup debug

setup:
	@command -v ansible-playbook >/dev/null || { \
		echo "ansible-playbook not found. Install it first:"; \
		echo "  sudo apt update && sudo apt install -y ansible"; \
		exit 1; }
	ansible-playbook -i localhost, -c local $(BECOME_EXE) -K setup-dev.yml

debug:
	@test -f $(SITE_DIR)/.bundle/config || { echo "Run 'make setup' first."; exit 1; }
	cd $(SITE_DIR) && bundle exec jekyll serve --livereload --drafts
