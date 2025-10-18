.DEFAULT_GOAL := deploy

.PHONY: deploy help

m :=

clean_public:
	
	@echo "🧹 Step 1/8: Cleaning the public directory..."
	rm -rf public/*

build: clean_public
	
	@echo "🚀 Step 2/8: Building site with Hugo..."
	hugo

publish: 
ifeq ($(strip $(m)),)
	$(error Commit message is missing. Usage: make deploy m="Your commit message")
endif
	@echo " public submodule | Step 3/8: Adding changes..."
	git submodule foreach 'if [ "$$path" = "public" ]; then git add .; fi'

	@echo " public submodule | Step 4/8: Committing changes..."
	git submodule foreach 'if [ "$$path" = "public" ]; then git commit -m "$(m)" || true; fi'

	@echo " public submodule | Step 5/8: Pushing updates..."
	git submodule foreach 'if [ "$$path" = "public" ]; then git push; fi'

	@echo " main repo      | Step 6/8: Adding changes..."
	git add .

	@echo " main repo      | Step 7/8: Committing changes..."
	git commit -m "$(m)"

	@echo " main repo      | Step 8/8: Pushing updates..."
	git push

deploy:

	@echo "\n Step 1: Building ..."
	make build 
	@echo "\n Step 2: Publishing ..."
	make publish
	@echo "\n✅ All done! Deployment complete."


help:
	@echo 'Usage:'
	@echo '  make deploy m="<your commit message>"    Builds and deploys the site with the given commit message.'
	@echo ''
	@echo 'Example:'
	@echo '  make deploy m="Update blog post about Makefiles"'