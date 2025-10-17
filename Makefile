# Default target to show help if 'make' is run without arguments.
.DEFAULT_GOAL := help

# This ensures that 'deploy' and 'help' are treated as commands, not files.
.PHONY: deploy help

# This line is a placeholder for the commit message variable.
# Example: make deploy m="Your commit message here"
m :=

deploy:
# 1. Check if the commit message 'm' was provided.
# This is a Make directive and must NOT be indented with a tab.
ifeq ($(strip $(m)),)
	$(error Commit message is missing. Usage: make deploy m="Your commit message")
endif

	# The following lines are commands and MUST start with a TAB character.
	
	# 2a. Clean the public directory.
	@echo "🧹 Step 1/8: Cleaning the public directory..."
	rm -rf public/*
	
	# 2b. Build the site with Hugo.
	@echo "🚀 Step 2/8: Building site with Hugo..."
	hugo

	# 2c. Add all changes specifically in the 'public' submodule.
	@echo " public submodule | Step 3/8: Adding changes..."
	git submodule foreach 'if [ "$$path" = "public" ]; then git add .; fi'

	# 2d. Commit changes specifically in the 'public' submodule.
	@echo " public submodule | Step 4/8: Committing changes..."
	git submodule foreach 'if [ "$$path" = "public" ]; then git commit -m "$(m)" || true; fi'

	# 2e. Push changes specifically from the 'public' submodule.
	@echo " public submodule | Step 5/8: Pushing updates..."
	git submodule foreach 'if [ "$$path" = "public" ]; then git push; fi'

	# 2f. Add all changes in the main repository (including the submodule update).
	@echo " main repo      | Step 6/8: Adding changes..."
	git add .

	# 2g. Commit changes in the main repository.
	@echo " main repo      | Step 7/8: Committing changes..."
	git commit -m "$(m)"

	# 2h. Push the main repository.
	@echo " main repo      | Step 8/8: Pushing updates..."
	git push

	@echo "\n✅ All done! Deployment complete."

help:
	@echo 'Usage:'
	@echo '  make deploy m="<your commit message>"    Builds and deploys the site with the given commit message.'
	@echo ''
	@echo 'Example:'
	@echo '  make deploy m="Update blog post about Makefiles"'